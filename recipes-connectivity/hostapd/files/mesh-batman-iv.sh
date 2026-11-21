# Some Rights Reserved. 2026 Federico Pietro Briata
#
# Licensed under the GNU General Public License (GPL) version 2 or later
# and the 3-Clause BSD License.

# batman-adv IV backend, sourced by hostapd-apup and apup-watchdog.
# Mandatory hooks: mesh_create, mesh_up, mesh_peer_attached, mesh_peer_up, mesh_stop, mesh_nat_rule.

PRIMARY_IF=primary0

# Before the Wi-Fi interface is brought up
mesh_create() {
    BAT_MAC="42:${PHY_MAC#*:}"
    PRIMARY_MAC="46:${PHY_MAC#*:}"
    if [ ! -d /sys/module/batman_adv ]; then
        modprobe batman-adv
    fi
    if ! ip link show dev "$MESH_IF" >/dev/null 2>&1; then
        ip link add name "$MESH_IF" type batadv
    fi
    batctl meshif "$MESH_IF" bl 0
    batctl meshif "$MESH_IF" multicast_mode 0
    batctl meshif "$MESH_IF" it "$ORIG_INTERVAL"
}

# After the Wi-Fi interface is up
mesh_up() {
    ip link set "$MESH_IF" address "$BAT_MAC"
    ip link set "$MESH_IF" mtu 1460
    ip link set "$MESH_IF" up
    ip addr flush dev "$MESH_IF"
    ip addr replace "$NODE_IP/16" broadcast "$NET_PREFIX.255.255" dev "$MESH_IF"

    # Added first so it stays the primary: the originator address no longer depends on which peer shows up first
    if ! ip link show dev "$PRIMARY_IF" >/dev/null 2>&1; then
        ip link add name "$PRIMARY_IF" type dummy
    fi
    ip link set "$PRIMARY_IF" address "$PRIMARY_MAC"
    ip link set "$PRIMARY_IF" up
    if ! batctl meshif "$MESH_IF" if | awk -v iface="$PRIMARY_IF:" '$1 == iface {found=1} END {exit !found}'; then
        batctl meshif "$MESH_IF" if add "$PRIMARY_IF"
    fi
}

mesh_info() {
    printf ' - Bat MAC: %s' "$BAT_MAC"
}

# Rule appended after "-s <hotspot network>" in the NAT chain; the words are split on purpose
mesh_nat_rule() {
    echo "-o $MESH_IF -j MASQUERADE"
}

# $1: peer interface, $2: its number
mesh_peer_attached() {
    batctl meshif "$MESH_IF" if | awk -v iface="mv$2:" '$1 == iface {found=1} END {exit !found}'
}

mesh_peer_up() {
    sta_if=$1
    MV_IF="mv$2"
    # Peer MAC on this WDS link; empty until hostapd has moved the station here, so retry on the next pass
    PEER_MAC=$(iw dev "$sta_if" station dump 2>/dev/null | awk '/^Station/ {print $2; exit}')
    [ -n "$PEER_MAC" ] || return 1
    # 02 (locally administered) + our MAC bytes 4-6 + peer MAC bytes 5-6: unique per peer, stable across reboots
    MV_MAC="02:$(printf '%s\n' "$PHY_MAC" | cut -d: -f4-6):$(printf '%s\n' "$PEER_MAC" | cut -d: -f5-6)"
    if ! ip link show dev "$MV_IF" >/dev/null 2>&1; then
        echo "Creating $MV_IF on $sta_if with MAC $MV_MAC"
        ip link add link "$sta_if" name "$MV_IF" address "$MV_MAC" type macvlan mode bridge || return 1
    fi
    ip link set dev "$MV_IF" up || return 1
    batctl meshif "$MESH_IF" if add "$MV_IF"
}

mesh_stop() {
    for mv_path in /sys/class/net/mv[0-9]*; do
        [ ! -e "$mv_path" ] || ip link del "${mv_path##*/}" 2>/dev/null || true
    done
}

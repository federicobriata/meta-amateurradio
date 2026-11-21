# Some Rights Reserved. 2026 Federico Pietro Briata
#
# Licensed under the GNU General Public License (GPL) version 2 or later
# and the 3-Clause BSD License.

# batman-adv V backend, sourced by hostapd-apup and apup-watchdog.
# The interfaces hostapd creates for the peers are added to the mesh as they
# are: unlike batman IV there are no macvlan and no dummy primary interface.
# Mandatory hooks: mesh_create, mesh_up, mesh_peer_attached, mesh_peer_up, mesh_stop, mesh_nat_rule.

# Before the Wi-Fi interface is brought up
mesh_create() {
    BAT_MAC="42:${PHY_MAC#*:}"
    if [ ! -d /sys/module/batman_adv ]; then
        modprobe batman-adv
    fi
    # The algorithm of an existing mesh interface cannot change: recreate it after a protocol switch
    if ip link show dev "$MESH_IF" >/dev/null 2>&1; then
        active=$(batctl ra | awk -v iface="$MESH_IF:" '$1 == "*" && $2 == iface {print $3}')
        if [ "$active" != BATMAN_V ]; then
            ip link del dev "$MESH_IF"
        fi
    fi
    if ! ip link show dev "$MESH_IF" >/dev/null 2>&1; then
        batctl ra BATMAN_V
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
    batctl meshif "$MESH_IF" if | awk -v iface="$1:" '$1 == iface {found=1} END {exit !found}'
}

mesh_peer_up() {
    echo "Adding $1"
    batctl meshif "$MESH_IF" if add "$1"
}

# The peer interfaces disappear with hostapd and batman-adv drops them by itself
mesh_stop() {
    :
}

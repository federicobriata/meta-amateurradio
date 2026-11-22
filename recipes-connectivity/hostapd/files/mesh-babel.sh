# Some Rights Reserved. 2026 Federico Pietro Briata
#
# Licensed under the GNU General Public License (GPL) version 2 or later
# and the 3-Clause BSD License.

# Babel backend, sourced by hostapd-apup and apup-watchdog.
# Layer 3 mesh: no bat0, no macvlan and no dummy interface. babeld routes between
# the interfaces hostapd creates for the peers and announces NODE_IP as a /32
# kept on lo. babeld refuses to start without interfaces, so the watchdog starts
# it on the first peer and adds the others through its local configuration server.
# Mandatory hooks: mesh_create, mesh_up, mesh_peer_attached, mesh_peer_up, mesh_stop, mesh_nat_rule.

# Read-write configuration server of babeld on ::1 (BusyBox nc cannot reach a unix socket)
BABEL_PORT=6697
BABEL_PID=$MESH_STATE_DIR/babeld.pid
BABEL_PEERS=$MESH_STATE_DIR/babel_peers
BABEL_ADDR=$MESH_STATE_DIR/babel_addr

# Before the Wi-Fi interface is brought up
mesh_create() {
    :
}

# After the Wi-Fi interface is up
mesh_up() {
    # babeld relays the traffic between the peers
    echo 1 > /proc/sys/net/ipv4/ip_forward
    ip addr replace "$NODE_IP/32" dev lo
    echo "$NODE_IP/32" > "$BABEL_ADDR"
    : > "$BABEL_PEERS"
}

babel_running() {
    [ -s "$BABEL_PID" ] && kill -0 "$(cat "$BABEL_PID")" 2>/dev/null
}

# $1: configuration statement for the running babeld; succeeds when it answers ok
babel_cmd() {
    printf '%s\nquit\n' "$1" | nc ::1 "$BABEL_PORT" 2>/dev/null |
        awk '$1 == "ok" {n++} $1 == "no" || $1 == "bad" {bad=1} END {exit !(n == 2 && !bad)}'
}

# $1: first peer interface
babel_start() {
    : > "$BABEL_PEERS"
    # A random router-id: a node that reboots is not ignored while the others still hold its old state
    babeld -r -S "$MESH_STATE_DIR/babel_state" -G "$BABEL_PORT" \
        -C 'default type wireless' \
        -C "install ip $NET_PREFIX.0.0/16 le 32 pref-src $NODE_IP" \
        -C "redistribute local ip $NODE_IP/32 allow" \
        -C 'redistribute local deny' \
        "$1" &
    echo $! > "$BABEL_PID"
}

# Rule appended after "-s <hotspot network>" in the NAT chain; the words are split on purpose
mesh_nat_rule() {
    echo "-d $NET_PREFIX.0.0/16 -j SNAT --to-source $NODE_IP"
}

# $1: peer interface, $2: its number
mesh_peer_attached() {
    babel_running && grep -qx "$1" "$BABEL_PEERS"
}

mesh_peer_up() {
    ip link set dev "$1" up || return 1
    if babel_running; then
        echo "Adding $1"
        babel_cmd "interface $1" || return 1
    else
        echo "Starting babeld on $1"
        babel_start "$1"
    fi
    echo "$1" >> "$BABEL_PEERS"
}

mesh_stop() {
    if babel_running; then
        kill "$(cat "$BABEL_PID")" 2>/dev/null || true
    fi
    if [ -f "$BABEL_ADDR" ]; then
        ip addr del "$(cat "$BABEL_ADDR")" dev lo 2>/dev/null || true
    fi
    rm -f "$BABEL_PEERS" "$BABEL_PID" "$BABEL_ADDR"
}

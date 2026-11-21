# Some Rights Reserved. 2026 Federico Pietro Briata
#
# Licensed under the GNU General Public License (GPL) version 2 or later
# and the 3-Clause BSD License.

# Sourced by hostapd-apup and apup-watchdog, not executed.

. @SYSCONFDIR@/hostapd-apup/hostapd-apup.conf

MESH_PROTO=${MESH_PROTO:-batman-iv}
MESH_STATE_DIR=/run/hostapd-apup
MESH_STATE_FILE=$MESH_STATE_DIR/mesh_proto

load_addresses() {
    PHY_MAC=$(cat "/sys/class/net/$WIFI_IF/address")
    if [ -z "${NODE_IP:-}" ]; then
        MAC5=$(printf '%s\n' "$PHY_MAC" | cut -d: -f5)
        MAC6=$(printf '%s\n' "$PHY_MAC" | cut -d: -f6)
        NODE_IP="$NET_PREFIX.$(printf '%d' "0x$MAC5").$(printf '%d' "0x$MAC6")"
    fi
}

# Optional hooks, a backend overrides them when it needs them
mesh_start() { :; }
mesh_info() { :; }

# The protocol that prepare started, so stop and the watchdog still follow it after the configuration changed
mesh_active_proto() {
    cat "$MESH_STATE_FILE" 2>/dev/null || echo "$MESH_PROTO"
}

mesh_load() {
    case "$1" in
        ''|*[!a-z0-9-]*)
            echo "Invalid MESH_PROTO: $1" >&2
            exit 1
            ;;
    esac
    if [ ! -f "@LIBEXECDIR@/hostapd-apup/mesh-$1.sh" ]; then
        echo "Unknown MESH_PROTO: $1" >&2
        exit 1
    fi
    . "@LIBEXECDIR@/hostapd-apup/mesh-$1.sh"
}

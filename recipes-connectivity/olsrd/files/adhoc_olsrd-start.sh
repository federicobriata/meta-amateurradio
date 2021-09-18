#!/bin/sh

ADHOC_INTERFACE=wlan0

echo "Prepare network interface.."
rfkill unblock wlan;
sleep 1;
ip link set ${ADHOC_INTERFACE} down;
sleep 1;
ip link set ${ADHOC_INTERFACE} up;
ifconfig ${ADHOC_INTERFACE} up;
echo "Done!
Create the Ad-hoc network"
iw dev ${ADHOC_INTERFACE} set type ibss;
iw dev ${ADHOC_INTERFACE} ibss join mesh 2437;
echo "Done!
Starting Mesh..."
sleep 1
echo "Done!
Generate and set a univocal ip addr based on MAC for adhoc net"
B=0x$(cat /sys/class/net/${ADHOC_INTERFACE}/address | cut -d : -f 4)
C=0x$(cat /sys/class/net/${ADHOC_INTERFACE}/address | cut -d : -f 5)
D=0x$(cat /sys/class/net/${ADHOC_INTERFACE}/address | cut -d : -f 6)
IP_ADDRESS=10.$((${B}+0)).$((${C}+0)).$((${D}+0))
ifconfig ${ADHOC_INTERFACE} $IP_ADDRESS netmask 255.0.0.0 broadcast 44.255.255.255
sleep 1
echo "Done!
The IP used in this node will be: $IP_ADDRESS
Starting Olsrd..."
/usr/sbin/olsrd
# OLSR needs port 698 to transmit state messages.
#iptables -A INPUT -p udp --dport 698 -j ACCEPT
#iptables -A INPUT -p tcp -m tcp --dport 2006 -j ACCEPT
# OLSR info need 8088 for http
#iptables -A INPUT -p tcp -m tcp --dport 8088 -j ACCEPT
echo "Ready to mesh!"

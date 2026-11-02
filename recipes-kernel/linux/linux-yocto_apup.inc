FILESEXTRAPATHS:prepend := "${THISDIR}/linux-yocto:"

SRC_URI += " \
    file://crypto.cfg \
    file://net-filter.cfg \
    file://wifi-base.cfg \
    file://wifi-usb.cfg \
"

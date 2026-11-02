FILESEXTRAPATHS:prepend := "${THISDIR}/linux-yocto:"

SRC_URI += " \
    file://crypto.cfg \
    file://wifi-base.cfg \
    file://wifi-usb.cfg \
"

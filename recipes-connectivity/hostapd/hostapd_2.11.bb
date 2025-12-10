SUMMARY = "User space daemon for extended IEEE 802.11 management"
HOMEPAGE = "http://w1.fi/hostapd/"
SECTION = "kernel/userland"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://hostapd/README;beginline=5;endline=47;md5=8e2c69e491b28390f9de0df1f64ebd6d"

DEPENDS = "libnl openssl"

SRC_URI = " \
    http://w1.fi/releases/hostapd-${PV}.tar.gz \
    file://0001-Include-base64-for-hostapd-CONFIG_SAE_PK-builds.patch \
    file://defconfig \
    file://init \
    file://hostapd.service \
    file://CVE-2025-24912-01.patch \
    file://CVE-2025-24912-02.patch \
    file://88463683e73cee8fab8a36c7f4832dbb455ddb7c.diff \
    file://711-wds_bridge_force.patch \
    file://6bb15f81e6857989c0b722fc1a49275492114148.diff \
"


SRC_URI[sha256sum] = "2b3facb632fd4f65e32f4bf82a76b4b72c501f995a4f62e330219fe7aed1747a"

inherit update-rc.d systemd pkgconfig features_check

CONFLICT_DISTRO_FEATURES = "openssl-no-weak-ciphers"

INITSCRIPT_NAME = "hostapd"

SYSTEMD_SERVICE:${PN} = "hostapd.service"
SYSTEMD_AUTO_ENABLE:${PN} = "disable"

do_configure:append() {
    install -m 0644 -D ${WORKDIR}/defconfig ${S}/hostapd/.config
}

do_compile() {
    export CFLAGS="-MMD -O2 -Wall -g"
    export EXTRA_CFLAGS="${CFLAGS}"
    make -C hostapd V=1
}

do_install() {
    install -d ${D}${sbindir} ${D}${sysconfdir}/init.d ${D}${systemd_unitdir}/system/
    install -m 0644 ${B}/hostapd/hostapd.conf ${D}${sysconfdir}
    install -m 0755 ${B}/hostapd/hostapd ${D}${sbindir}
    install -m 0755 ${B}/hostapd/hostapd_cli ${D}${sbindir}
    install -m 755 ${WORKDIR}/init ${D}${sysconfdir}/init.d/hostapd
    install -m 0644 ${WORKDIR}/hostapd.service ${D}${systemd_unitdir}/system/
    sed -i -e 's,@SBINDIR@,${sbindir},g' -e 's,@SYSCONFDIR@,${sysconfdir},g' ${D}${systemd_unitdir}/system/hostapd.service
}

CONFFILES:${PN} += "${sysconfdir}/hostapd.conf"

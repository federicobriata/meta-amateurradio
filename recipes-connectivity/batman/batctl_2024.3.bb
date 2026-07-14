DESCRIPTION = "Control application for B.A.T.M.A.N. routing protocol kernel module for multi-hop ad-hoc mesh networks."
HOMEPAGE = "http://www.open-mesh.net/"
SECTION = "console/network"
PRIORITY = "optional"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://LICENSES/preferred/GPL-2.0;md5=fc6177742f3ff0569ececd42b9b7d5fc"

DEPENDS = "libnl"

SRC_URI = "https://downloads.open-mesh.net/batman/stable/sources/${BPN}/${BPN}-${PV}.tar.gz"
SRC_URI[sha256sum] = "665e655eda381415218a4d5f5fd77ff33c4fa9b5edbb7e88e839096961e3600b"

inherit pkgconfig

RRECOMMENDS_${PN} = "kernel-module-batman-adv"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 batctl ${D}${bindir}
}

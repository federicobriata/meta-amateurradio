SUMMARY = "OLSR - Optimized Link State Routing daemon"
DESCRIPTION = "This service it's a routing adhoc application working on Layer 3."
HOMEPAGE = "http://www.olsr.org"
SECTION = "console/network"
PRIORITY = "optional"
LICENSE = "BSD-3-Clause"

LIC_FILES_CHKSUM = "file://license.txt;md5=39c3eae5373af35da1f6575a2e98cd08"

SRC_URI[md5sum] = "47d9ad3957b0808417b81c6eb6ce461e"
SRC_URI[sha256sum] = "326dbe083d4d39f1b4a4bcc2869e1a178a959332961952688ac3e03866ea7d6f"

DEPENDS = "bison-native"
RDEPENDS:${PN} += "bash"

SRCREV = "4973feb538b5b98b9d8ac2f8f474202f6d73de78"
PR = "r1"

SRCBRANCH = "master"
SRC_URI = "git://github.com/OLSR/olsrd.git;protocol=https;branch=${SRCBRANCH} \
        file://olsrd-adhoc-setup \
        file://olsrd.conf \
"

S = "${WORKDIR}/git"

inherit pkgconfig
#inherit autotools update-rc.d

EXTRA_OEMAKE = "MAKEFLAGS=-I${S} \
	NORPATH=1 \
	NO_DEBUG_MESSAGES=1 \
	OS="linux" \
	DESTDIR="${D}" \
	STRIP="true" \
	INSTALL_LIB="true" \
	SUBDIRS='arprefresh dyn_gw_plain nameservice txtinfo'"

do_configure() {
        oe_runmake clean
}

do_compile() {
        oe_runmake clean
        oe_runmake all libs
}

do_install () {
	oe_runmake INSTALL_PREFIX=${D} STRIP=echo install install_libs
	
	install -p -d ${D}/usr/lib
	install -m 0755 ${WORKDIR}/olsrd-adhoc-setup ${D}/usr/sbin
	install -m 644 ${WORKDIR}/olsrd.conf ${D}/${sysconfdir}/olsrd
}

FILES:${PN} = "${libdir}/${PN}_* /usr/sbin ${sysconfdir}"

CONFFILES:${PN} = "${sysconfdir}/olsrd/olsrd.conf"

SUMMARY = "OLSR - Optimized Link State Routing daemon"
DESCRIPTION = "This service it's a routing adhoc application working on Layer 3."
HOMEPAGE = "http://www.olsr.org"
SECTION = "console/network"
PRIORITY = "optional"
LICENSE = "BSD"

LIC_FILES_CHKSUM = "file://license.txt;md5=c67df89fe836b66cd7c17d3a6f7e2b02"

SRC_URI[md5sum] = "feabdd611391dcb30af5795e834cc258"
SRC_URI[sha256sum] = "692de2eb144f0be2e1dfc5dc5275b6c61b80af080e8f733e0b26b6a860442d27"

DEPENDS = "bison-native"
RDEPENDS_${PN} += "bash"

PV = "0.6.8"
PR = "r1"

SRC_URI = "http://bindist.wlan-si.net/mirror/olsrd-${PV}.tar.bz2 \
        file://olsrd-0.6.8-unbreak-makefile.patch;patch=0 \
        file://remove_the_redundant_rpath_linker_option.patch;patch=1 \
        file://adhoc_olsrd-start.sh \
        file://olsrd.conf \
"

S = "${WORKDIR}/olsrd-${PV}"

inherit pkgconfig
#inherit autotools update-rc.d

EXTRA_OEMAKE = "MAKEFLAGS=-I${S} \
	NORPATH=1 \
	NO_DEBUG_MESSAGES=1 \
	OS="linux" \
	DESTDIR="$(D)" \
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
	install -d ${D}/usr/bin
	install -m 0755 ${WORKDIR}/*.sh ${D}/usr/bin
	install -m 644 ${WORKDIR}/olsrd.conf ${D}/${sysconfdir}/olsrd
}

FILES_${PN} = "${libdir}/${PN}_* ${sysconfdir}/init.d /usr/sbin /usr/bin ${sysconfdir}"

CONFFILES_${PN} = "${sysconfdir}/olsrd/olsrd.conf"

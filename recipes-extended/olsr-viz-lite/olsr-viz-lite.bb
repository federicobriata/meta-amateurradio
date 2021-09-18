DESCRIPTION = "OLSRD Visualisation"
HOMEPAGE = "https://github.com/haxwithaxe/olsr-viz-lite"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://olsr-viz.js;md5=c06cbfbe15e3103fde8de57fe1828d02"

DEPENDS = "olsrd"
RDEPENDS_${PN} = "lighttpd lighttpd-module-cgi"

SRC_URI = "file://index.html \
	file://olsr-viz.js \
	file://olsr-viz.sh \
	file://dot_down.gif \
	file://dot_good.gif \
	file://dot_ok.gif \
	file://dot_weak.gif \
	file://node-hna-mini.gif \
	file://node-mini.gif \
	file://vizdata.sh \
	"

PR = "r1"
S = "${WORKDIR}"

do_install() {
		install -d ${D}/www
		install -d ${D}/www/pages
		install -d ${D}/www/pages
		install -d ${D}/www/pages/resources 
		install -d ${D}/www/pages/resources/olsr-viz
		install -m 0644 index.html ${D}/www/pages
		install -m 0755 *.sh ${D}/www/pages
		install -m 0644 olsr-viz.js ${D}/www/pages/resources
		install -m 0644 *.gif ${D}/www/pages/resources/olsr-viz
}

FILES_${PN} = "/www/*"

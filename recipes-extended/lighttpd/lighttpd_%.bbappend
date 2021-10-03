FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = "file://lighttpd.conf \
"

CONFFILES:${PN} = "${D}/lighttpd.conf"

do_install:append () {
    mv ${D}/www/pages/index.html ${D}/www/pages/index_old.html
}

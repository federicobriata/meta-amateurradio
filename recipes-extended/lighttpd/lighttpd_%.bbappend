FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI_append = "file://lighttpd.conf \
"

CONFFILES_${PN} = "${D}/lighttpd.conf"

do_install_append () {
    mv ${D}/www/pages/index.html ${D}/www/pages/index_old.html
}

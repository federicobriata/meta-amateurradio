DESCRIPTION = "B.A.T.M.A.N. advanced routing protocol kernel module for multi-hop ad-hoc mesh networks."
HOMEPAGE = "http://open-mesh.net"
SECTION = "kernel/modules"
PRIORITY = "optional"
LICENSE = "GPLv2"

inherit module

LIC_FILES_CHKSUM = "file://LICENSES/preferred/GPL-2.0;md5=fc6177742f3ff0569ececd42b9b7d5fc"

SRC_URI = "https://downloads.open-mesh.net/batman/stable/sources/${BPN}/${BPN}-${PV}.tar.gz"
SRC_URI[sha256sum] = "b96817ed1f4f48917c32550a84faad8c87ecf53aa6f6f46cc26554b999b57ff3"

EXTRA_OEMAKE = "KERNELPATH=${STAGING_KERNEL_BUILDDIR}"

do_install() {
    oe_runmake install DESTDIR=${D} INSTALL_MOD_PATH=${D} DEPMOD=echo

    if [ -d ${D}/lib ]; then
        install -d ${D}${nonarch_base_libdir}
        cp -r ${D}/lib/* ${D}${nonarch_base_libdir}/
        rm -rf ${D}/lib
    fi
}

FILES:${PN} += "${nonarch_base_libdir}/modules/${KERNEL_VERSION}/updates/net/batman-adv/batman-adv.ko"

RDEPENDS:${PN} += "kernel-module-batman-adv"
KERNEL_MODULE_AUTOLOAD += "batman-adv"

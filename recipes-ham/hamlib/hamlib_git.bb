SUMMARY = "Hamlib"

DESCRIPTION = "The Ham Radio Control Library-Hamlib, for short-is a project to \
provide programs with a consistent Application Programming Interface (API) for \
controlling the myriad of radios and rotators available to amateur radio and \
communications users."

HOMEPAGE = "https://hamlib.github.io/"
LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

# WSJT-X needs the forked version of hamlib instead of the main one
SRC_URI = "git://git.code.sf.net/u/bsomervi/hamlib;protocol=git;branch=integration \
          "

SRCREV = "6d52e85159f7caae0e5cb3010364a53a9b4108c0"

S = "${WORKDIR}/git"

inherit autotools

# WSJT-X requires the /usr/bin files from here to be available in the sysroot
SYSROOT_DIRS += "${bindir}"

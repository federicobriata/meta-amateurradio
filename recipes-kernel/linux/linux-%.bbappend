# any kernel recipe with fragment support, that sets LINUX_VERSION to one of the
# tested values, will get the appropriate fragments included in their SRC_URI

# The mac80211 APuP patch is needed from 6.x kernels on, while on 5.15 APuP
# works fine without it: linux-yocto_6.6_apup.inc adds it on top of the fragments.

LINUX_MAJOR = "${@(d.getVar('LINUX_VERSION') or "x.y").split('.')[0]}"
LINUX_MINOR = "${@(d.getVar('LINUX_VERSION') or "x.y").split('.')[1]}"

KERNEL_META_TYPE = "${@'yocto' if d.getVar('SRC_URI').find('type=kmeta') > 0 else 'none'}"

include ${@bb.utils.contains('DISTRO_FEATURES', 'apup', 'linux-${KERNEL_META_TYPE}_${LINUX_MAJOR}.${LINUX_MINOR}_apup.inc', '', d)}

# include the baseline APuP configuration options
# after this include, we can do version specific things

include linux-yocto_apup.inc

SRC_URI += "file://393-wifi-mac80211-allow-peer-bssid-block-ack-for-apup.patch"

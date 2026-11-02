DESCRIPTION = "Test image for APuP batman-adv mesh nodes"
LICENSE = "MIT"

inherit core-image

IMAGE_FEATURES += "\
	ssh-server-dropbear \
        splash \
	"

IMAGE_FEATURES:remove = "\
	tools-profile \
	tools-debug \
	tools-testapps \
	"

IMAGE_INSTALL += "\
	batctl \
	batman-adv \
	ca-certificates \
	dnsmasq \
	ethtool \
	hostapd \
	htop \
	iperf3 \
	iproute2 \
	iptables \
	iw \
	kernel-modules \
	linux-firmware-ath9k \
	linux-firmware-ralink \
	mtr \
	rng-tools \
	tcpdump \
	tzdata \
	wpa-supplicant \
	"


#!/usr/bin/env sh

DESTDIR=
BINDIR=/usr/bin
CONFDIR=/etc/all-ways-egpu

initServices() {
	# check if using systemd or openrc
	if [ -e "$(command -v systemctl)" ]; then
		cp systemd/all-ways-egpu.service "${DESTDIR}"${CONFDIR}
		cp systemd/all-ways-egpu-igpu.service "${DESTDIR}"${CONFDIR}
		cp systemd/all-ways-egpu-user.service "${DESTDIR}"${CONFDIR}
		cp systemd/all-ways-egpu-boot-vga.service "${DESTDIR}"${CONFDIR}
		cp systemd/all-ways-egpu-shutdown.service "${DESTDIR}"${CONFDIR}
		cp systemd/all-ways-egpu-set-compositor.service "${DESTDIR}"${CONFDIR}
		cp all-ways-egpu-reenable.desktop "${DESTDIR}"${CONFDIR}
	else
		if [ -e "$(command -v rc-status)" ]; then
			cp OpenRC/all-ways-egpu-openrc "${DESTDIR}"${CONFDIR}
			cp OpenRC/all-ways-egpu-boot-vga-openrc "${DESTDIR}"${CONFDIR}
			cp OpenRC/all-ways-egpu-set-compositor-openrc "${DESTDIR}"${CONFDIR}
		fi
	fi
}

install() {
	echo "Installing to system in directory ${DESTDIR}${BINDIR}"
	mkdir -p "${DESTDIR}"${BINDIR}
	cp all-ways-egpu "${DESTDIR}"${BINDIR}
	if [ ! -e "${DESTDIR}"${BINDIR}/all-ways-egpu-entry.sh ]; then
		cp all-ways-egpu-entry.sh "${DESTDIR}"${BINDIR}
	fi
	chmod +x "${DESTDIR}"${BINDIR}/all-ways-egpu
	chmod +x "${DESTDIR}"${BINDIR}/all-ways-egpu-entry.sh
	mkdir -p "${DESTDIR}"${CONFDIR}
	initServices
	cp all-ways-egpu.desktop "${DESTDIR}"/usr/share/applications
}

userInstall() {
	set -- "${DESTDIR}"/home/*
	for HD in "$@"; do
		mkdir -p "$HD"/bin
		if [ -x "$HD"/bin ]; then
			echo "Installing to user directory: $HD/bin"
			# Init services hard coded to first user path that is executable
			sed -i 's,=all-ways-egpu,='"$HD"'\/bin\/all-ways-egpu,' systemd/*.service
			sed -i 's,="all-ways-egpu",="'"$HD"'\/bin\/all-ways-egpu\",' OpenRC/*-openrc
			sed -i 's,\(^all-ways-egpu\),'"$HD"'\/bin\/all-ways-egpu,' all-ways-egpu-entry.sh
			cp all-ways-egpu "$HD"/bin
			if [ ! -e "$HD"/bin/all-ways-egpu-entry.sh ]; then
				cp all-ways-egpu-entry.sh "$HD"/bin
			fi
			chmod +x "$HD"/bin/all-ways-egpu
			chmod +x "$HD"/bin/all-ways-egpu-entry.sh
			if [ -e "$HD"/.local/share/applications ]; then
				cp all-ways-egpu.desktop "$HD"/.local/share/applications
			fi
			if [ -e "$HD"/.bashrc ]; then
				if ! cat "$HD"/.bashrc | grep -q PATH='.*$HOME/bin'; then echo 'export PATH="$HOME/bin:$PATH"' >> "$HD"/.bashrc; fi
			fi
		else
			echo "Skipping directory ""$HD"" that is not executable"
		fi
	done
	mkdir -p "${DESTDIR}"${CONFDIR}
	initServices
}

case $1 in
	install)
	install
		;;
	user-install)
	userInstall
		;;
	uninstall)
	all-ways-egpu uninstall
		;;
	*)
		# check for write permissions and install in user directory if /usr is not writable
		if [ -w /usr ]; then
			install
		else
			userInstall
		fi
		;;
esac

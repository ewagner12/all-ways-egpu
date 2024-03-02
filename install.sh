#!/usr/bin/env sh

DESTDIR=
BINDIR=/usr/bin
CONFDIR=/etc/all-ways-egpu

initServices() {
	# check if using systemd or openrc
	if [ -e "$(command -v systemctl)" ]; then
		cp systemd/all-ways-egpu.service "${DESTDIR}"${CONFDIR}
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

case $1 in
	install)
		mkdir -p "${DESTDIR}"${BINDIR}
		cp all-ways-egpu "${DESTDIR}"${BINDIR}
		chmod +x "${DESTDIR}"${BINDIR}/all-ways-egpu
		mkdir -p "${DESTDIR}"${CONFDIR}
		initServices
		cp all-ways-egpu.desktop "${DESTDIR}"/usr/share/applications
		;;

	user-install)
		set -- "${DESTDIR}"/home/*
		# Init services hard coded to first user path
		sed -i 's,=all-ways-egpu,='"$1"'\/bin\/all-ways-egpu,' systemd/*.service
		sed -i 's,="all-ways-egpu",="'"$1"'\/bin\/all-ways-egpu\",' OpenRC/*-openrc
		mkdir -p "${DESTDIR}"${CONFDIR}
		initServices
		for HD in "$@"; do
			mkdir -p "$HD"/bin
			cp all-ways-egpu "$HD"/bin
			chmod +x "$HD"/bin/all-ways-egpu
			if [ -e "$HD"/.local/share/applications ]; then
				cp all-ways-egpu.desktop "$HD"/.local/share/applications
			fi
			if [ -e "$HD"/.bashrc ]; then
				if ! cat "$HD"/.bashrc | grep -q PATH='.*$HOME/bin'; then echo 'export PATH="$HOME/bin:$PATH"' >> "$HD"/.bashrc; fi
			fi
		done
		;;

	uninstall)
		all-ways-egpu uninstall
		;;

esac

#!/usr/bin/env sh

DESTDIR=
BINDIR=/usr/bin
CONFDIR=/etc/all-ways-egpu

case $1 in
	install)
		mkdir -p "${DESTDIR}"${BINDIR}
		cp all-ways-egpu "${DESTDIR}"${BINDIR}
		chmod +x "${DESTDIR}"${BINDIR}/all-ways-egpu
		mkdir -p "${DESTDIR}"${CONFDIR}
		cp all-ways-egpu.service "${DESTDIR}"${CONFDIR}
		cp all-ways-egpu-user.service "${DESTDIR}"${CONFDIR}
		cp all-ways-egpu-boot-vga.service "${DESTDIR}"${CONFDIR}
		cp all-ways-egpu-shutdown.service "${DESTDIR}"${CONFDIR}
		cp all-ways-egpu-openrc "${DESTDIR}"${CONFDIR}
		cp all-ways-egpu-boot-vga-openrc "${DESTDIR}"${CONFDIR}
		cp all-ways-egpu-reenable.desktop "${DESTDIR}"${CONFDIR}
		cp all-ways-egpu.desktop "${DESTDIR}"/usr/share/applications
		;;

	user-install)
		set -- "${DESTDIR}"/home/*
		for HD in "$@"; do
			mkdir -p "$HD"/bin
			cp all-ways-egpu "$HD"/bin
			chmod +x "$HD"/bin/all-ways-egpu
			cp all-ways-egpu.desktop "$HD"/.local/share/applications
			echo 'export PATH="$HOME/bin:$PATH"' >> "$HD"/.bashrc
		done
#		./.bashrc
		;;

	uninstall)
		all-ways-egpu uninstall
		;;

esac

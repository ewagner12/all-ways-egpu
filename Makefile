BINDIR := /usr/bin
SYSDIR := /etc/systemd/system

all:

install:
	mkdir -p ${DESTDIR}${BINDIR}
	cp all-ways-egpu ${DESTDIR}${BINDIR}
	chmod +x ${DESTDIR}${BINDIR}/all-ways-egpu
	mkdir -p ${DESTDIR}${SYSDIR}
	cp all-ways-egpu.service ${DESTDIR}${SYSDIR}
	cp all-ways-egpu-user.service ${DESTDIR}${SYSDIR}
	mkdir -p ${DESTDIR}/usr/share/all-ways-egpu
	cp all-ways-egpu-reenable.desktop ${DESTDIR}/usr/share/all-ways-egpu

uninstall:
	${DESTDIR}${BINDIR}/all-ways-egpu internal
	systemctl disable all-ways-egpu.service
	rm -f ${DESTDIR}${BINDIR}/all-ways-egpu
	rm -f ${DESTDIR}${SYSDIR}/all-ways-egpu.service
	rm -f ${DESTDIR}${SYSDIR}/all-ways-egpu-user.service
	rm -rf ${DESTDIR}/usr/share/all-ways-egpu
	rm -f /home/*/.config/autostart/all-ways-egpu-reenable.desktop

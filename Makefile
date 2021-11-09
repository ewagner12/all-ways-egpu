BINDIR := /usr/bin
CONFDIR := /usr/share/all-ways-egpu

all:

install:
	mkdir -p ${DESTDIR}${BINDIR}
	cp all-ways-egpu ${DESTDIR}${BINDIR}
	chmod +x ${DESTDIR}${BINDIR}/all-ways-egpu
	mkdir -p ${DESTDIR}${CONFDIR}
	cp all-ways-egpu.service ${DESTDIR}${CONFDIR}
	cp all-ways-egpu-user.service ${DESTDIR}${CONFDIR}
	cp all-ways-egpu-boot-vga.service ${DESTDIR}${CONFDIR}
	cp all-ways-egpu-shutdown.service ${DESTDIR}${CONFDIR}
	cp all-ways-egpu-openrc ${DESTDIR}${CONFDIR}
	cp all-ways-egpu-boot-vga-openrc ${DESTDIR}${CONFDIR}
	cp all-ways-egpu-reenable.desktop ${DESTDIR}${CONFDIR}
	cp all-ways-egpu.desktop ${DESTDIR}/usr/share/applications

uninstall:
	${DESTDIR}${BINDIR}/all-ways-egpu uninstall

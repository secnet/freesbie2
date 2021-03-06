#
# Copyright (c) 2005 Dario Freni
#
# See COPYING for licence terms.
#
# $FreeBSD$
# $Id: Makefile,v 1.3 2008/05/05 20:51:04 sullrich Exp $
#
# FreeSBIE makefile. Main targets are:
#
# iso:		build an iso image
# img:		build a loopback image 
# flash:	copy the built system on a device (interactive)
# freesbie:	same of `iso'
#
# pkgselect:	choose packages to include in the built system (interactive)

.if defined(MAKEOBJDIRPREFIX)
CANONICALOBJDIR:=${MAKEOBJDIRPREFIX}${.CURDIR}
.elif defined(MAKEOBJDIR)
CANONICALOBJDIR:=${MAKEOBJDIR}
.else
CANONICALOBJDIR:=/usr/obj${.CURDIR}
.endif

.if defined(CUSTOM_MAKEOBJDIRPREFIX)
PRE_LAUNCH=env MAKEOBJDIRPREFIX=${CUSTOM_MAKEOBJDIRPREFIX}
.endif

.if ${FREEBSD_VERSION} < 9
pkgtarget=pkginstall
.else
pkgtarget=pkgnginstall
.endif

all: freesbie

freesbie: iso

pkgselect: obj
	@sh ${.CURDIR}/scripts/launch.sh ${.CURDIR} pkgselect

obj: .done_objdir
.done_objdir:
	@if ! test -d ${CANONICALOBJDIR}/; then \
		mkdir -p ${CANONICALOBJDIR}; \
		if ! test -d ${CANONICALOBJDIR}/; then \
			${ECHO} ">>> Unable to create ${CANONICALOBJDIR}."; \
			exit 1; \
		fi; \
	fi
	@${ECHO} ">>> Setting CANONICALOBJDIR to ${CANONICALOBJDIR}."
	@if ! test -f ${CANONICALOBJDIR}/.done_objdir; then \
		touch ${CANONICALOBJDIR}/.done_objdir; \
	fi

buildworld: .done_buildworld
.done_buildworld: .done_objdir
	@-rm -f ${CANONICALOBJDIR}/.tmp_buildworld
	@touch ${CANONICALOBJDIR}/.tmp_buildworld
	@${ECHO} ">>> Starting buildworld."
	@${PRE_LAUNCH} sh ${.CURDIR}/scripts/launch.sh ${.CURDIR} buildworld ${CANONICALOBJDIR}/.tmp_buildworld
	@${ECHO} ">>> Finished buildworld."
	@mv ${CANONICALOBJDIR}/.tmp_buildworld ${CANONICALOBJDIR}/.done_buildworld

installworld: .done_installworld
.done_installworld: .done_buildworld
	@-rm -f ${CANONICALOBJDIR}/.tmp_installworld
	@touch ${CANONICALOBJDIR}/.tmp_installworld
	@${ECHO} ">>> Starting installworld."
	@${PRE_LAUNCH} sh ${.CURDIR}/scripts/launch.sh ${.CURDIR} installworld ${CANONICALOBJDIR}/.tmp_installworld
	@${ECHO} ">>> Finished installworld."
	@mv ${CANONICALOBJDIR}/.tmp_installworld ${CANONICALOBJDIR}/.done_installworld

buildkernel: .done_buildkernel
.done_buildkernel: .done_buildworld
	@-rm -f ${CANONICALOBJDIR}/.tmp_buildkernel
	@touch ${CANONICALOBJDIR}/.tmp_buildkernel
	@${PRE_LAUNCH} sh ${.CURDIR}/scripts/launch.sh ${.CURDIR} buildkernel ${CANONICALOBJDIR}/.tmp_buildkernel
	@mv ${CANONICALOBJDIR}/.tmp_buildkernel ${CANONICALOBJDIR}/.done_buildkernel

installkernel: .done_installkernel
.done_installkernel: .done_buildkernel .done_installworld
	@-rm -f ${CANONICALOBJDIR}/.tmp_installkernel
	@touch ${CANONICALOBJDIR}/.tmp_installkernel
	@${PRE_LAUNCH} sh ${.CURDIR}/scripts/launch.sh ${.CURDIR} installkernel ${CANONICALOBJDIR}/.tmp_installkernel
	@mv ${CANONICALOBJDIR}/.tmp_installkernel ${CANONICALOBJDIR}/.done_installkernel

pkginstall: .done_pkginstall
.done_pkginstall: .done_installworld
	@-rm -f ${CANONICALOBJDIR}/.tmp_pkginstall
	@touch ${CANONICALOBJDIR}/.tmp_pkginstall
	@sh ${.CURDIR}/scripts/launch.sh ${.CURDIR} pkginstall ${CANONICALOBJDIR}/.tmp_pkginstall
	@mv ${CANONICALOBJDIR}/.tmp_pkginstall ${CANONICALOBJDIR}/.done_pkginstall

pkgnginstall: .done_pkgnginstall
.done_pkgnginstall: .done_installworld
	@-rm -f ${CANONICALOBJDIR}/.tmp_pkgnginstall
	@touch ${CANONICALOBJDIR}/.tmp_pkgnginstall
	@${ECHO} ">>> Started pkgnginstall."
	@sh ${.CURDIR}/scripts/launch.sh ${.CURDIR} pkgnginstall ${CANONICALOBJDIR}/.tmp_pkgnginstall
	@${ECHO} ">>> Finished pkgnginstall."
	@mv ${CANONICALOBJDIR}/.tmp_pkgnginstall ${CANONICALOBJDIR}/.done_pkgnginstall

extra:	.done_extra
.done_extra: .done_installworld
	@-rm -f ${CANONICALOBJDIR}/.tmp_extra
	@touch ${CANONICALOBJDIR}/.tmp_extra
	@sh ${.CURDIR}/scripts/launch.sh ${.CURDIR} extra ${CANONICALOBJDIR}/.tmp_extra
	@mv ${CANONICALOBJDIR}/.tmp_extra ${CANONICALOBJDIR}/.done_extra

clonefs: .done_clonefs
.done_clonefs: ${pkgtarget} .done_extra
	@-rm -f ${CANONICALOBJDIR}/.tmp_clonefs
	@touch ${CANONICALOBJDIR}/.tmp_clonefs
	@sh ${.CURDIR}/scripts/launch.sh ${.CURDIR} clonefs ${CANONICALOBJDIR}/.tmp_clonefs
	@mv ${CANONICALOBJDIR}/.tmp_clonefs ${CANONICALOBJDIR}/.done_clonefs

compressfs:
	@sh ${.CURDIR}/scripts/launch.sh ${.CURDIR} compressfs ${CANONICALOBJDIR}/.tmp_extra

iso: .done_iso
.done_iso: .done_clonefs
	@-rm -f ${CANONICALOBJDIR}/.tmp_iso
	@touch ${CANONICALOBJDIR}/.tmp_iso
	@sh ${.CURDIR}/scripts/launch.sh ${.CURDIR} iso ${CANONICALOBJDIR}/.tmp_iso
	@mv ${CANONICALOBJDIR}/.tmp_iso ${CANONICALOBJDIR}/.done_iso

img: .done_img
.done_img: .done_clonefs
	@-rm -f ${CANONICALOBJDIR}/.tmp_img
	@touch ${CANONICALOBJDIR}/.tmp_img
	@sh ${.CURDIR}/scripts/launch.sh ${.CURDIR} img ${CANONICALOBJDIR}/.tmp_img
	@mv ${CANONICALOBJDIR}/.tmp_img ${CANONICALOBJDIR}/.done_img

flash: .done_flash
.done_flash: .done_clonefs
	@-rm -f ${CANONICALOBJDIR}/.tmp_flash
	@touch ${CANONICALOBJDIR}/.tmp_flash
	@sh ${.CURDIR}/scripts/launch.sh ${.CURDIR} flash ${CANONICALOBJDIR}/.tmp_flash
	@mv ${CANONICALOBJDIR}/.tmp_flash ${CANONICALOBJDIR}/.done_flash

clean:
	@-rm -f .tmp* .done* > /dev/null 2>&1

cleandir: clean
	@sh ${.CURDIR}/scripts/launch.sh ${.CURDIR} cleandir

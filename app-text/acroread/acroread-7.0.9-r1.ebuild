# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/app-text/acroread/Attic/acroread-7.0.9-r1.ebuild,v 1.7 2008/03/07 20:57:51 tgurr dead $

inherit eutils nsplugins

DESCRIPTION="Adobe's PDF reader"
HOMEPAGE="http://www.adobe.com/products/acrobat/"
IUSE="cups ldap nsplugin"

SRC_HEAD="http://ardownload.adobe.com/pub/adobe/reader/unix/7x/${PV}"
SRC_FOOT="-${PV}-1.i386.tar.gz"

#LINGUA_LIST="en:enu de:deu fr:fra sv:sve es:esp pt:ptb nb:nor it:ita fi:suo nl:nld da:dan ja:jpn ko:kor zh_CN:chs zh_TW:cht"
LINGUA_LIST="en:enu"
SRC_URI=
DEFAULT_URI="${SRC_HEAD}/enu/AdobeReader_enu${SRC_FOOT}"
for ll in ${LINGUA_LIST}; do
	iuse_l="linguas_${ll/:*}"
	src_l=${ll/*:}
	IUSE="${IUSE} ${iuse_l}"
	DEFAULT_URI="!${iuse_l}? ( ${DEFAULT_URI} )"
	SRC_URI="${SRC_URI}
		${iuse_l}? ( ${SRC_HEAD}/${src_l}/AdobeReader_${src_l}${SRC_FOOT} )"
done
SRC_URI="${SRC_URI}
	${DEFAULT_URI}
	x86? ( !cups? ( mirror://gentoo/libcups.so-i386.bz2 ) )"

LICENSE="Adobe"
SLOT="0"
KEYWORDS="-* amd64 x86"
RESTRICT="strip mirror"

RDEPEND="x86? ( >=x11-libs/gtk+-2.0
			cups? ( net-print/cups )
			ldap? ( net-nds/openldap ) )
	amd64? ( >=app-emulation/emul-linux-x86-baselibs-2.4.2
			>=app-emulation/emul-linux-x86-gtklibs-2.0 )"
QA_TEXTRELS="opt/Acrobat7/Reader/intellinux/lib/libCoolType.so.5.01
	opt/Acrobat7/Reader/intellinux/lib/libcrypto.so.0.9.6
	opt/Acrobat7/Reader/intellinux/lib/libJP2K.so
	opt/Acrobat7/Reader/intellinux/lib/libAXSLE.so
	opt/Acrobat7/Reader/intellinux/lib/librt3d.so
	opt/Acrobat7/Reader/intellinux/SPPlugins/ADMPlugin.apl
	opt/Acrobat7/Reader/intellinux/plug_ins3d/tesselate.x3d
	opt/Acrobat7/Reader/intellinux/plug_ins3d/drvSOFT.x3d
	opt/Acrobat7/Reader/intellinux/plug_ins3d/3difr.x3d
	opt/Acrobat7/Reader/intellinux/plug_ins3d/drvOpenGL.x3d
	opt/Acrobat7/Reader/intellinux/plug_ins3d/2d.x3d
	opt/Acrobat7/Reader/intellinux/plug_ins/checkers.api
	opt/Acrobat7/Reader/intellinux/plug_ins/EFS.api
	opt/Acrobat7/Reader/intellinux/plug_ins/MakeAccessible.api
	opt/Acrobat7/Reader/intellinux/plug_ins/DigSig.api
	opt/Acrobat7/Reader/intellinux/plug_ins/wwwlink.api
	opt/Acrobat7/Reader/intellinux/plug_ins/SaveAsRTF.api
	opt/Acrobat7/Reader/intellinux/plug_ins/PPKLite.api
	opt/Acrobat7/Reader/intellinux/plug_ins/ewh.api
	opt/Acrobat7/Reader/intellinux/plug_ins/PDDom.api
	opt/Acrobat7/Reader/intellinux/plug_ins/SOAP.api
	opt/Acrobat7/Reader/intellinux/plug_ins/SendMail.api
	opt/Acrobat7/Reader/intellinux/plug_ins/Annots.api
	opt/Acrobat7/Reader/intellinux/plug_ins/SearchFind.api
	opt/Acrobat7/Reader/intellinux/plug_ins/Spelling.api
	opt/Acrobat7/Reader/intellinux/plug_ins/Accessibility.api
	opt/Acrobat7/Reader/intellinux/plug_ins/EScript.api
	opt/Acrobat7/Reader/intellinux/plug_ins/AcroForm.api
	opt/netscape/plugins/nppdf.so
	opt/Acrobat7/Reader/intellinux/sidecars/RdLang32*"

INSTALLDIR=/opt/Acrobat7

S=${WORKDIR}/AdobeReader

pkg_setup() {
	# x86 binary package, ABI=x86
	# Danny van Dyk <kugelfang@gentoo.org> 2005/03/25
	has_multilib_profile && ABI="x86"
}

# Determine lingua from filename
acroread_get_ll() {
	local f_src_l ll lingua src_l
	f_src_l=${1/${SRC_FOOT}}
	f_src_l=${f_src_l/*_}
	for ll in ${LINGUA_LIST}; do
		lingua=${ll/:*}
		src_l=${ll/*:}
		if [[ ${src_l} == ${f_src_l} ]]; then
			echo ${lingua}
			return
		fi
	done
	die "Failed to match file $1 to a LINGUA; please report"
}

src_unpack() {
	local ll linguas fl
	# Unpack all into the same place; overwrite common files.
	fl=""
	for pkg in ${A}; do
		cd ${WORKDIR}
		unpack ${pkg}
		cd ${S}
		# Note; bash-3.2_p9 doesn't like quotes on the rhs of =~
		# Seems inconsistent to me; this works for now, awaiting
		# upstream response.
		if [[ ${pkg} =~ ^AdobeReader_ ]]; then
			tar xf ILINXR.TAR ||
				die "Failed to unpack ILINXR.TAR; is distfile corrupt?"
			tar xf COMMON.TAR ||
				die "Failed to unpack COMMON.TAR; is distfile corrupt?"
			epatch ${FILESDIR}/acroread-scim.patch
			epatch ${FILESDIR}/acroread-low-startup-fontissue.patch
			epatch ${FILESDIR}/acroread-expr.patch
			ll=$(acroread_get_ll ${pkg})
			mv bin/acroread bin/acroread.${ll}
			if [[ -z ${fl} ]]; then
				fl=${ll}
				linguas="${ll}"
			else
				linguas="${linguas} ${ll}"
			fi
		fi
	done
	if [[ ${linguas} == ${fl} ]]; then
		# Only one lingua selected - skip building the wrapper
		mv bin/acroread.${fl} bin/acroread ||
			die "Failed to put acroread.${fl} back to acroread; please report"
	else
		# Build wrapper.  Launch the acroread for the environment variable
		# LANG (matched with a trailing * so that for example 'de_DE' matches
		# 'de', 'en_GB' matches 'en' etc).
		cat > bin/acroread <<-EOF
			#!/bin/bash
			# Copyright 1999-2007 Gentoo Foundation
			# Distributed under the terms of the GNU General Public License v2
			#
			# Automatically generated by ${CATEGORY}/${PF}

			# Exec the acroread script for the language chosen in
			# LC_ALL/LC_MESSAGES/LANG (first found takes precedence, as in glibc)
			L=\${LC_ALL}
			L=\${L:-\${LC_MESSAGES}}
			L=\${L:-\${LANG}}
			case \${L} in
		EOF
		for ll in ${linguas}; do
			echo "${ll}*) exec ${INSTALLDIR}/acroread.${ll} \"\$@\";;" >> bin/acroread
		done
		# default to English (in particualr for LANG=C)
		cat >> bin/acroread <<-EOF
			*) exec ${INSTALLDIR}/acroread.${fl} "\$@";;
			esac
		EOF
		chmod 755 bin/acroread
	fi
}

src_install() {
	local i

	cp Resource/Support/AdobeReader_KDE.desktop AdobeReader.desktop
	domenu AdobeReader.desktop
	doicon Resource/Icons/AdobeReader.png

	dodir ${INSTALLDIR}
	DIRS="Reader Resource"
	for i in ${DIRS}
	do
		if [ -d ${i} ] ; then
			chown -R --dereference -L root:0 ${i}
			mv ${i} ${D}${INSTALLDIR}
		fi
	done

	exeinto ${INSTALLDIR}
	for exe in bin/acroread*; do
		doexe ${exe} || die "doexe failed"
	done
	# The Browser_Plugin_HowTo.txt is now in a subdirectory, which
	# is named according to the language the user is using.
	# Ie. for German, it is in a DEU directory.	See bug #118015
	#dodoc Browser/${LANG_TAG}/Browser_Plugin_HowTo.txt
	dodoc Browser/HowTo/*/Browser_Plugin_HowTo.txt

	if use nsplugin ; then
		exeinto /opt/netscape/plugins
		doexe Browser/intellinux/nppdf.so
		inst_plugin /opt/netscape/plugins/nppdf.so
	fi

	if ! use ldap ; then
		rm ${D}${INSTALLDIR}/Reader/intellinux/plug_ins/PPKLite.api
	fi

	# libcups is needed for printing support (bug 118417)
	if use x86 && ! use cups ; then
		mv ${WORKDIR}/libcups.so-i386 ${WORKDIR}/libcups.so.2
		exeinto ${INSTALLDIR}/Reader/intellinux/lib
		doexe ${WORKDIR}/libcups.so.2
		dosym libcups.so.2 ${INSTALLDIR}/Reader/intellinux/lib/libcups.so
	fi

	dodir /opt/bin
	dosym ${INSTALLDIR}/acroread /opt/bin/acroread

	# fix wrong directory permissions (bug #25931)
	find ${D}${INSTALLDIR}/. -type d | xargs chmod 755 || die
}

pkg_postinst () {
	local ll lc
	use ldap ||
		elog "The Acrobat(TM) Security Plugin can be enabled with USE=ldap"
	use nsplugin ||
		elog "The Acrobat(TM) Browser Plugin can be enabled with USE=nsplugin"
	lc=0
	for ll in ${LINGUA_LIST}; do
		use linguas_${ll/:*} && (( lc = ${lc} + 1 ))
	done
	if [[ ${lc} > 1 ]]; then
		elog "Multiple languages have been installed, selected via a wrapper script."
		elog "The language is selected according to the LANG environment variable"
		elog "(defaulting to English if LANG is not set, or no matching language"
		elog "version is installed).  Users may need to remove their preferences in"
		elog "~/.adobe to switch languages."
	fi
}

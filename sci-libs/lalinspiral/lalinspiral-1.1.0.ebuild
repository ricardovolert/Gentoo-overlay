# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils

DESCRIPTION="Binary-inspiral package of the LIGO/Virgo libraries"
HOMEPAGE="https://www.lsc-group.phys.uwm.edu/daswg/projects/lalsuite.html"
SRC_URI="https://www.lsc-group.phys.uwm.edu/daswg/download/software/source/lalsuite/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
		sci-libs/libframe
		sci-libs/metaio
		sci-libs/lalframe
		sci-libs/lalmetaio
		sci-libs/lal
		sci-libs/lalsimulation
		sci-libs/fftw
		sci-libs/gsl
		sys-libs/zlib
	"
RDEPEND=${DEPEND}

src_prepare() {
	# Fix call to __builtin___snprintf_chk will always overflow destination buffer errors:
	epatch "${FILESDIR}/${P}-NRWaveInject.patch"
}

pkg_postinst() {
	elog "\n    Now you may want to setup your environment:"
	elog "\n    Bourne shell [bash] users: please add the following line to your .profile file:"
	elog "\n        . /etc/lalinspiral-user-env.sh"
	elog "\n    C-shell [tcsh] users: please add the following line to your .login file:"
	elog "\n        source /etc/lalinspiral-user-env.csh"
	elog ""
}

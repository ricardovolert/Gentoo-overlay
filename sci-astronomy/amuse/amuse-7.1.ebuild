# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit fortran-2

DESCRIPTION="AMUSE is an Astrophysical Multipurpose Software Environment"
HOMEPAGE="http://amusecode.org"
SRC_URI="http://www.amusecode.org/releases/${P}.tar.gz"
MERGE_TYPE="buildonly"

LICENSE="other"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="mesa mocassin mpiamrvac pynbody"

RDEPEND=">=dev-lang/python-2.6
		>=dev-python/mpi4py-1.0
		>=dev-python/numpy-1.3.0
		>=sci-libs/hdf5-1.6.5
		>=dev-python/h5py-1.2.0
		|| ( sys-cluster/mpich2  sys-cluster/openmpi )
		dev-python/nose
		dev-python/docutils
		>=sci-libs/fftw-3.0
		sci-libs/gsl
		>=dev-libs/gmp-4.2.1
		>=dev-libs/mpfr-2.3.1
		sys-devel/gcc[cxx]
		virtual/fortran"
DEPEND="${RDEPEND}
		>=dev-util/cmake-2.4
	   "

src_compile() {
	emake

	# USE-flag dependent make:
	use mesa       && emake mesa.code       DOWNLOAD_CODES=1
	use mocassin   && emake mocassin.code   DOWNLOAD_CODES=1
	use mpiamrvac  && emake mpiamrvac.code  DOWNLOAD_CODES=1
	use pynbody    && emake pynbody.code    DOWNLOAD_CODES=1
}

#src_install() {
#   return
#   #emake DESTDIR="${D}" install
#}

# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

AUTOTOOLS_AUTORECONF=1

inherit git-r3 autotools-utils

DESCRIPTION="VPNs on steroids"
HOMEPAGE="http://kronosnet.org/"
EGIT_REPO_URI="https://github.com/fabbione/kronosnet.git"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

REQUIRED_USE=""

COMMON_DEPEND="
"

DEPEND="
	${COMMON_DEPEND}
"

RDEPEND="
	${COMMON_DEPEND}
"

DOCS=(README)

src_prepare() {
	autotools-utils_src_prepare
}

src_configure() {
	autotools-utils_src_configure
}

src_compile() {
	autotools-utils_src_compile
}

src_install() {
	autotools-utils_src_install
}

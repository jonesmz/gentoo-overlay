EAPI=5

AUTOTOOLS_AUTORECONF=1

inherit git-r3 autotools-utils user systemd

DESCRIPTION="Open Source client/server backup system"
HOMEPAGE="https://www.urbackup.org"
#SRC_URI=""
EGIT_REPO_URI="https://github.com/uroni/urbackup_backend.git"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

REQUIRED_USE=""

COMMON_DEPEND="
	dev-libs/crypto++
"

DEPEND="
	${COMMON_DEPEND}
"

RDEPEND="
	${COMMON_DEPEND}
"

DOCS=(README)

src_prepare() {
#	python3 build/replace_versions.py
	cp defaults_server		defaults
	cp copy_cond init.d_server	init.d

	cp Makefile.am_server		Makefile.am
	cp configure.ac_server		configure.ac

	sed -i "s/BUILDID/0/g" configure.ac

	sed -i "s/adduser/true || adduser/g" Makefile.am
	sed -i "s/install-data-local:.*/install-data-local:/g" Makefile.am

	autotools-utils_src_prepare
}

src_configure() {
	autotools-utils_src_configure
	cp ${S}_build/config.h .
}

src_compile() {
	autotools-utils_src_compile
}

src_install() {
	autotools-utils_src_install
	systemd_dounit urbackup-server.service
}

pkg_setup() {
	enewgroup urbackup
	enewuser urbackup -1 -1 "${ROOT}/var/lib/urbackup/" "urbackup"
}

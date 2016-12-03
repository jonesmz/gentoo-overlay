EAPI="5"

inherit git-r3 qmake-utils

DESCRIPTION="Implementation of the Aerosta Engine"
HOMEPAGE="https://jonesmz@bitbucket.org/aerostallc/"
#SRC_URI="https://jonesmz@bitbucket.org/aerostallc/aerosta-engine.git"
EGIT_REPO_URI="https://jonesmz@bitbucket.org/aerostallc/aerosta-engine.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

REQUIRED_USE=""

COMMON_DEPEND="
	dev-qt/qtcore:5
	net-libs/keyvalbroadcast
	net-dns/qtzeroconf
	sys-cluster/corosync
"

DEPEND="
	${COMMON_DEPEND}
"

RDEPEND="
	${COMMON_DEPEND}
"

src_configure() {
	eqmake5 aerosta-engine.pro
}

src_install() {
	dobin bin/aerosta-engine*
}



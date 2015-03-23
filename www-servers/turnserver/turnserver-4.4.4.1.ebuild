# Distributed under the terms of the GNU General Public License v2

EAPI="5"
inherit base eutils systemd

DESCRIPTION="High-performance free open source TURN and STUN Server implementation."
HOMEPAGE="https://code.google.com/p/rfc5766-turn-server/"
SRC_URI="http://turnserver.open-sys.org/downloads/v${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="ssl"

RDEPEND="
	dev-libs/libevent[ssl?]
	ssl? ( dev-libs/openssl )"
DEPEND="${RDEPEND}"

src_configure() {
	econf
}

src_compile() {
	emake
}

src_install() {
	emake DESTDIR="${D}" MORECMD="cat" install
	dodoc AUTHORS README.*

	#systemd
        systemd_dounit "${FILESDIR}"/${PN}.service
}

# Copyright 2026 Michael Jones
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )

inherit python-single-r1 systemd

DESCRIPTION="Dispatcher daemon for systemd-networkd connection status changes"
HOMEPAGE="https://gitlab.com/craftyguy/networkd-dispatcher"
SRC_URI="https://gitlab.com/craftyguy/${PN}/-/archive/${PV}/${P}.tar.bz2"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="doc wifi"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	')
	sys-apps/systemd
	wifi? ( net-wireless/iw )
"
DEPEND="${RDEPEND}"
BDEPEND="doc? ( app-text/asciidoc )"

src_compile() {
	# The only build artifact is the optional manpage, produced from
	# networkd-dispatcher.txt via a2x (asciidoc).
	if use doc; then
		emake networkd-dispatcher.8
	fi
}

src_install() {
	# Main daemon script; installs to /usr/bin, matching ExecStart in the
	# systemd unit. python_doexe byte-compiles/handles the interpreter.
	python_doexe networkd-dispatcher

	# systemd service and its EnvironmentFile.
	systemd_dounit "${PN}.service"
	newconfd "${PN}.conf" "${PN}.conf"

	# State directories that dispatcher scans. /etc for local overrides,
	# /usr/lib for package-provided scripts. Create the full set upstream
	# documents so hooks can be dropped in without mkdir.
	local state
	for state in routable dormant no-carrier off carrier degraded \
			configuring configured; do
		keepdir "/etc/networkd-dispatcher/${state}.d"
		keepdir "/usr/lib/networkd-dispatcher/${state}.d"
	done

	dodoc README.md
	use doc && doman networkd-dispatcher.8
}

pkg_postinst() {
	elog "Enable and start the dispatcher with:"
	elog "  systemctl enable --now networkd-dispatcher.service"
	elog
	elog "Drop executable, root-owned scripts into the state directories under"
	elog "  /etc/networkd-dispatcher/<state>.d/   (local)"
	elog "  /usr/lib/networkd-dispatcher/<state>.d/ (packages)"
	elog "where <state> is one of: routable dormant no-carrier off carrier"
	elog "degraded configuring configured."
	elog
	elog "Command-line options can be set via networkd_dispatcher_args in"
	elog "  /etc/conf.d/networkd-dispatcher.conf"
}

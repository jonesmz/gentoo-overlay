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
KEYWORDS="amd64 arm arm64 x86"
IUSE="doc wifi"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# sys-apps/systemd provides networkd (the daemon we dispatch for) and the
# waiter units referenced by our ordering drop-in:
#   systemd-networkd-wait-online.service (gates network-online.target) and
#   systemd-time-wait-sync.service       (gates time-sync.target).
# The binaries always ship with systemd; those units must be ENABLED by the
# admin for the ordering to take effect (see pkg_postinst).
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

PATCHES=(
	# Skip non-executable files in state directories silently instead of
	# logging an error per file. Lets Portage's keepdir .keep markers (and
	# editor swap/backup files, READMEs, etc.) coexist with real hooks
	# without spamming the journal on every networkd state transition.
	"${FILESDIR}/${P}-skip-nonexecutable-files.patch"
)

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
	# Ship our own conf.d instead of upstream's empty one so that
	# --run-startup-triggers is enabled by default (see files/*.conf).
	newconfd "${FILESDIR}/${PN}.conf" "${PN}.conf"

	# Drop-in ordering the dispatcher after the network is usable, so that
	# startup-trigger hooks have a routable link, name resolution, and a
	# synced clock. See files/10-network-online.conf.
	systemd_install_dropin "${PN}.service" "${FILESDIR}/10-network-online.conf"

	# State directories that dispatcher scans. /etc for local overrides,
	# /usr/lib for package-provided scripts. Create the full set upstream
	# documents so hooks can be dropped in without mkdir. The keepdir .keep
	# markers are harmless here because the skip-nonexecutable-files patch
	# makes dispatcher ignore non-executable entries silently.
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
	elog
	elog "This overlay enables --run-startup-triggers by default in that file,"
	elog "so hooks also fire for links already in their operational state when"
	elog "the dispatcher starts (at boot, or after restarting systemd-networkd),"
	elog "not only on a later state transition. Remove the flag there to revert"
	elog "to upstream behaviour. Existing installs keep their current conf.d;"
	elog "merge the new default with etc-update/dispatch-conf to pick it up."
	elog
	elog "A drop-in (10-network-online.conf) orders the dispatcher after"
	elog "network-online.target, systemd-resolved, nss-lookup and time-sync so"
	elog "startup-trigger hooks run once the network is usable."
	elog
	elog "IMPORTANT: those targets are hollow unless their waiter services are"
	elog "enabled. network-online.target is reached immediately, and"
	elog "time-sync.target likewise, if nothing gates them -- so the ordering"
	elog "above has NO effect until you enable BOTH:"
	elog "  systemctl enable systemd-networkd-wait-online.service"
	elog "  systemctl enable systemd-time-wait-sync.service"
	elog "The first makes network-online.target wait for a routable link with"
	elog "addresses (past DHCP/DNS); the second makes time-sync.target wait for"
	elog "the clock to sync (needed by Kerberos-based hooks)."
	elog
	elog "Even with both enabled, hooks contacting remote services should still"
	elog "tolerate transient boot-time failures (e.g. the retry loop in"
	elog "net-dns/samba-ad-dns-register)."
}

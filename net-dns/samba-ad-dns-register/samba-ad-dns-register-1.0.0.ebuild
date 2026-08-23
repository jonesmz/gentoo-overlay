# Copyright 2026 Michael Jones
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="networkd-dispatcher hook to register a host's records in Samba AD DNS"
HOMEPAGE="https://github.com/jonesmz/gentoo-overlay"

# No upstream tarball; all content ships in files/.
S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm arm64 x86"

# net-misc/networkd-dispatcher provides /etc/networkd-dispatcher/routable.d
# net-fs/samba provides the `net` binary used by the hook
# app-admin/sysklogd or any syslog provides logger via sys-apps/util-linux
RDEPEND="
	net-misc/networkd-dispatcher
	net-fs/samba
	sys-apps/util-linux
"

src_install() {
	# The routable.d hook must be executable.
	exeinto /etc/networkd-dispatcher/routable.d
	newexe "${FILESDIR}"/50-samba-ad-dns-register 50-samba-ad-dns-register

	# Optional configuration sourced by the hook.
	newconfd "${FILESDIR}"/samba-ad-dns-register.confd samba-ad-dns-register
}

pkg_postinst() {
	elog "This package installed a networkd-dispatcher hook at:"
	elog "  /etc/networkd-dispatcher/routable.d/50-samba-ad-dns-register"
	elog
	elog "It runs 'net ads dns register --machine-pass' whenever an interface"
	elog "becomes routable, keeping this host's A/AAAA records current in the"
	elog "Samba Active Directory DNS zone."
	elog
	elog "Requirements:"
	elog "  - This host must be joined to the AD domain (net ads join) with a"
	elog "    valid machine account in secrets.tdb."
	elog "  - networkd-dispatcher.service must be enabled and running:"
	elog "      systemctl enable --now networkd-dispatcher.service"
	elog "  - Working Kerberos (clock in sync with the DCs, DCs resolvable)."
	elog
	elog "Optional configuration: /etc/conf.d/samba-ad-dns-register"
	elog "  Restrict to specific interfaces with SAMBA_AD_DNS_REGISTER_IFACES,"
	elog "  or disable with SAMBA_AD_DNS_REGISTER_ENABLE=\"no\"."
	elog
	elog "For stable-IP infrastructure hosts, a static record added on a DC"
	elog "  (samba-tool dns add <dc> <zone> <name> A <ip>) is more robust than"
	elog "  this self-registration and does not depend on the machine account."
}

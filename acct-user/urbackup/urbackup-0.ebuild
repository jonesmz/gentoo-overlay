# Copyright 2019-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="Urbackup program user"
ACCT_USER_ID=111
ACCT_USER_GROUPS=( urbackup )
acct-user_add_deps


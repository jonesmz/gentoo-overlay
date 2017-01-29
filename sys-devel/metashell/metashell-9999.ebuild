# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3 cmake-utils

DESCRIPTION="Interactive Template Metaprogramming Shell"
HOMEPAGE="http://http://metashell.org/"
EGIT_REPO_URI="https://github.com/metashell/metashell.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

REQUIRED_USE=""

COMMON_DEPEND="
	sys-libs/libtermcap-compat
	dev-cpp/gmock
"

DEPEND="
	${COMMON_DEPEND}
"

RDEPEND="
	${COMMON_DEPEND}
"

src_prepare() {
	##
	# Remove third party libs embedded in repo
	##
	sed -i 's/subdirs(boost protobuf googletest googlemock)/subdirs(protobuf)/' ${S}/3rd/CMakeLists.txt || die
	rm -rf ${S}/3rd/boost || die
	rm -rf ${S}/3rd/googletest || die
	rm -rf ${S}/3rd/googlemock || die

	##
	# Remove dependency on embedded third party libs
	##
	sed -i '/include_directories(SYSTEM "${CMAKE_SOURCE_DIR}\/3rd\/googletest\/include")/d' ${S}/test/system/app/core/CMakeLists.txt || die
	sed -i 's/googletest/gtest/g' ${S}/test/system/app/core/CMakeLists.txt || die

	sed -i '/include_directories(SYSTEM "${CMAKE_SOURCE_DIR}\/3rd\/googletest\/include")/d' ${S}/test/system/app/mdb/CMakeLists.txt || die
	sed -i 's/googletest/gtest/g' ${S}/test/system/app/mdb/CMakeLists.txt || die

	sed -i '/include_directories(SYSTEM "${CMAKE_SOURCE_DIR}\/3rd\/googletest\/include")/d' ${S}/test/system/app/pp/CMakeLists.txt || die
	sed -i 's/googletest/gtest/g' ${S}/test/system/app/pp/CMakeLists.txt || die

	sed -i '/include_directories(SYSTEM "${CMAKE_SOURCE_DIR}\/3rd\/googletest\/include")/d' ${S}/test/system/app/pp/CMakeLists.txt || die

	sed -i '/include_directories(SYSTEM "${CMAKE_SOURCE_DIR}\/3rd\/googletest\/include")/d' ${S}/test/unit/CMakeLists.txt || die
	sed -i '/include_directories(SYSTEM "${CMAKE_SOURCE_DIR}\/3rd\/googlemock\/include")/d' ${S}/test/unit/CMakeLists.txt || die
	sed -i 's/googletest/gtest/g' ${S}/test/unit/CMakeLists.txt || die
	sed -i 's/googlemock/gmock/g' ${S}/test/unit/CMakeLists.txt || die

	##
	# Prepare as normal
	##
	cmake-utils_src_prepare
}

src_configure() {
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
}

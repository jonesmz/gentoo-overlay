# Copyright 2016 Michael Jones
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3 cmake

DESCRIPTION="Interactive Template Metaprogramming Shell"
HOMEPAGE="http://http://metashell.org/"
EGIT_REPO_URI="https://github.com/metashell/metashell.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

REQUIRED_USE=""

DEPEND="
	sys-libs/libtermcap-compat
"

RDEPEND="
	${DEPEND}
"

src_prepare() {
	##
	# Remove third party libs embedded in repo
	##
	sed -i 's/subdirs(boost protobuf googletest googlemock)/subdirs(protobuf)/' "${S}/3rd/CMakeLists.txt" || die
	rm -rf "${S}/3rd/boost" || die
	rm -rf "${S}/3rd/googletest" || die
	rm -rf "${S}/3rd/googlemock" || die

	##
	# Remove dependency on embedded third party libs
	##
	sed -i '/include_directories(SYSTEM "${CMAKE_SOURCE_DIR}\/3rd\/googletest\/include")/d' "${S}/test/system/app/core/CMakeLists.txt" || die
	sed -i 's/googletest/gtest/g' "${S}/test/system/app/core/CMakeLists.txt" || die

	sed -i '/include_directories(SYSTEM "${CMAKE_SOURCE_DIR}\/3rd\/googletest\/include")/d' "${S}/test/system/app/mdb/CMakeLists.txt" || die
	sed -i 's/googletest/gtest/g' "${S}/test/system/app/mdb/CMakeLists.txt" || die

	sed -i '/include_directories(SYSTEM "${CMAKE_SOURCE_DIR}\/3rd\/googletest\/include")/d' "${S}/test/system/app/pp/CMakeLists.txt" || die
	sed -i 's/googletest/gtest/g' "${S}/test/system/app/pp/CMakeLists.txt" || die

	sed -i '/include_directories(SYSTEM "${CMAKE_SOURCE_DIR}\/3rd\/googletest\/include")/d' "${S}/test/system/app/pp/CMakeLists.txt" || die

	sed -i '/include_directories(SYSTEM "${CMAKE_SOURCE_DIR}\/3rd\/googletest\/include")/d' "${S}/test/unit/CMakeLists.txt" || die
	sed -i '/include_directories(SYSTEM "${CMAKE_SOURCE_DIR}\/3rd\/googlemock\/include")/d' "${S}/test/unit/CMakeLists.txt" || die
	sed -i 's/googletest/gtest/g' "${S}/test/unit/CMakeLists.txt" || die
	sed -i 's/googlemock/gmock/g' "${S}/test/unit/CMakeLists.txt" || die

	##
	# Prepare as normal
	##
	cmake_src_prepare
}

src_configure() {
	cmake_src_configure
}

src_compile() {
	cmake_src_compile
}

src_install() {
	cmake_src_install
}

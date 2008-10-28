# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"

NEED_KDE="svn"
SLOT="kde-svn"
inherit kde4svn avviso

# Install to KDEDIR rather than /usr, to slot properly.
PREFIX="${KDEDIR}"

DESCRIPTION="CloudCity KDE 4 Theme"
HOMEPAGE="http://cloudcity.sourceforge.net/"
ESVN_REPO_URI="https://cloudcity.svn.sourceforge.net/svnroot/cloudcity"
LICENSE="GPL-2"

pkg_setup() {
	avviso
		}

src_compile() {
	kde4overlay-base_src_compile
		}


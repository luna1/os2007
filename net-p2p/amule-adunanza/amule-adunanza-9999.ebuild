# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: 

inherit eutils flag-o-matic subversion avviso

DESCRIPTION="aMule, the all-platform eMule p2p client, Fastweb Network Mod"
HOMEPAGE="http://www.adunanza.net/"
ESVN_REPO_URI="https://amule-adunanza.svn.sourceforge.net/svnroot/amule-adunanza/trunk"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ppc ~ppc64 ~sparc ~x86"
IUSE="daemon debug geoip gtk nls remote stats unicode upnp"

DEPEND="=x11-libs/wxGTK-2.8*
		>=dev-libs/crypto++-5.5.2
		>=sys-libs/zlib-1.2.1
		stats? ( >=media-libs/gd-2.0.26 )
		geoip? ( dev-libs/geoip )
		upnp? ( net-libs/libupnp )
		remote? ( >=media-libs/libpng-1.2.0
		unicode? ( >=media-libs/gd-2.0.26 ) )"

pkg_setup() {
		avviso
		if ! use gtk && ! use remote && ! use daemon; then
				eerror ""
				eerror "Devi specificare almeno una di queste: gtk, remote, daemon"
				eerror "USE flag per compilare aMule."
				eerror ""
				die "Invalid USE flag set"
		fi

		if use stats && ! use gtk; then
				einfo "Nota: Devi specificare le USE flag: gtk, stats"
				einfo "per compilare la GUI delle statistiche."
				einfo "Non compilerò la GUI."
		fi

		if use stats && ! built_with_use media-libs/gd jpeg; then
				die "media-libs/gd deve essere compilato con la USE flag: jpeg \
				se specifichi la USE flag: stats"
		fi
}

pkg_preinst() {
	if use daemon || use remote; then
		enewgroup p2p
		enewuser p2p -1 -1 /home/p2p p2p
	fi
}

src_compile() {
		local myconf

		WX_GTK_VER="2.8"

		if use gtk ; then
				use stats && myconf="${myconf}
					--enable-wxcas
					--enable-alc"
				use remote && myconf="${myconf}
					--enable-amule-gui"
		else
				myconf="
					--disable-monolithic
					--disable-amule-gui
					--disable-wxcas
					--disable-alc"
		fi

		econf \
				--enable-amulecmd \
				$(use_enable debug) \
				$(use_enable !debug optimize) \
				$(use_enable daemon amule-daemon) \
				$(use_enable geoip) \
				$(use_enable nls) \
				$(use_enable remote webserver) \
				$(use_enable stats cas) \
				$(use_enable stats alcc) \
				${myconf} || die

		# we filter ssp until bug #74457 is closed to build on hardened
		filter-flags -fstack-protector -fstack-protector-all

		emake -j1 || die
}

src_install() {
		emake DESTDIR="${D}" install || die

		if use daemon; then
				newconfd "${FILESDIR}"/amuled.confd amuled
				newinitd "${FILESDIR}"/amuled.initd amuled
		fi

		if use remote; then
				newconfd "${FILESDIR}"/amuleweb.confd amuleweb
				newinitd "${FILESDIR}"/amuleweb.initd amuleweb
				make_desktop_entry amulegui "aMule Remote" amule "Network;P2P"
		fi
}

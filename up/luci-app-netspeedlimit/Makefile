#
# Copyright (C) 2006-2017 OpenWrt.org
# Copyright (C) 2023 sirpdboy <herboy2008@gmail.com>
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for netspeedlimit by sirpdboy
LUCI_DESCRIPTION:=LuCI support for Easy netspeedlimit(Support speed limit based on IP address).
LUCI_DEPENDS:=+bash +tc +kmod-sched-core +kmod-ifb +kmod-sched
LUCI_PKGARCH:=all

PKG_VERSION:=1.1.1
PKG_RELEASE:=20230609
PKG_MAINTAINER:=sirpdboy <herboy2008@gmail.com>

define Package/$(PKG_NAME)/conffiles
/etc/config/netspeedlimit
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature


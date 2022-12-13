#
# Copyright (C) 2010-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
# by 2021 sirpdboy

include $(TOPDIR)/rules.mk

PKG_NAME:=autosamba-samba4
PKG_VERSION:=1
PKG_RELEASE:=12

include $(INCLUDE_DIR)/package.mk

define Package/autosamba-samba4
  TITLE:=Samba4 autoconfig hotplug script.
  MAINTAINER:=Lean
  DEPENDS:=+wsdd2
  PKGARCH:=all
endef

define Package/autosamba-samba4/description
A hotplug script to config Samba share automatically.
endef

define Build/Compile
	true
endef

define Package/autosamba-samba4/install
	$(INSTALL_DIR) $(1)/etc/hotplug.d/block
	$(INSTALL_BIN) ./files/20-smb $(1)/etc/hotplug.d/block/20-smb
endef

$(eval $(call BuildPackage,autosamba-samba4))

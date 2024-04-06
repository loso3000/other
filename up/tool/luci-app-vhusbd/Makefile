#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
# Copyright 2022-2024 sirpdboy  
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk
NAME:=vhusbd
PKG_NAME:=luci-app-$(NAME)
LUCI_PKGARCH:=all
PKG_VERSION:=2.1.0
PKG_RELEASE:=20240406

define Package/$(PKG_NAME)
 	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=VirtualHere USB Service for LuCI
	DEPENDS:=+vhusbd
	PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
    This package contains LuCI configuration pages for VH USB Service.
endef


define Package/$(PKG_NAME)/conffiles
/etc/config/vhusbd
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

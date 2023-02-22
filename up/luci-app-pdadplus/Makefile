
# This is free software, licensed under the Apache License, Version 2.0 .
#  Copyright 2019-2023 sirpdboy <sirpdboy@qq.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-pdadplus

PKG_MAINTAINER:=sirpdboy <sirpdboy@qq.com>
PKG_VERSION:=1.3.1
PKG_RELEASE:=20230222

LUCI_TITLE:=LuCI page for Advanced Plus Config
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+luci-compat

define Package/$(PKG_NAME)/conffiles
/etc/config/pdadplus
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

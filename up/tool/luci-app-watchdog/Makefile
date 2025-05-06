include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-watchdog
PKG_VERSION:=3.6.8
PKG_RELEASE:=

PKG_MAINTAINER:=tty228 <tty228@yeah.net>
PKG_CONFIG_DEPENDS:=

LUCI_TITLE:=LuCI support for watchdog
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+iputils-arping +curl +jq +bash

define Package/$(PKG_NAME)/conffiles
/etc/config/watchdog
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

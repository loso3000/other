# Copyright (C) 2019 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-bridge
PKG_VERSION=v0.1.1
PKG_RELEASE:=23

LUCI_TITLE:=Luci for support bridge
LUCI_PKGARCH:=all
LUCI_DEPENDS:= \
  +ip-bridge \
  +kmod-nft-bridge \
  +kmod-br-netfilter

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

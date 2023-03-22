# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2022 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=msd_lite
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rozhuk-im/msd_lite.git
PKG_SOURCE_DATE:=2023-02-17
PKG_SOURCE_VERSION:=744d2ef91797471e26b3b117e7aa0ffebbb91106
PKG_MIRROR_HASH:=f4e8e3571fda1be758d7fedd10926badea661ca86477e0835b544b5174dc1dae

PKG_MAINTAINER:=Tianling Shen <cnsztl@immrotalwrt.org>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/msd_lite
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Program for IP TV streaming on the network via HTTP
  URL:=http://www.netlab.linkpc.net/wiki/ru:software:msd:lite
endef

define Package/msd_lite/description
  msd_lite - Multi stream daemon lite. The lightweight version of
  Multi Stream daemon (msd) Program for organizing IP TV streaming
  on the network via HTTP.
endef

CMAKE_OPTIONS+= -DCONFDIR=../etc/msd_lite

define Package/msd_lite/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/msd_lite $(1)/usr/bin/
endef

$(eval $(call BuildPackage,msd_lite))

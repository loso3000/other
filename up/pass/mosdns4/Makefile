# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=mosdns4
PKG_VERSION:=4.5.3
PKG_RELEASE:=$(AUTORELEASE)

ifeq ($(ARCH),x86_64)
	PKG_ARCH:=amd64
endif
ifeq ($(ARCH),arm)
	PKG_ARCH:=arm-7
endif
ifeq ($(ARCH),aarch64)
	PKG_ARCH:=arm64
endif

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).zip
PKG_SOURCE_URL:=https://github.com/IrineSistiana/mosdns/releases/download/v$(PKG_VERSION)/mosdns-linux-$(PKG_ARCH).zip?
PKG_HASH:=skip

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILE:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_CONFIG_DEPENDS:= \
	CONFIG_MOSDNS_COMPRESS_UPX

include $(INCLUDE_DIR)/package.mk

UNZIP_CMD:=unzip -q -d $(PKG_BUILD_DIR) $(DL_DIR)/$(PKG_SOURCE)

define Package/mosdns4
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=A plug-in DNS forwarder/splitter
  URL:=https://github.com/IrineSistiana/mosdns
  DEPENDS:=@(x86_64||arm||aarch64)
endef

define Package/mosdns4/config
config MOSDNS_COMPRESS_UPX
	bool "Compress executable files with UPX"
	default y
endef

define Build/Compile

ifneq ($(CONFIG_MOSDNS_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_BUILD_DIR)/mosdns
endif
endef

define Package/mosdns4/install
	$(INSTALL_DIR) $(1)/etc/mosdns4
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mosdns $(1)/usr/bin/mosdns4
	$(INSTALL_DATA) ./files/config.yaml.tpl $(1)/etc/mosdns4/config.yaml.tpl
endef

$(eval $(call BuildPackage,mosdns4))

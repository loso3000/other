# SPDX-License-Identifier: GPL-3.0-only
# Copyright (c) 2020-2024 sirpdboy  herboy2008@gmail.com
#

include $(TOPDIR)/rules.mk

PKG_NAME:=vhusbd
PKG_VERSION:=4.6.4
PKG_RELEASE:=1

ifeq ($(ARCH),aarch64)
	FILENAME:=vhusbdarm64

else ifeq ($(ARCH),arm)
	FILENAME:=vhusbdarm

else ifeq ($(ARCH),i386)
	FILENAME:=vhusbdi386

else ifeq ($(ARCH),mips)
	FILENAME:=vhusbdmips

else ifeq ($(ARCH),mipsel)
	FILENAME:=vhusbdmipsel

else ifeq ($(ARCH),x86_64)
	FILENAME:=vhusbdx86_64
endif

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=VirtualHere USB Service for LuCI
  URL:=https://www.virtualhere.com
  DEPENDS:=
endef

define Package/$(PKG_NAME)/description
  VirtualHere USB Service for LuCI
endef

define Build/Prepare
	[ ! -f $(PKG_BUILD_DIR)/server_Linux_$(H_ARCH).tar.gz ] && wget https://www.virtualhere.com/sites/default/files/usbserver/$(FILENAME) -O vhusbd
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) vhusbd $(1)/usr/bin/vhusbd
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

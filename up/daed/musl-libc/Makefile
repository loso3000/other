#
# Copyright (C) 2012-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=musl-libc
PKG_VERSION:=1.2.4
PKG_RELEASE:=1

PKG_SOURCE:=musl-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://musl.libc.org/releases/
PKG_HASH:=7a35eae33d5372a7c0da1188de798726f68825513b7ae3ebe97aaaa52114f039

PKG_BUILD_DIR:=$(BUILD_DIR)/musl-$(PKG_VERSION)
PKG_BUILD_FLAGS:=no-lto

include $(INCLUDE_DIR)/package.mk

define Package/musl-libc
  SECTION:=libs
  CATEGORY:=Base system
  DEPENDS:=@!USE_MUSL
  TITLE:=musl libc
  URL:=https://musl.libc.org/
endef

define Package/musl-libc/description
  musl is a C standard library to power a new generation
  of Linux-based devices. It is lightweight, fast, simple,
  free, and strives to be correct in the sense of standards
  conformance and safety.
endef

define Package/musl-libc/install
	$(INSTALL_DIR) $(1)/lib
	$(CP) $(PKG_BUILD_DIR)/lib/libc.so $(1)/lib/ld-musl-$(ARCH).so.1
	$(LN) -sf ld-musl-$(ARCH).so.1 $(1)/lib/libc.musl-$(ARCH).so.1
endef

$(eval $(call BuildPackage,musl-libc))

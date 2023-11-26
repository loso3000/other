#
# Copyright (C) 2021 ImmortalWrt
# <https://immortalwrt.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=default-settings
PKG_VERSION:=2.0
PKG_RELEASE:=2
PKG_LICENSE:=GPLv3

include $(INCLUDE_DIR)/package.mk

define Package/default-settings
  SECTION:=luci
  CATEGORY:=LuCI
  TITLE:=LuCI support for Base Settings
  PKGARCH:=all
  DEPENDS:=+luci-base +luci +jsonfilter +@LUCI_LANG_zh-cn
endef

define Package/default-settings/description
	Language Support Packages.
endef

define Package/default-settings/conffiles
/etc/config/base_config
endef

if [ -z "$$IPKG_INSTROOT" ]; then
  ( . /etc/uci-defaults/zzz-base-config-setting )
  rm -f /etc/uci-defaults/zzz-base-config-setting
fi
exit 0
endef

define Package/default-settings/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults $(1)/usr/lib/lua/luci/i18n $(1)/etc/config
	$(INSTALL_DATA) ./files/base_config.config $(1)/etc/config/base_config
	$(INSTALL_BIN) ./files/zzz-default-settings $(1)/etc/uci-defaults/zzz-base-config-setting
	po2lmo ./po/zh-cn/default.po $(1)/usr/lib/lua/luci/i18n/default.zh-cn.lmo
endef

$(eval $(call BuildPackage,default-settings))

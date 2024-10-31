#
# Copyright (C) 2021 Lean <coolsnowwolf@gmail.com>
#
# Copyright (C) 2021 ImmortalWrt
# <https://immortalwrt.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=default-settings
PKG_VERSION:=2
PKG_RELEASE:=26
PKG_LICENSE:=GPL-3.0

include $(INCLUDE_DIR)/package.mk

define Package/default-settings
  SECTION:=luci
  CATEGORY:=LuCI
  TITLE:=LuCI support for Default Settings
  DEPENDS:=+luci +jsonfilter +@LUCI_LANG_zh_Hans +luci-i18n-base-zh-cn
  PKGARCH:=all
endef

define Package/default-settings/description
	Default Settings & Language Support Packages.
endef


define Package/default-settings/conffiles
/etc/config/base_config
endef
define Package/default-settings/postinst
#!/bin/sh
if [ -z "$$IPKG_INSTROOT" ]; then
  ( . /etc/uci-defaults/zzz-base-config-setting )
  rm -f /etc/uci-defaults/zzz-base-config-setting
fi
exit 0
endef
define Build/Compile
endef

define Package/default-settings/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults $(1)/etc/config
	$(INSTALL_DATA) ./files/base_config.config $(1)/etc/config/base_config
	$(INSTALL_BIN) ./files/zzz-default-settings $(1)/etc/uci-defaults/zzz-base-config-setting
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./i18n/default.zh_Hans.po $(1)/usr/lib/lua/luci/i18n/default.zh-cn.lmo
	po2lmo ./i18n/more.zh_Hans.po $(1)/usr/lib/lua/luci/i18n/more.zh-cn.lmo
endef

$(eval $(call BuildPackage,default-settings))

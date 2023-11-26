#
# Copyright (C) 2016-2017 GitHub 
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=default-settings
PKG_VERSION:=2.0
PKG_RELEASE:=2
PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE

PKG_FLAGS:=nonshared

include $(INCLUDE_DIR)/package.mk

define Package/default-settings
  SECTION:=luci
  CATEGORY:=LuCI
  TITLE:=LuCI support for Base Settings
  PKGARCH:=all
  DEPENDS:=+luci-base +luci +base-files +jsonfilter +@LUCI_LANG_zh-cn
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
	$(INSTALL_DIR) $(1)/etc/uci-defaults $(1)/usr/lib/lua/luci/i18n $(1)/etc/config  $(1)/usr/share/base-config
	$(INSTALL_DATA) ./files/base_config.config $(1)/etc/config/base_config
	$(INSTALL_DATA) ./files/zzz-default-settings $(1)/etc/uci-defaults/zzz-base-config-setting
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/auto_usb_mount.init $(1)/etc/init.d/auto_usb_mount
	$(INSTALL_DATA) ./files/auto_usb_mount.hotplug $(1)/usr/share/base-config/auto_usb_mount.hotplug
	$(INSTALL_DATA) ./files/mount.hotplug $(1)/usr/share/base-config/mount.hotplug
	po2lmo ./po/zh-cn/default.po $(1)/usr/lib/lua/luci/i18n/default.zh-cn.lmo
endef

$(eval $(call BuildPackage,default-settings))

# 
# Copyright (C) 2010-2011 OpenWrt.org
#  2021-2023 by sirpdboy  (sirpdboy@qq.com)
#  2020  by lean
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=myautocore
PKG_VERSION:=2
PKG_RELEASE:=22

include $(INCLUDE_DIR)/package.mk
define Package/myautocore-arm
  TITLE:=Arm auto core loadbalance script.
  MAINTAINER:=CN_SZTL
  DEPENDS:=@(arm||aarch64) \
    +TARGET_bcm27xx:bcm27xx-userland \
    +TARGET_bcm53xx:nvram +ethtool
  VARIANT:=arm
endef
define Package/myautocore-x86
  TITLE:=x86/x64 auto core loadbalance script.
  MAINTAINER:=Lean
  DEPENDS:=@TARGET_x86 +lm-sensors +ethtool
  VARIANT:=x86
endef

define Package/myautocore-arm/description
  A luci autoconfig hotplug script.
endef

define Package/myautocore-x86/description
  A usb autoconfig hotplug script.
endef

define Build/Compile
endef

define Package/myautocore-arm/install
	$(INSTALL_DIR) $(1)/etc/init.d/ $(1)/sbin $(1)/etc/uci-defaults $(1)/etc/ $(1)/www
	$(INSTALL_BIN) ./files/generic/sysinfo $(1)/sbin/
	$(INSTALL_DATA) ./files/arm/index.htm $(1)/etc/
	$(INSTALL_BIN) ./files/generic/090-cover-index_htm $(1)/etc/uci-defaults/
	$(CP) ./htdocs/* $(1)/www

endef

define Package/myautocore-x86/install

	$(INSTALL_DIR) $(1)/etc/init.d/ $(1)/sbin $(1)/etc/ $(1)/etc/uci-defaults $(1)/www

	$(INSTALL_BIN) ./files/x86/autocore $(1)/etc/init.d/
	$(INSTALL_DATA) ./files/x86/index.htm $(1)/etc/index.htm
	$(INSTALL_BIN) ./files/generic/090-cover-index_htm $(1)/etc/uci-defaults/
	$(INSTALL_BIN) ./files/generic/sysinfo $(1)/sbin/
	$(CP) ./htdocs/* $(1)/www
endef

$(eval $(call BuildPackage,myautocore-arm))
$(eval $(call BuildPackage,myautocore-x86))

# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2020 Lean <coolsnowwolf@gmail.com>
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=autocore
PKG_FLAGS:=nonshared
PKG_RELEASE:=$(COMMITCOUNT)

PKG_CONFIG_DEPENDS:= \
	CONFIG_TARGET_bcm27xx \
	CONFIG_TARGET_bcm53xx \
	CONFIG_TARGET_mvebu

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/target.mk

define Package/autocore-arm
  TITLE:=ARM auto core script.
  MAINTAINER:=CN_SZTL
  DEPENDS:=@(arm||aarch64) \
    +TARGET_bcm27xx:bcm27xx-userland \
    +TARGET_bcm53xx:nvram
  VARIANT:=arm
endef

define Package/autocore-x86
  TITLE:=x86/x64 auto core loadbalance script.
  MAINTAINER:=Lean / CN_SZTL
  DEPENDS:=@TARGET_x86 +lm-sensors +ethtool +lscpu
  VARIANT:=x86
endef

define Build/Compile
endef

define Package/autocore/install/Default
	$(INSTALL_DIR) $(1)/etc
	$(CP) ./files/generic/10_system.js $(1)/etc/rpcd_10_system.js
	$(CP) ./files/generic/19_cpu.js $(1)/etc/rpcd_19_cpu.js
	$(CP) ./files/generic/28_ethinfo.js $(1)/etc/rpcd_28_ethinfo.js
	$(CP) ./files/generic/29_ports.js $(1)/etc/rpcd_29_ports.js
	$(CP) ./files/generic/luci $(1)/etc/rpcd_luci
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/generic/090-cover-index_files $(1)/etc/uci-defaults/

	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) ./files/generic/sysinfo $(1)/sbin/
	$(INSTALL_BIN) ./files/generic/ethinfo $(1)/sbin/
	$(INSTALL_BIN) ./files/generic/ethlist $(1)/sbin/
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(CP) ./files/generic/luci-mod-status-autocore.json $(1)/usr/share/rpcd/acl.d/
	$(CP) ./files/generic/luci-app-cpu-status.json $(1)/usr/share/rpcd/acl.d/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/admin_status/index/
	$(CP) ./files/generic/inlink.htm  $(1)/usr/lib/lua/luci/view/admin_status/index/
	$(INSTALL_DIR) $(1)/www/luci-static/resources/view/status/include
	$(INSTALL_DATA) ./files/generic/19_cpu.js $(1)/www/luci-static/resources/view/status/include/
	$(INSTALL_DATA) ./files/generic/28_ethinfo.js $(1)/www/luci-static/resources/view/status/include/
endef

define Package/autocore-arm/install
	$(call Package/autocore/install/Default,$(1))

ifneq ($(filter ipq% %mt7622, $(TARGETID)),)
	$(INSTALL_BIN) ./files/arm/tempinfo $(1)/sbin/
endif
endef

define Package/autocore-x86/install
	$(call Package/autocore/install/Default,$(1))

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/x86/autocore $(1)/etc/init.d/
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh

HOST_SED="$(subst ${STAGING_DIR_HOST},$${STAGING_DIR_HOST},$(SED))"
HOST_LN="$(subst ${STAGING_DIR_HOST},$${STAGING_DIR_HOST},$(LN))"

[ -n "$${IPKG_INSTROOT}" ] && {
	$${HOST_SED} 's,^src/gz istoreos_,src/gz openwrt_,g' -e '/^src\/gz openwrt_\(core\|base\|luci\|packages\|routing\|telephony\) /!d' "$${IPKG_INSTROOT}/etc/opkg/distfeeds.conf"

	$${HOST_SED} 's/"192.168.1.1"/"192.168.10.1"/' \
		"$${IPKG_INSTROOT}/usr/lib/lua/luci/controller/admin/system.lua" \
		"$${IPKG_INSTROOT}/usr/lib/lua/luci/controller/admin/ota.lua" \
		"$${IPKG_INSTROOT}/bin/config_generate"

	$${HOST_SED} "s/'192\\.168\\.1\\.1'/'192.168.10.1'/; s/'openwrt\\.lan'/window.location.host/" "$${IPKG_INSTROOT}/www/luci-static/resources/view/system/flash.js"

	$${HOST_SED} 's/s\.anonymous = true/s\.anonymous = true\ns\.addremove = true/' "$${IPKG_INSTROOT}/usr/lib/lua/luci/model/cbi/hd_idle.lua"

	$${HOST_SED} 's#"/opt"#"/overlay/upper/opt/docker"#' "$${IPKG_INSTROOT}/usr/lib/lua/luci/model/cbi/admin_system/fstab/mount.lua"

	rm -f "$${IPKG_INSTROOT}/sbin/jffs2reset"
	$${HOST_LN} /sbin/firstboot "$${IPKG_INSTROOT}/sbin/jffs2reset"
}
true

endef
$(eval $(call BuildPackage,autocore-arm))
$(eval $(call BuildPackage,autocore-x86))

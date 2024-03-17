include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-control-speedlimit
PKG_VERSION:=v4.0.4
PKG_RELEASE:=20210515

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  DEPENDS:=+tc +bash +kmod-ifb +kmod-sched +kmod-sched-core
  TITLE:=LuCI support for speedlimit
  PKGARCH:=all
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
rm -f /tmp/luci-*
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/speedlimit
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

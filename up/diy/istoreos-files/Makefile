include $(TOPDIR)/rules.mk

PKG_NAME:=istoreos-files
PKG_VERSION:=1.0
PKG_RELEASE:=$(COMMITCOUNT)
PKG_FLAGS:=hold essential nonshared

PKG_LICENSE:=CC0-1.0
PKG_MAINTAINER:=jjm2473 <jjm2473@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=base
  CATEGORY:=Base system
  TITLE:=iStoreOS files
  MAINTAINER:=jjm2473 <jjm2473@gmail.com>
  DEFAULT:=y
  HIDDEN:=y
  DEPENDS:=+luci-theme-kucat
endef

define Package/$(PKG_NAME)/description
 The iStoreOS.
endef

define Package/istoreos-intl
  SECTION:=base
  CATEGORY:=Base system
  TITLE:=iStoreOS intl
  MAINTAINER:=jjm2473 <jjm2473@gmail.com>
  DEPENDS:=$(PKG_NAME)
endef

define Package/istoreos-intl/description
 iStoreOS internationalization.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default

endef
Build/Compile = $(Build/Compile/Default)

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh

HOST_SED="$(subst ${STAGING_DIR_HOST},$${STAGING_DIR_HOST},$(SED))"
HOST_LN="$(subst ${STAGING_DIR_HOST},$${STAGING_DIR_HOST},$(LN))"

[ -n "$${IPKG_INSTROOT}" ] && {
	$${HOST_SED} 's/s\.anonymous = true/s\.anonymous = true\ns\.addremove = true/' "$${IPKG_INSTROOT}/usr/lib/lua/luci/model/cbi/hd_idle.lua"
	rm -f "$${IPKG_INSTROOT}/sbin/jffs2reset"
	$${HOST_LN} /sbin/firstboot "$${IPKG_INSTROOT}/sbin/jffs2reset"


}
true

endef

define Package/istoreos-intl/install
	$(CP) ./intl/* $(1)/
endef

$(eval $(call BuildPackage,istoreos-files))
$(eval $(call BuildPackage,istoreos-intl))

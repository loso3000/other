include $(TOPDIR)/rules.mk

PKG_NAME:=homebox
PKG_VERSION:=0.0.0-dev.2023102203
PKG_RELEASE:=1
PKGARCH:=all 

ifeq ($(ARCH),mipsel)
	H_ARCH:=mips
endif
ifeq ($(ARCH),mips)
	H_ARCH:=mips
endif
ifeq ($(ARCH),i386)
	H_ARCH:=386
endif
ifeq ($(ARCH),x86_64)
	H_ARCH:=amd64
endif
ifeq ($(ARCH),arm)
	H_ARCH:=arm
endif
ifeq ($(BOARD),bcm53xx)
	H_ARCH:=arm
ifeq ($(word 2,$(subst +,$(space),$(call qstrip,$(CONFIG_CPU_TYPE)))),)
	H_ARCH:=arm
endif
endif
ifeq ($(BOARD),kirkwood)
	H_ARCH:=arm
endif
ifeq ($(ARCH),aarch64)
	H_ARCH:=arm64
endif

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=skip

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A Toolbox for Home Local Networks
  URL:=https://github.com/XGHeaven/homebox
  DEPENDS:=@(i386||x86_64||arm||aarch64||mipsel||mips)
endef

define Package/$(PKG_NAME)/description
  A Toolbox for Home Local Networks Speed Test
endef

define Build/Prepare
	[ ! -f $(PKG_BUILD_DIR)/server_Linux_$(H_ARCH).tar.gz ] && wget https://github.com/XGHeaven/homebox/releases/download/v$(PKG_VERSION)/server_Linux_$(H_ARCH).tar.gz -O $(PKG_BUILD_DIR)/server_Linux_$(H_ARCH).tar.gz
	tar -xzvf $(PKG_BUILD_DIR)/server_Linux_$(H_ARCH).tar.gz -C $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/server_Linux_$(H_ARCH) $(1)/usr/bin/homebox
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

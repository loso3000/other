# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2022 ImmortalWrt.org

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=igb
PKG_VERSION:=5.15.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://downloads.sourceforge.net/project/e1000/igb%20stable/$(PKG_VERSION)/
PKG_MD5SUM:=0f627bf1dd424d0cd55a4829c8c38b63

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define KernelPackage/igb-intel
  SUBMENU:=Network Devices
  TITLE:=Intel(R) 82575/82576 PCI-Express Gigabit Ethernet support (vendor driver)
  VERSION:=$(LINUX_VERSION)+$(PKG_VERSION)-$(BOARD)-$(PKG_RELEASE)
  DEPENDS:=@PCI_SUPPORT +kmod-i2c-core +kmod-i2c-algo-bit +kmod-ptp +kmod-hwmon-core @TARGET_x86
  CONFLICTS:=kmod-igb
  FILES:=$(PKG_BUILD_DIR)/src/igb.ko
  AUTOLOAD:=$(call AutoProbe,igb)
endef

define KernelPackage/igb-intel/description
  Kernel modules for Intel(R) 82575/82576 PCI-Express Gigabit Ethernet adapters.
endef

define Build/Configure
	( \
		pushd $(PKG_BUILD_DIR)/src ; \
		KSRC=$(LINUX_DIR) \
		OUT=kcompat_generated_defs.h \
		CONFFILE=$(LINUX_DIR)/include/generated/autoconf.h \
		bash kcompat-generator.sh ; \
		popd ; \
	)
endef

define Build/Compile
	+$(KERNEL_MAKE) $(PKG_JOBS) \
		M=$(PKG_BUILD_DIR)/src \
		CONFIG_IGB=m \
		modules
endef

$(eval $(call KernelPackage,igb-intel))

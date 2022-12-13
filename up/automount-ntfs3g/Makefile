#
# Copyright (C) 2010-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=automount-ntfs
PKG_VERSION:=1
PKG_RELEASE:=39
PKG_ARCH:=all

include $(INCLUDE_DIR)/package.mk

define Package/automount-ntfs
  TITLE:=mount and format autoconfig hotplug script.
  MAINTAINER:=Lean &sirpdboy

  DEPENDS:=+block-mount +kmod-fs-exfat +kmod-fs-ext4 +kmod-fs-vfat +libblkid +ntfs-3g +ntfs-3g-utils \
	+kmod-usb-storage +kmod-usb-storage-extras +!TARGET_ramips:kmod-usb-storage-uas
endef

define Package/automount-ntfs/description
  A usb autoconfig hotplug script.
endef

define Build/Compile
endef

define Package/automount-ntfs/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults $(1)/sbin
	$(INSTALL_BIN) ./files/15-automount $(1)/etc/15-automount
	$(INSTALL_BIN) ./files/mount.ntfs $(1)/sbin
	$(INSTALL_BIN) ./files/zzz-move-automount $(1)/etc/uci-defaults/zzz-move-automount
endef

$(eval $(call BuildPackage,automount-ntfs))

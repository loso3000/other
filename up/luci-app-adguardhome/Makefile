# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-adguardhome

LUCI_TITLE:=LuCI app for AdGuardHome
LUCI_DEPENDS:=+adguardhome +luci-base

PKG_MAINTAINER:=Douglas Orend <doug.orend2@gmail.com>


define Package/luci-app-adguardhome/conffiles
/etc/config/AdGuardHome
/etc/AdGuardHome.yaml
endef


define Package/luci-app-adguardhome/postinst
#!/bin/sh
	chmod 755 /usr/share/AdGuardHome/*
	chmod +x /etc/init.d/AdGuardHome
	/etc/init.d/AdGuardHome enable >/dev/null 2>&1
	enable=$(uci get AdGuardHome.AdGuardHome.enabled 2>/dev/null)
	if [ "$enable" == "1" ]; then
		/etc/init.d/AdGuardHome reload
	fi
	rm -f /tmp/luci-indexcache
	rm -f /tmp/luci-modulecache/*
exit 0
endef

define Package/luci-app-adguardhome/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
     /etc/init.d/AdGuardHome disable
     /etc/init.d/AdGuardHome stop
uci -q batch <<-EOF >/dev/null 2>&1
	delete ucitrack.@AdGuardHome[-1]
	commit ucitrack
EOF
fi
exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

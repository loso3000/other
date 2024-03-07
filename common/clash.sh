
#!/bin/bash
OP=$1
if [ $OP == amd64 ] ;then
BASE_FILES=${GITHUB_WORKSPACE}/openwrt/package/base-files/files
			singbox_version="1.8.7"
			hysteria_version="2.2.4"
			wget --quiet --no-check-certificate -P /tmp https://github.com/SagerNet/sing-box/releases/download/v${singbox_version}/sing-box-${singbox_version}-linux-amd64.tar.gz
			wget --quiet --no-check-certificate -P /tmp \
				https://github.com/apernet/hysteria/releases/download/app%2Fv${hysteria_version}/hysteria-linux-amd64
			
			mkdir -p ${BASE_FILES}/usr/bin
			tar -xvzf /tmp/sing-box-${singbox_version}-linux-amd64.tar.gz -C /tmp
			Copy /tmp/sing-box-${singbox_version}-linux-amd64/sing-box ${BASE_FILES}/usr/bin
			Copy /tmp/hysteria-linux-amd64 ${BASE_FILES}/usr/bin hysteria

			chmod 777 ${BASE_FILES}/usr/bin/sing-box ${BASE_FILES}/usr/bin/hysteria
fi
#删除冲突插件
# rm -rf $(find ./feeds/luci/ -type d -regex ".*\(argon\|design\|openclash\).*")
#修改默认主题
# sed -i "s/luci-theme-bootstrap/luci-theme-$OWRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改默认IP地址
# sed -i "s/192\.168\.[0-9]*\.[0-9]*/$OWRT_IP/g" ./package/base-files/files/bin/config_generate
#修改默认主机名
# sed -i "s/hostname='.*'/hostname='$OWRT_NAME'/g" ./package/base-files/files/bin/config_generate
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" ./package/base-files/files/bin/config_generate
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" ./package/base-files/files/bin/config_generate
mkdir -p files/etc/openclash/core
CLASH_DEV_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/dev/clash-linux-${OP}.tar.gz"
CLASH_TUN_URL=$(curl -fsSL https://api.github.com/repos/vernesong/OpenClash/contents/master/premium\?ref\=core | grep download_url | grep amd64 | awk -F '"' '{print $4}' | grep "v3" )
CLASH_META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-${OP}.tar.gz"
GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
wget -qO- $CLASH_DEV_URL | tar xOvz > files/etc/openclash/core/clash
wget -qO- $CLASH_TUN_URL | gunzip -c > files/etc/openclash/core/clash_tun
wget -qO- $CLASH_META_URL | tar xOvz > files/etc/openclash/core/clash_meta
wget -qO- $GEOIP_URL > files/etc/openclash/GeoIP.dat
wget -qO- $GEOSITE_URL > files/etc/openclash/GeoSite.dat

[ -f files/etc/openclash/core/clash ] || mv -f ./package/other/patch/openclash/core/clash files/etc/openclash/core/clash
[ -f files/etc/openclash/core/clash_tun ] || mv -f ./package/other/patch/openclash/core/clash_tun files/etc/openclash/core/clash_tun
[ -f files/etc/openclash/core/clash_meta ] || mv -f ./package/other/patch/openclash/core/clash_meta files/etc/openclash/core/clash_meta
[ -f files/etc/openclash/GeoIP.dat ] || mv -f ./package/other/patch/openclash/GeoIP.dat files/etc/openclash/GeoIP.dat
[ -f files/etc/openclash/GeoSite.dat ] || mv -f ./package/other/patch/openclash/GeoSite.dat files/etc/openclash/GeoSite.dat
chmod +x files/etc/openclash/core/clash*


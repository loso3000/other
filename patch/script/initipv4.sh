#!/bin/bash
#=================================================
# Description: Build OpenWrt using GitHub Actions
# 使用 O2 级别的优化
# sed -i 's/O3/O2/g' include/target.mk
git clone https://github.com/sirpdboy/build.git ./package/build

# version=$(grep "DISTRIB_REVISION=" package/lean/default-settings/files/zzz-default-settings  | awk -F "'" '{print $2}')

rm -rf ./package/lean/luci-theme-argon
rm -rf ./package/lean/luci-theme-opentomcat
echo '替换aria2'
rm -rf ./feeds/luci/applications/luci-app-aria2 && svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-aria2 ./feeds/luci/applications/luci-app-aria2
rm -rf ./feeds/packages/net/aria2 && svn co https://github.com/sirpdboy/sirpdboy-package/trunk/aria2 ./feeds/packages/net/aria2
rm -rf ./feeds/packages/net/ariang && svn co https://github.com/sirpdboy/sirpdboy-package/trunk/ariang ./feeds/packages/net/ariang
# rm -rf package/diy/aria2
# rm -rf package/diy/ariang
# rm -rf package/diy/luci-app-aria2
# echo '替换transmission'
rm -rf ./feeds/luci/applications/luci-app-transmission && svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-transmission ./feeds/luci/applications/luci-app-transmission
rm -rf ./feeds/packages/net/transmission && svn co https://github.com/sirpdboy/sirpdboy-package/trunk/transmission ./feeds/packages/net/transmission
rm -rf ./feeds/packages/net/transmission-web-control && svn co https://github.com/sirpdboy/sirpdboy-package/trunk/transmission-web-control ./feeds/packages/net/transmission-web-control
# echo 'qBittorrent'
# rm -rf package/lean/luci-app-qbittorrent
# rm -rf package/lean/qBittorrent
# rm -rf package/diy/luci-app-qbittorrent
# rm -rf package/diy/qBittorrent
# rm -rf package/lean/qt5
rm -rf ./package/lean/luci-app-wrtbwmon
rm -rf ./package/lean/luci-app-baidupcs-web && svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-baidupcs-web ./package/lean/luci-app-baidupcs-web
# luci-app-kodexplorer
rm -rf ./package/lean/luci-app-kodexplorer && svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-kodexplorer ./package/lean/luci-app-kodexplorer
# ksmbd
rm -rf ./feeds/packages/kernel/ksmbd && svn co https://github.com/sirpdboy/build/trunk/ksmbd ./feeds/packages/kernel/ksmbd
rm -rf ./feeds/packages/net/ksmbd-tools && svn co https://github.com/sirpdboy/build/trunk/ksmbd-tools ./feeds/packages/net/ksmbd-tools
echo '替换smartdns'
rm -rf ./feeds/packages/net/smartdns&& svn co https://github.com/sirpdboy/sirpdboy-package/trunk/smartdns ./feeds/packages/net/smartdns
rm -rf ./package/lean/luci-app-netdata && svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-netdata ./package/lean/luci-app-netdata
rm -rf ./feeds/packages/admin/netdata && svn co https://github.com/sirpdboy/sirpdboy-package/trunk/netdata ./feeds/packages/admin/netdata
#rm -rf ./feeds/luci/applications/luci-app-mwan3 && svn co https://github.com/sirpdboy/build/trunk/luci-app-mwan3 ./feeds/luci/applications/luci-app-mwan3
rm -rf ./feeds/packages/net/mwan3 && svn co https://github.com/sirpdboy/build/trunk/mwan3 ./feeds/packages/net/mwan3
rm -rf ./feeds/packages/net/https-dns-proxy  && svn co https://github.com/Lienol/openwrt-packages/trunk/net/https-dns-proxy ./feeds/packages/net/https-dns-proxy
rm -rf ./feeds/packages/devel/ninja   && svn co https://github.com/Lienol/openwrt-packages/trunk/devel/ninja feeds/packages/devel/ninja
#rm -rf ./package/diy/autocore
rm -rf ./package/build/mwan3
rm -rf ./package/build/set/autocore
rm -rf ./package/lean/automount
rm -rf ./package/lean/autosamba
rm -rf ./package/lean/luci-app-accesscontrol
rm -rf ./package/lean/autocore
rm -rf ./package/lean/default-settings
rm -rf ./package/lean/luci-app-ramfree
rm -rf ./package/lean/luci-app-arpbind
rm -rf ./package/lean/luci-app-docker
rm -rf ./package/lean/luci-app-dockerman
rm -rf ./package/lean/luci-lib-docker
rm -rf ./package/lean/trojan
rm -rf ./feeds/packages/build/wsdd2
rm -rf ./package/build/openwrt-fullconenat 
rm -rf ./package/build/shortcut-fe
rm -rf ./package/build/dnsforwarder
# rm -rf package/lean/openwrt-fullconenat && svn co https://github.com/sirpdboy/build/trunk/openwrt-fullconenat package/lean/openwrt-fullconenat
# rm -rf ./package/lean/shortcut-fe
# rm -rf ./package/lean/dnsforwarder
# rm -rf  ./feeds/packages/net/wsdd2  && svn co https://github.com/sirpdboy/build/trunk/wsdd2  ./feeds/packages/net/wsdd2 
rm -rf ./feeds/luci/applications/luci-app-samba 
# svn co https://github.com/sirpdboy/build/trunk/luci-app-samba ./feeds/luci/applications/luci-app-samba
rm -rf ./package/network/services/samba36 
# svn co https://github.com/sirpdboy/build/trunk/samba36 ./package/network/services/samba36
rm -rf ./package/lean/samba4
rm -rf ./feeds/package/net/samba4 && svn co https://github.com/sirpdboy/build/trunk/samba4 ./feeds/package/net/samba4
rm -rf ./package/lean/softethervpn5
rm -rf ./package/lean/luci-app-samba4

# Boost 通用即插即用
# sed -i 's,api.ipify.org,myip.ipip.net/s,g' ./package/build/luci-app-boostupnp/root/usr/sbin/boostupnp.sh
# rm -rf ./feeds/packages/net/miniupnpd   && svn co https://github.com/openwrt/packages/trunk/net/miniupnpd feeds/packages/net/miniupnpd

# curl -fsSL https://raw.githubusercontent.com/loso3000/other/master/patch/autocore/files/x86/index.htm > package/lean/autocore/files/x86/index.htm
# curl -fsSL https://raw.githubusercontent.com/loso3000/other/master/patch/autocore/files/arm/index.htm > package/lean/autocore/files/arm/index.htm
 curl -fsSL  https://raw.githubusercontent.com/loso3000/other/master/patch/default-settings/zzz-default-settings > ./package/build/default-settings/files/zzz-default-settings
# curl -fsSL  https://raw.githubusercontent.com/sirpdboy/sirpdboy-package/master/set/sysctl.conf > ./package/base-files/files/etc/sysctl.conf
echo '添加关机'
curl -fsSL  https://raw.githubusercontent.com/loso3000/other/master/patch/poweroff/poweroff.htm > ./feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_system/poweroff.htm 
curl -fsSL  https://raw.githubusercontent.com/loso3000/other/master/patch/poweroff/system.lua > ./feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/system.lua

sed -i 's/网络存储/存储/g' ./package/lean/luci-app-vsftpd/po/zh-cn/vsftpd.po
sed -i 's/Turbo ACC 网络加速/ACC网络加速/g' ./package/lean/luci-app-flowoffload/po/zh-cn/flowoffload.po
sed -i 's/Turbo ACC 网络加速/ACC网络加速/g' ./package/lean/luci-app-sfe/po/zh-cn/sfe.po
sed -i 's/解锁网易云灰色歌曲/解锁灰色歌曲/g' ./package/lean/luci-app-unblockmusic/po/zh-cn/unblockmusic.po
sed -i 's/家庭云//g' ./package/lean/luci-app-familycloud/luasrc/controller/familycloud.lua
sed -i 's/实时流量监测/流量/g' ./package/lean/luci-app-wrtbwmon/po/zh-cn/wrtbwmon.po
sed -i 's/KMS 服务器/KMS激活/g' ./package/lean/luci-app-vlmcsd/po/zh-cn/vlmcsd.po
sed -i 's/USB 打印服务器"/打印服务/g' ./package/lean/luci-app-usb-printer/po/zh-cn/usb-printer.po
sed -i 's/aMule设置/电驴下载/g' ./package/lean/luci-app-amule/po/zh-cn/amule.po
sed -i 's/网络存储/存储/g' ./package/lean/luci-app-amule/po/zh-cn/amule.po
sed -i 's/监听端口/监听端口 用户名admin密码adminadmin/g' ./package/lean/luci-app-qbittorrent/po/zh-cn/qbittorrent.po
sed -i 's/带宽监控/监控/g' ./feeds/luci/applications/luci-app-nlbwmon/po/zh-cn/nlbwmon.po
sed -i 's/a.default = "0"/a.default = "1"/g' ./package/lean/luci-app-cifsd/luasrc/controller/cifsd.lua   #挂问题
echo  "        option tls_enable 'true'" >> ./package/lean/luci-app-frpc/root/etc/config/frp   #FRP穿透问题
sed -i 's/invalid/# invalid/g' ./package/lean/samba4/files/smb.conf.template   #共享问题
sed -i 's/invalid/# invalid/g' ./package/network/services/samba36/files/smb.conf.template  #共享问题
sed -i '/mcsub_renew.datatype/d'  ./feeds/luci/applications/luci-app-udpxy/luasrc/model/cbi/udpxy.lua  #修复UDPXY设置延时55的错误
sed -i 's/root::0:0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/g' ./package/base-files/files/etc/shadow
# sed -i '/filter_/d' ./package/network/services/dnsmasq/files/dhcp.conf   #DHCP禁用IPV6问题
echo '灰色歌曲'
rm -rf ./package/lean/luci-app-unblockmusic
git clone https://github.com/immortalwrt/luci-app-unblockneteasemusic.git  ./package/diy/luci-app-unblockneteasemusic
sed -i 's/解除网易云音乐播放限制/解锁灰色歌曲/g' ./package/diy/luci-app-unblockneteasemusic/luasrc/controller/unblockneteasemusic.lua

# git clone https://github.com/garypang13/luci-app-bypass.git package/luci-app-bypass
# find package/*/ feeds/*/ -maxdepth 2 -path "*luci-app-bypass/Makefile" | xargs -i sed -i 's/shadowsocksr-libev-ssr-redir/shadowsocksr-libev-alt/g' {}
# find package/*/ feeds/*/ -maxdepth 2 -path "*luci-app-bypass/Makefile" | xargs -i sed -i 's/shadowsocksr-libev-ssr-server/shadowsocksr-libev-server/g' {}
# git clone https://github.com/garypang13/luci-app-dnsfilter.git package/luci-app-dnsfilter

# rm -rf package/lean/luci-app-jd-dailybonus && git clone https://github.com/jerrykuku/luci-app-jd-dailybonus.git package/diy/luci-app-jd-dailybonus

#svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash ./package/diy/luci-app-openclash
git clone https://github.com/vernesong/OpenClash ./package/diy/OpenClash
git clone -b master --single-branch https://github.com/tty228/luci-app-serverchan ./package/diy/luci-app-serverchan
git clone -b master --single-branch https://github.com/destan19/OpenAppFilter ./package/diy/OpenAppFilter
# 京东签到 By Jerrykuku
# sed -i 's/wget-ssl/wget/g' package/lean/luci-app-jd-dailybonus/root/usr/share/jd-dailybonus/newapp.sh package/lean/luci-app-jd-dailybonus/luasrc/controller/jd-dailybonus.lua
# rm -rf ./package/lean/luci-app-jd-dailybonus/root/usr/share/jd-dailybonus/JD_DailyBonus.js
# wget -P ./package/lean/luci-app-jd-dailybonus/root/usr/share/jd-dailybonus/ https://github.com/NobyDa/Script/raw/master/JD-DailyBonus/JD_DailyBonus.js
# 花生壳内网穿透
# svn co https://github.com/QiuSimons/dragino2-teasiu/trunk/package/teasiu/luci-app-phtunnel package/new/luci-app-phtunnel
# svn co https://github.com/QiuSimons/dragino2-teasiu/trunk/package/teasiu/phtunnel package/new/phtunnel
svn co https://github.com/teasiu/dragino2/trunk/devices/common/diy/package/teasiu/luci-app-phtunnel package/new/luci-app-phtunnel
svn co https://github.com/teasiu/dragino2/trunk/devices/common/diy/package/teasiu/phtunnel package/new/phtunnel
svn co https://github.com/QiuSimons/dragino2-teasiu/trunk/package/teasiu/luci-app-oray package/new/luci-app-oray

# Passwall
# svn co https://github.com/xiaorouji/openwrt-passwall/trunk package/passwall
git clone https://github.com/xiaorouji/openwrt-passwall package/passwall
# svn co https://github.com/xiaorouji/openwrt-passwall/trunk/luci-app-passwall package/passwall/luci-app-passwall
sed -i 's,default n,default y,g' package/passwall/luci-app-passwall/Makefile

# ShadowsocksR Plus+
svn co https://github.com/fw876/helloworld/trunk/luci-app-ssr-plus package/lean/luci-app-ssr-plus
sed -i '/status/am:section(SimpleSection).template = "openclash/myip"' ./package/lean/luci-app-ssr-plus/luasrc/model/cbi/shadowsocksr/client.lua

sed -i 's,default n,default y,g' ./package/lean/luci-app-ssr-plus
sed -i '/V2ray:v2ray/d' Makefile
sed -i '/plugin:v2ray/d' Makefile

# VSSR
svn co https://github.com/jerrykuku/luci-app-vssr/trunk/  ./package/lean/luci-app-vssr
# git clone -b master --depth 1 https://github.com/jerrykuku/luci-app-vssr.git package/lean/luci-app-vssr
# git clone -b master --depth 1 https://github.com/jerrykuku/lua-maxminddb.git package/lean/lua-maxminddb
sed -i 's,default n,default y,g' ./package/lean/luci-app-vssr/Makefile

find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

./scripts/feeds update -i

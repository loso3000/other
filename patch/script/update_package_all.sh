#!/bin/bash
#=================================================
# Description: Build OpenWrt using GitHub Actions
git clone https://github.com/sirpdboy/build.git package/build
rm -rf ./package/lean/luci-theme-argon
rm -rf ./package/lean/luci-theme-opentomcat
# echo '替换aria2'
rm -rf feeds/luci/applications/luci-app-aria2 && svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-aria2 feeds/luci/applications/luci-app-aria2
rm -rf feeds/packages/net/aria2 && svn co https://github.com/sirpdboy/sirpdboy-package/trunk/aria2 feeds/packages/net/aria2
rm -rf feeds/packages/net/ariang && svn co https://github.com/sirpdboy/sirpdboy-package/trunk/ariang feeds/packages/net/ariang
# rm -rf package/diy/aria2
# rm -rf package/diy/ariang
# rm -rf package/diy/luci-app-aria2
# echo '替换transmission'
rm -rf feeds/luci/applications/luci-app-transmission && svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-transmission feeds/luci/applications/luci-app-transmission
rm -rf feeds/packages/net/transmission && svn co https://github.com/sirpdboy/sirpdboy-package/trunk/transmission feeds/packages/net/transmission
rm -rf feeds/packages/net/transmission-web-control && svn co https://github.com/sirpdboy/sirpdboy-package/trunk/transmission-web-control feeds/packages/net/transmission-web-control
# echo 'qBittorrent'
# rm -rf package/lean/luci-app-qbittorrent
# rm -rf package/lean/qBittorrent
#rm -rf package/diy/luci-app-qbittorrent
#rm -rf package/diy/qBittorrent
rm -rf package/lean/qt5
rm -rf package/lean/luci-app-wrtbwmon
rm -rf package/lean/luci-app-baidupcs-web && svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-baidupcs-web ./package/lean/luci-app-baidupcs-web
#ksmbd
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
#rm -rf ./package/diy/default-settings
rm -rf ./package/lean/automount
rm -rf ./package/lean/autosamba
rm -rf ./package/diy/netdata
rm -rf ./package/build/mwan3
rm -rf ./package/lean/autocore
rm -rf ./package/lean/default-settings
#curl -fsSL  https://raw.githubusercontent.com/sirpdboy/sirpdboy-package/master/set/sysctl.conf > ./package/base-files/files/etc/sysctl.conf
curl -fsSL  https://raw.githubusercontent.com/loso3000/other/master/patch/poweroff/poweroff.htm > ./feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_system/poweroff.htm 
curl -fsSL  https://raw.githubusercontent.com/loso3000/other/master/patch/poweroff/system.lua > ./feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/system.lua
sed -i 's/网络存储/存储/g' package/lean/luci-app-vsftpd/po/zh-cn/vsftpd.po
sed -i 's/Turbo ACC 网络加速/ACC网络加速/g' package/lean/luci-app-flowoffload/po/zh-cn/flowoffload.po
sed -i 's/Turbo ACC 网络加速/ACC网络加速/g' package/lean/luci-app-sfe/po/zh-cn/sfe.po
sed -i 's/解锁网易云灰色歌曲/解锁灰色歌曲/g' package/lean/luci-app-unblockmusic/po/zh-cn/unblockmusic.po
sed -i 's/家庭云//g' package/lean/luci-app-familycloud/luasrc/controller/familycloud.lua
sed -i 's/实时流量监测/流量/g' package/lean/luci-app-wrtbwmon/po/zh-cn/wrtbwmon.po
sed -i 's/KMS 服务器/KMS激活/g' package/lean/luci-app-vlmcsd/po/zh-cn/vlmcsd.po
sed -i 's/USB 打印服务器"/打印服务/g' package/lean/luci-app-usb-printer/po/zh-cn/usb-printer.po
sed -i 's/aMule设置/电驴下载/g' package/lean/luci-app-amule/po/zh-cn/amule.po
sed -i 's/网络存储/存储/g' package/lean/luci-app-amule/po/zh-cn/amule.po
sed -i 's/监听端口/监听端口 用户名admin密码adminadmin/g' package/lean/luci-app-qbittorrent/po/zh-cn/qbittorrent.po

cp -f ./package/build/banner ./package/base-files/files/etc/
date1='Ipv6-S'`TZ=UTC-8 date +%Y.%m.%d -d +"8"hour`
sed -i 's/$(VERSION_DIST_SANITIZED)/$(shell TZ=UTC-8 date +%Y%m%d -d +8hour)-Ipv6/g' include/image.mk
echo "DISTRIB_REVISION='${date1} by Sirpdboy'" > ./package/base-files/files/etc/openwrt_release1
echo ${date1}' by Sirpdboy ' >> ./package/base-files/files/etc/banner
echo '---------------------------------' >> ./package/base-files/files/etc/banner
sed -i 's/带宽监控/监控/g' feeds/luci/applications/luci-app-nlbwmon/po/zh-cn/nlbwmon.po
sed -i 's/root::0:0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/g' ./package/base-files/files/etc/shadow

sed -i 's/a.default = "0"/a.default = "1"/g' ./package/lean/luci-app-cifsd/luasrc/controller/cifsd.lua   #挂问题
echo  "        option tls_enable 'true'" >> ./package/lean/luci-app-frpc/root/etc/config/frp   #FRP穿透问题
sed -i 's/invalid/# invalid/g' package/lean/samba4/files/smb.conf.template   #共享问题
sed -i 's/invalid/# invalid/g' package/network/services/samba36/files/smb.conf.template  #共享问题
sed -i '/filter_/d' package/network/services/dnsmasq/files/dhcp.conf   #DHCP禁用IPV6问题
sed -i '/mcsub_renew.datatype/d'  feeds/luci/applications/luci-app-udpxy/luasrc/model/cbi/udpxy.lua  #修复UDPXY设置延时55的错误
#内核设置 甜糖
cat ./package/build/set/Config-kernel.in   > ./config/Config-kernel.in
echo  'CONFIG_BINFMT_MISC=y' >> ./package/target/linux/x86/config-5.4
##sed -i '/CONFIG_NVME_MULTIPATH /d' ./package/target/linux/x86/config-5.4
#sed -i '/CONFIG_NVME_TCP /d' ./package/target/linux/x86/config-5.4
#echo  'CONFIG_EXTRA_FIRMWARE="i915/kbl_dmc_ver1_04.bin"'   >> ./package/target/linux/x86/config-5.4
#echo  'CONFIG_EXTRA_FIRMWARE_DIR="/lib/firmware"'  >> ./package/target/linux/x86/config-5.4
#echo  'CONFIG_NVME_FABRICS=y'  >> ./package/target/linux/x86/config-5.4
#echo  'CONFIG_NVME_FC=y' >> ./package/target/linux/x86/config-5.4
#echo  'CONFIG_NVME_MULTIPATH=y' >> ./package/target/linux/x86/config-5.4
#echo  'CONFIG_NVME_TCP=y' >> ./package/target/linux/x86/config-5.4

git clone https://github.com/garypang13/luci-app-bypass.git package/luci-app-bypass
find package/*/ feeds/*/ -maxdepth 2 -path "*luci-app-bypass/Makefile" | xargs -i sed -i 's/shadowsocksr-libev-ssr-redir/shadowsocksr-libev-alt/g' {}
find package/*/ feeds/*/ -maxdepth 2 -path "*luci-app-bypass/Makefile" | xargs -i sed -i 's/shadowsocksr-libev-ssr-server/shadowsocksr-libev-server/g' {}
#git clone https://github.com/garypang13/luci-app-dnsfilter.git package/luci-app-dnsfilter
#rm -rf package/lean/luci-app-jd-dailybonus && git clone https://github.com/jerrykuku/luci-app-jd-dailybonus.git package/diy/luci-app-jd-dailybonus
svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash package/diy/luci-app-openclash
git clone https://github.com/xiaorouji/openwrt-passwall package/diy1
#git clone https://github.com/AlexZhuo/luci-app-bandwidthd /package/diy/luci-app-bandwidthd
git clone -b master --single-branch https://github.com/tty228/luci-app-serverchan ./package/diy/luci-app-serverchan
git clone -b master --single-branch https://github.com/destan19/OpenAppFilter ./package/diy/OpenAppFilter

svn co https://github.com/fw876/helloworld/trunk/luci-app-ssr-plus  package/diy/luci-app-ssr-plus
sed -i '/status/am:section(SimpleSection).template = "openclash/myip"' ./package/diy/luci-app-ssr-plus/luasrc/model/cbi/shadowsocksr/client.lua

svn co https://github.com/jerrykuku/luci-app-vssr/trunk/  package/diy/luci-app-vssr

#sed -i '/get("@global_other/i\m:section(SimpleSection).template = "openclash/myip"' package/diy1/luci-app-passwall/luasrc/model/cbi/passwall/client/global.lua
#else
#	cp -vr package/diy/myip.htm ./package/hw/luci-app-ssr-plus/luasrc/view
#	sed -i '/status/am:section(SimpleSection).template = "myip"'  ./package/hw/luci-app-ssr-plus/luasrc/model/cbi/shadowsocksr/client.lua
#	sed -i '/get("@global_other/i\m:section(SimpleSection).template = "myip"'  package/diy1/luci-app-passwall/luasrc/model/cbi/passwall/client/global.lua
git clone https://github.com/jerrykuku/luci-app-ttnode.git     package/diy/luci-app-ttnode
# svn co https://github.com/jerrykuku/luci-app-ttnode/trunk/  package/diy/luci-app-ttnode
# sed -i 's/KERNEL_PATCHVER:=5.4/KERNEL_PATCHVER:=4.19/g' ./target/linux/x86/Makefile
# sed -i 's/KERNEL_TESTING_PATCHVER:=5.4/KERNEL_TESTING_PATCHVER:=4.19/g' ./target/linux/x86/Makefile
#sed -i "/mediaurlbase/d" package/*/luci-theme*/root/etc/uci-defaults/*
#sed -i "/mediaurlbase/d" feed/*/luci-theme*/root/etc/uci-defaults/*

# Add driver for rtl8821cu & rtl8812au-ac
# svn co https://github.com/project-openwrt/openwrt/branches/master/package/ctcgfw/rtl8812au-ac ./package/ctcgfw
# svn co https://github.com/project-openwrt/openwrt/branches/master/package/ctcgfw/rtl8821cu ./package/ctcgfw
rm -rf package/lean/luci-app-docker
rm -rf package/lean/luci-app-dockerman
rm -rf package/lean/luci-lib-docker
# rm -rf ./package/diy1/trojan
# rm -rf ./package/diy1/v2ray
# rm -rf ./package/diy1/v2ray-plugin
#  rm -rf package/lean/parted
# rm -rf package/diy1/tcping
rm -rf ./package/lean/trojan
rm -rf ./package/lean/v2ray-plugin
rm -rf package/diy/vssr
./scripts/feeds update -i
#git clone https://github.com/openwrt-dev/po2lmo.git
#cd po2lmo
#make && sudo make install

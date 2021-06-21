#!/bin/bash
#=================================================
# Description: Build OpenWrt using GitHub Actions
cp -f ./package/build/banner ./package/base-files/files/etc/
# date1='${version} Ipv4P-S'`TZ=UTC-8 date +%Y.%m.%d -d +"8"hour`
date1='Ipv4P-S'`TZ=UTC-8 date +%Y.%m.%d -d +"8"hour`
sed -i 's/$(VERSION_DIST_SANITIZED)/$(shell TZ=UTC-8 date +%Y%m%d -d +8hour)-Ipv4P/g' include/image.mk
echo "DISTRIB_REVISION='${date1} by Sirpdboy'" > ./package/base-files/files/etc/openwrt_release1
echo ${date1}' by Sirpdboy ' >> ./package/base-files/files/etc/banner
echo '---------------------------------' >> ./package/base-files/files/etc/banner

# cp -f package/build/shortcut-fe ./package/base-files/files/etc/init.d   21.02

#内核设置 甜糖
#cat ./package/build/set/Config-kernel.in   > ./config/Config-kernel.in
#echo  'CONFIG_BINFMT_MISC=y' >> ./package/target/linux/x86/config-5.4

#内核设置 甜糖
# find target/linux -path "target/linux/*/config-*" | xargs -i sed -i '$a CONFIG_ACPI=y\nCONFIG_X86_ACPI_CPUFREQ=y\n \
# CONFIG_NR_CPUS=128\nCONFIG_FAT_DEFAULT_IOCHARSET="utf8"\nCONFIG_CRYPTO_CHACHA20_NEON=y\nCONFIG_CRYPTO_CHACHA20POLY1305=y\nCONFIG_BINFMT_MISC=y' {}


echo '默认开启 Irqbalance'
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config
./scripts/feeds update -i
# 生成默认配置及缓存
# rm -rf .config

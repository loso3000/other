#!/bin/bash
#=================================================
# File name: preset-terminal-tools.sh
# System Required: Linux
# Version: 1.0
# Lisence: MIT
# Author: SuLingGG
# Blog: https://mlapp.cn
#=================================================

if [ $1 == amd64 ] ;then
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
mkdir -p files/root
cp  -rf ./package/other/patch/z.zshrc ./files/root/.zshrc
cp  -rf ./package/other/patch/profiles ./files/etc/profiles
pushd files/root

## Install oh-my-zsh
# Clone oh-my-zsh repository
git clone https://github.com/ohmyzsh/ohmyzsh ./.oh-my-zsh

# git clone https://github.com/robbyrussell/oh-my-zsh ./.oh-my-zsh
# Install extra plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ./.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ./.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ./.oh-my-zsh/custom/plugins/zsh-completions
popd

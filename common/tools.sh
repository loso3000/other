#!/bin/bash
#=================================================
# File name: preset-terminal-tools.sh
# System Required: Linux
# Version: 1.0
# Lisence: MIT
# Author: SuLingGG
# Blog: https://mlapp.cn
#=================================================

mkdir -p files/root
cp  -rf ./patch/z.zshrc ./files/root/.zshrc
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

## opkg ##
PLATFORM=$(cat .config | grep CONFIG_TARGET_ARCH_PACKAGES | awk -F '"' '{print $2}')
TARGET=$(cat .config | grep CONFIG_TARGET_BOARD | awk -F '"' '{print $2}')
SUBTARGET=$(cat .config |  grep CONFIG_TARGET | sed -n 2p | awk -F '=' '{print $1}')

mkdir -p files/etc/opkg
pushd files/etc/opkg
cat <<-EOF > "distfeeds.conf"
src/gz ezopwrt_core https://downloads.immortalwrt.org/releases/23.05-SNAPSHOT/targets/x86/64/packages
src/gz ezopwrt_base https://downloads.immortalwrt.org/releases/23.05-SNAPSHOT/packages/x86_64/base
src/gz ezopwrt_luci https://downloads.immortalwrt.org/releases/23.05-SNAPSHOT/packages/x86_64/luci
src/gz ezopwrt_packages https://downloads.immortalwrt.org/releases/23.05-SNAPSHOT/packages/x86_64/packages
src/gz ezopwrt_routing https://downloads.immortalwrt.org/releases/23.05-SNAPSHOT/packages/x86_64/routing
src/gz ezopwrt_telephony https://downloads.immortalwrt.org/releases/23.05-SNAPSHOT/packages/x86_64/telephony
EOF
cp distfeeds.conf distfeeds.conf.bak
popd

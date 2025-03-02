<!-- markdownlint-configure-file {
  "MD013": {
    "code_blocks": false,
    "tables": false,
    "line_length":200
  },
  "MD033": false,
  "MD041": false
} -->

[license]: /LICENSE
[license-badge]: https://img.shields.io/github/license/sirpdboy/luci-theme-kucat?style=flat-square&a=1
[prs]: https://github.com/sirpdboy/luci-theme-kucat/pulls
[prs-badge]: https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square
[issues]: https://github.com/sirpdboy/luci-theme-kucat/issues/new
[issues-badge]: https://img.shields.io/badge/Issues-welcome-brightgreen.svg?style=flat-square
[release]: https://github.com/sirpdboy/luci-theme-kucat/releases
[release-badge]: https://img.shields.io/github/v/release/sirpdboy/luci-theme-kucat?style=flat-square
[download]: https://github.com/sirpdboy/luci-theme-kucat/releases
[download-badge]: https://img.shields.io/github/downloads/sirpdboy/luci-theme-kucat/total?style=flat-square
[contact]: https://t.me/sirpdboy
[contact-badge]: https://img.shields.io/badge/Contact-telegram-blue?style=flat-square
[en-us-link]: /README.md
[zh-cn-link]: /README_ZH.md
[en-us-release-log]: /RELEASE.md
[zh-cn-release-log]: /RELEASE_ZH.md
[config-link]: https://github.com/sirpdboy/luci-app-advancedplus/releases
[lede]: https://github.com/coolsnowwolf/lede
[official]: https://github.com/openwrt/openwrt
[immortalwrt]: https://github.com/immortalwrt/immortalwrt

<div align="center">

# A brand new OpenWrt LuCI theme

Argon is **a clean and tidy OpenWrt LuCI theme** that allows<br/>
users to customize their login interface with images or videos.  
It also supports automatic and manual switching between light and dark modes.

[![license][license-badge]][license]
[![prs][prs-badge]][prs]
[![issues][issues-badge]][issues]
[![release][release-badge]][release]
[![download][download-badge]][download]
[![contact][contact-badge]][contact]

**English** |
[简体中文][zh-cn-link]

[Key Features](#key-features) ??
[Branch](#branch-introduction) ??
[Version History](#version-history) ??
[Getting started](#getting-started) ??
[Screenshots](#screenshots) ??
[Contributors](#contributors) ??
[Credits](#credits)

</div>

## Key Features

- Clean Layout.
- Adapted to mobile display.
- Customizable theme colors.
- Support for using Bing images as login background.
- Support for custom uploading of images or videos as login background.
- Automatically switch between light and dark modes with the system, and can also be set to a fixed mode.
- Settings plugin with extensions [luci-app-argon-config][config-link]

> **Upcoming Version **
>
> "The current theme uses Less for CSS construction, and the method for switching between light and dark modes is relatively primitive. Meanwhile, the official theme has already switched to the UT template. I am exploring a way to build the theme template using modern front-end development tools, initially settling on a solution using Vite + UnoCSS. This approach will utilize a proxy server for debugging and also support HMR (Hot Module Replacement), significantly improving development speed. Currently, the basic development framework has been set up, but due to a busy schedule, I still need some time to migrate the existing styles. Stay tuned!"

## Branch Introduction

There are currently two main branches that are adapted to different versions of the **OpenWrt** source code.  
The table below will provide a detailed introduction:

| Branch | Version | Description                        | Matching source                                           |
| ------ | ------- | ---------------------------------- | --------------------------------------------------------- |
| master | v2.x.x  | Support the latest version of LuCI | [Official OpenWrt][official] ??[ImmortalWrt][immortalwrt] |
| 18.06 (deprecated) | v1.x.x  | Support the 18.06 version of LuCI   | [Lean's LEDE][lede]                                         |

## Version History

The latest version is v2.3.1 [Click here][en-us-release-log] to view the full version history record.

## Getting started

### Build for Lean's LEDE project (deprecated)

```bash
cd lede/package/lean
rm -rf luci-theme-kucat
git clone -b 18.06 https://github.com/sirpdboy/luci-theme-kucat.git luci-theme-kucat
make menuconfig #choose LUCI->Theme->Luci-theme-argon
make -j1 V=s
```

### Build for OpenWrt official SnapShots and ImmortalWrt

```bash
cd openwrt/package
git clone https://github.com/sirpdboy/luci-theme-kucat.git
make menuconfig #choose LUCI->Theme->Luci-theme-kucat
make -j1 V=s
```

### Install for LuCI 18.06 ( Lean's LEDE )

```bash
wget --no-check-certificate https://github.com/sirpdboy/luci-theme-kucat/releases/download/v1.8.2/luci-theme-argon_1.8.2-20230609_all.ipk
opkg install luci-theme-argon*.ipk
```

### Install for OpenWrt official SnapShots and ImmortalWrt

```bash
opkg install luci-compat
opkg install luci-lib-ipkg
wget --no-check-certificate https://github.com/sirpdboy/luci-theme-kucat/releases/download/v2.3.2/luci-theme-argon_2.3.2-r20250207_all.ipk
opkg install luci-theme-argon*.ipk
```

### Install luci-app-argon-config

```bash
wget --no-check-certificate https://github.com/jerrykuku/luci-app-argon-config/releases/download/v0.9/luci-app-argon-config_0.9_all.ipk
opkg install luci-app-argon-config*.ipk
```

## Notice

- Chrome browser is highly recommended. There are some new css3 features used in this theme, currently only Chrome has the best compatibility.
- Microsoft has officially retired Internet Explorer, RIP IE?<del>Currently, the mainline version of the IE series has bugs that need to be addressed.</del>
- FireFox does not enable the backdrop-filter by default, [see here](https://developer.mozilla.org/zh-CN/docs/Web/CSS/backdrop-filter) for the opening method.

## Screenshots

![desktop](/Screenshots/screenshot_pc.jpg)
![mobile](/Screenshots/screenshot_phone.jpg)

## Contributors

<a href="https://github.com/sirpdboy/luci-theme-kucat/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=sirpdboy/luci-theme-kucat&v=2" />
</a>

Made with [contrib.rocks](https://contrib.rocks).

## Related Projects

- [luci-app-argon-config](https://github.com/jerrykuku/luci-app-argon-config): Argon theme config plugin
- [openwrt-package](https://github.com/jerrykuku/openwrt-package): My OpenWrt package
- [CasaOS](https://github.com/IceWhaleTech/CasaOS): A simple, easy-to-use, elegant open-source Personal Cloud system (My current main project)

## Credits

[luci-theme-material](https://github.com/LuttyYang/luci-theme-material/)

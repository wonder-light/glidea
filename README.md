<div align="center">
  <img src="docs/assets/images/logo.png" alt="logo" width="80px" height="80px">
  <h1 align="center">Glidea</h1>
  <h3 align="center">一个静态博客写作客户端</h3>

  [下 载](https://github.com/wonder-light/glidea/releases) | [主 页](https://glidea.nianian.cn/)

  <a href="https://github.com/wonder-light/glidea/releases/latest">
    <img src="https://img.shields.io/github/release/wonder-light/glidea.svg?style=flat-square" alt="release">
  </a>
  <a href="https://github.com/wonder-light/glidea/blob/master/LICENSE">
    <img src="https://img.shields.io/github/license/wonder-light/glidea.svg?style=flat-square" alt="license">
  </a>
  <a href="https://github.com/wonder-light/glidea/releases/latest">
    <img src="https://img.shields.io/github/downloads/wonder-light/glidea/total.svg?color=%2312b886&style=flat-square" alt="GitHub All Releases">
  </a>
</div>

[English](README-en.md) | 简体中文

**[更新日志](CHANGELOG.md)** | [LICENSE](LICENSE)

👏  欢迎使用 **Glidea** ！

✍️  **Glidea** 一个静态博客写作客户端, 可以用来记录你的生活、心情、想法...

# 特性👇
📝  你可以使用简洁的 **Markdown** 语法，进行快速创作

🌉  你可以给文章配上精美的封面图和在文章任意位置插入图片

🏷️  你可以对文章进行标签分组

📋  你可以自定义菜单，可以创建外部链接菜单

💻  你可以在桌面端或移动端设备上使用此客户端

🌎  你可以使用 **𝖦𝗂𝗍𝗁𝗎𝖻 𝖯𝖺𝗀𝖾𝗌** 向世界展示，未来将支持更多平台

<!--
💬  你可以进行简单的配置，接入 [Gitalk](https://github.com/gitalk/gitalk) 或 [DisqusJS](https://github.com/SukkaW/DisqusJS) 评论系统
-->

🗺️  你可以使用**中文简体**、**英语**等等

🌁  你可以任意使用默认主题或任意第三方主题，有强大的主题自定义能力

🖥  你可以自定义源文件夹，利用 OneDrive、百度网盘等进行多设备同步

💪 让我们一起携手前行，迎接更加美好的未来!

# 示例截图
<div align="center">
  <img src="docs/assets/images/themes.png">
</div>

# 开发
如果你想贡献代码，请提前参阅[贡献指南](https://github.com/wonder-light/glidea/wiki/%E8%B4%A1%E7%8C%AE%E6%8C%87%E5%8D%97)

## 开始

```shell
# 克隆仓库 Glidea
> git clone https://github.com/wonder-light/glidea.git

# 运行下载依赖项
> flutter pub get

# 构建 json 反射数据
> dart run build_runner build --delete-conflicting-outputs

# 运行以启动应用程序
> flutter run
```

## Flutter 版本
```shell
> flutter --version

Flutter 3.27.3 • channel stable • https://github.com/flutter/flutter.git
Framework • revision c519ee916e (3 days ago) • 2025-01-21 10:32:23 -0800
Engine • revision e672b006cb
Tools • Dart 3.6.1 • DevTools 2.40.2
```
## 构建

### Android

传统APK

```shell
> flutter build apk
```

适用于 Google Play 的 AppBundle

```shell
> flutter build appbundle
```

### Ios

```shell
> flutter build ipa
```

### MacOS

```shell
> flutter build macos
```

### Windows

传统

```shell
> flutter build windows
```

本地 MSIX 应用程序

```shell
# 安装 flutter_distributor
> dart pub global activate flutter_distributor

# 构建 MSIX
> flutter_distributor package --platform windows --targets msix
```

### Linux

传统

```shell
> flutter build linux
```

deb

```shell
# 安装 flutter_distributor
> dart pub global activate flutter_distributor

# 构建 deb
> flutter_distributor package --platform linux --targets deb
```

---

+ [Flutter 环境配置](https://github.com/toly1994328/FlutterUnit/issues/22)
+ [Flutter 实用插件集录](https://github.com/toly1994328/FlutterUnit/issues/41)

---

## 支持
<img src="docs/assets/images/reward_qrcode.png" width="300px" height="300px" alt="赞赏码">

## License
[MIT](LICENSE). Copyright (c) 2024 wonder-light

## 贡献

<a href="https://github.com/wonder-light/glidea/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=wonder-light/glidea"  alt="Glidea 贡献"/>
</a>
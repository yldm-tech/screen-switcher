# Screen Switcher

[English](README.md) · [贡献指南](CONTRIBUTING.md) · [MIT 许可证](LICENSE)

轻量的 macOS 原生菜单栏工具，用于切换镜像与扩展显示。Swift / AppKit 实现，无第三方依赖。

**早期版本**：构建和资源检查已自动化，真实多屏硬件及完整 UI 验证尚未完成，暂不提供公证后的二进制发行版。

## 功能

- 镜像开关：打开为镜像，关闭为扩展。
- 镜像时选择主屏，其他屏幕镜像它。
- 显示器变化后自动刷新状态。
- 主菜单直接设置登录启动和语言。
- 默认跟随系统，支持中、英、日、韩、西、法、德语。
- 配套 App 图标与菜单栏单色图标。

## 构建与运行

需要 macOS 13+，以及带 Swift 5.9+ 的 Xcode 或 Apple Command Line Tools。

```sh
git clone https://github.com/yldm-tech/screen-switcher.git
cd screen-switcher
sh build-app.sh
open dist/ScreenSwitcher.app
```

产物使用临时签名，适用于当前构建机器架构，并非通用或公证发行版。请运行打包的 App，
避免通过 `swift run` 验证通知、图标和登录启动集成。启用登录启动前，请将 App 放到固定位置。

开启镜像后，通过“镜像主屏”选择来源。无法取得名称时显示屏幕编号。
主屏选择反映当前会话，不保存为布局预设。

## 验证

```sh
sh Scripts/verify.sh
```

检查 Debug/Release 构建、翻译完整性、语言解析与打包资源读取、图标和签名。
不会更改真实显示器配置。硬件验证范围见 [手动检查清单](docs/TESTING.md)。

## 限制

- 配置仅作用于当前会话；不同屏幕比例可能产生黑边或缩放。
- 镜像主屏选择镜像来源，不是独立分辨率预设或永久的 macOS 主显示器设置。
- 部分虚拟显示器、转接器和多屏组合可能不支持指定模式。
- 登录启动可能需要系统设置批准，真实硬件与菜单交互仍需手动验证。
- 没有超时自动回滚。显示异常时请关闭镜像或前往系统设置 → 显示器调整。

## 隐私与贡献

不实现联网请求、统计分析或屏幕采集。屏幕信息只在本机读取，语言偏好保存在 UserDefaults 中。
通知权限可选。欢迎提交 Issue 或 Pull Request；请勿上传包含个人信息的日志或截图。

代码与图标绘图源文件均采用 [MIT 许可证](LICENSE)。

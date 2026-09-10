# Screen Switcher

[English](README.md) · [贡献指南](CONTRIBUTING.md) · [MIT 许可证](LICENSE)

轻量的 macOS 原生菜单栏工具，用于切换镜像与扩展显示。Swift / AppKit 实现，无第三方依赖。

**早期版本**：构建和资源检查已自动化，真实多屏硬件及完整 UI 验证尚未完成。

## 下载

[下载已签名并经 Apple 公证的 DMG](https://github.com/yldm-tech/screen-switcher/releases/latest/download/ScreenSwitcher-AppleSilicon.dmg)，适用于 macOS 13+ 的 Apple Silicon Mac。打开 DMG，将 ScreenSwitcher 拖入 Applications（应用程序）即可。App 和 DMG 都附有公证票据。[发行页面](https://github.com/yldm-tech/screen-switcher/releases/latest)提供 SHA-256 校验文件。Intel Mac 可按下方说明从源码构建。

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
open apps/macos/dist/ScreenSwitcher.app
```

产物使用临时签名，适用于当前构建机器架构，并非通用或公证发行版。请运行打包的 App，
避免通过 `swift run` 验证通知、图标和登录启动集成。启用登录启动前，请将 App 放到固定位置。

### Developer ID 签名

用 `asc certificates list --certificate-type DEVELOPER_ID_APPLICATION --fields name,serialNumber,expirationDate` 查询 Apple 证书。下载证书不等于拥有签名能力，钥匙串还必须有对应私钥。用 `security find-identity -v -p codesigning` 查看可用身份，然后传入 Developer ID Application 的 SHA-1 指纹：

```sh
SIGNING_IDENTITY="YOUR_DEVELOPER_ID_SHA1" sh build-app.sh
SIGNING_IDENTITY="YOUR_DEVELOPER_ID_SHA1" sh apps/macos/Tests/check-signing.sh
```

指定身份后会启用强化运行时和安全时间戳，需要联网；签名失败会中止，不会退回临时签名。不设置 `SIGNING_IDENTITY` 时仍使用临时签名。这不包含公证或 CI 凭据配置。不要提交私钥或签名凭据。参考 [ASC 签名文档](https://docs.asccli.sh/guides/code-signing)。

主仓库的 `macOS validation` 工作流在 `main` 验证通过后构建并公证 Apple Silicon DMG。读取签名 Secrets：`BUILD_CERTIFICATE_BASE64`（加密 P12 的 Base64）、`P12_PASSWORD`、`SIGNING_IDENTITY`（SHA-1 指纹），以及公证 Secrets：`APPLE_API_KEY_BASE64`、`APPLE_API_KEY_ID`、`APPLE_API_ISSUER_ID`。App 和 DMG 均附加公证票据并通过 Gatekeeper 检查，随后上传 `ScreenSwitcher-notarized-dmg` 及 SHA-256 校验文件，保留七天。PR 和 Fork 仅运行普通临时签名检查。即使任务失败也会清理签名材料，产物不包含凭据。

发布时，将 `apps/macos/Info.plist` 中的 `CFBundleShortVersionString` 改为尚未使用的 `主.次.修订` 版本，推送至 `main` 后手动运行工作流，设置 `publish_release=true`。只有成功公证的 DMG 才会发布，不覆盖已有版本。如果公证等待超时，Apple 可能仍在处理，应先检查公证历史，避免重复提交。P12 必须通过 macOS 的 `security import` 验证，不能仅依赖 OpenSSL；不兼容的 PKCS#12 算法可能产生误导性的“密码错误”提示。

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

## Monorepo

原生 App 在 `apps/macos`，官网在 `apps/web`。官网使用 Node.js 22+：执行 `npm ci` 后运行 `npm run dev`。
`npm run build:web` 构建静态官网。域名与部署说明见 [DEPLOYMENT.md](docs/DEPLOYMENT.md)。

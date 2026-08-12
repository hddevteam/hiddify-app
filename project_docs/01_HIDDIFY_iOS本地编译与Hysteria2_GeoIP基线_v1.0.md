# Hiddify iOS 本地编译与 Hysteria2/GeoIP 基线 MVP 实施计划

**目标：** 在个人公开 fork 中完成 Hiddify iOS 模拟器构建基线，并验证 Hysteria2、GeoIP/GeoSite 配置入口和 iOS Packet Tunnel 工程结构。

**当前结论：** 已修复 App Group 容器不可用导致的启动崩溃，并重新完成模拟器安装启动。连接的实体 iPhone 已识别，但真机安装暂时受签名团队缺少 App Group、Network Extension 和 Personal VPN Profile 阻塞。

## 范围

- 包含：Flutter 依赖恢复、CocoaPods、iOS Runner/Packet Tunnel 模拟器构建、启动观察、Hysteria2 配置解析检查、GeoIP/GeoSite 资源检查。
- 不包含：App Store 发布、商业分发、真实订阅账号、未脱敏的节点配置或密码入库。
- 真机 VPN 隧道必须单独验证；模拟器启动不能证明 Network Extension 真机能力。

## 基线

- 分支：`agent/mvp01-ios-build`
- 本地路径：`/Users/ming/projects/hiddify-app-mvp01-ios`
- Flutter 要求：`^3.38.5`
- Dart 要求：`^3.10.4`
- iOS Packet Tunnel 工程：`ios/HiddifyPacketTunnel`
- iOS 构建工程：`ios/Runner.xcworkspace`
- Hiddify 核心：`HiddifyCore.xcframework` / sing-box bridge
- 远端：`origin=https://github.com/hddevteam/hiddify-app.git`，`upstream=https://github.com/hiddify/hiddify-app.git`

## 验收标准

- [x] `flutter pub get` 成功并生成 `.dart_tool/package_config.json`。
- [x] `pod install` 成功，`Runner.xcworkspace` 可用于构建。
- [x] iOS Runner 和 `HiddifyPacketTunnel` 模拟器构建成功。
- [x] App 已安装并启动到固定 iPhone 17 Pro Max 模拟器。
- [ ] 使用脱敏配置确认 Hysteria2 节点字段可导入或转换。
- [ ] 确认 GeoIP/GeoSite 数据库或 sing-box rule-set 的来源、下载和更新路径。
- [ ] 不提交证书、私钥、profile、节点密码或订阅 URL。

## 当前阻塞证据

### 在线依赖解析

`flutter pub get` 多次停留在 `Resolving dependencies...`，当前 shell 使用 `HTTP_PROXY/HTTPS_PROXY=http://127.0.0.1:7890`。直接访问 `https://pub.dev/api/packages/intl` 失败：

```text
curl: (35) LibreSSL SSL_connect: SSL_ERROR_SYSCALL in connection to pub.dev:443
```

### 离线依赖解析

```text
Because hiddify depends on dart_mappable_builder any which doesn't exist
(could not find package dart_mappable_builder in cache), version solving failed.
```

## 已通过阶段

- `flutter pub get`：通过。使用临时环境变量 `PUB_HOSTED_URL=https://pub.flutter-io.cn`，未修改仓库配置。
- `flutter precache --ios`：通过。
- `make ios-libs`：通过，从 Hiddify Core draft release 下载并解压 `HiddifyCore.xcframework`；包含 iOS arm64 和 iOS Simulator arm64/x86_64 slice，版本 4.1.0，最低 iOS 15.0。
- 首次模拟器构建已确认原始核心问题：仓库中的 `ios/Frameworks/HiddifyCore.xcframework` 只有 `.gitkeep` 和旧的 `Libcore.xcframework.zip`，不含可识别的二进制 artifact；运行 `make ios-libs` 后已解决。
- CocoaPods SQLite 官方源下载速度过低；本次构建使用本地临时 SQLite 3.52.0 源码副本完成依赖安装，未将临时路径提交到仓库。
- HiddifyCore 4.1.0 的 Libbox Swift 协议比仓库旧接口多出方法，并将 DNS 地址改为迭代器；已在 `ExtensionPlatformInterface.swift` 做最小兼容调整。
- 项目锁定的依赖需要 Flutter 3.38.5；Flutter 3.44.9 会因 `IconData` final 导致图标包编译失败。
- `FilePath` 现在优先使用 App Group，无法取得容器时回退到 Application Support；回退和 App Group 两条路径均通过 XCTest。
- Bundle ID 已切换为 `com.luckyxmobile.hiddify`，签名团队配置切换为本机个人团队 `34D596WSR8`；仍需该团队在 Apple Developer 中创建对应 App ID、App Group、Network Extension/Personal VPN Profile。

## 下一步

1. 人工观察模拟器首页和配置导入流程。
2. 使用脱敏 Hysteria2 配置确认导入、解析和启动路径。
3. 确认 GeoIP/GeoSite 数据库或 sing-box rule-set 的来源、下载和更新路径。
4. 再评估是否将 SQLite 下载缓存和 Flutter 3.38.5 工具链写入可复现脚本。

## 执行顺序

1. 恢复在线 Pub 访问，或确认完整 Pub 缓存。
2. 执行 `flutter pub get` 和 `flutter analyze`。
3. 执行 `flutter precache --ios`、`pod install`。
4. 在固定 iOS 模拟器上构建、安装、启动 Runner。
5. 检查 Packet Tunnel target、entitlements、bundle identifier 和 HiddifyCore framework。
6. 使用脱敏 Hysteria2/GeoIP 配置执行解析和真机验证。

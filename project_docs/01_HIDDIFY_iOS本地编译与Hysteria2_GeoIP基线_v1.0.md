# Hiddify iOS 本地编译与 Hysteria2/GeoIP 基线 MVP 实施计划

**目标：** 在个人公开 fork 中完成 Hiddify iOS 模拟器构建基线，并验证 Hysteria2、GeoIP/GeoSite 配置入口和 iOS Packet Tunnel 工程结构。

**当前结论：** Hiddify 工程包含 `HiddifyPacketTunnel`、`HiddifyCore.xcframework` 引用和 sing-box GeoIP/GeoSite 路由配置；Flutter 依赖和核心框架已恢复，当前阻塞在 CocoaPods 下载 SQLite 源码包。

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

- [ ] `flutter pub get` 成功并生成 `.dart_tool/package_config.json`。
- [ ] `pod install` 成功，`Runner.xcworkspace` 可用于构建。
- [ ] iOS Runner 和 `HiddifyPacketTunnel` 模拟器构建成功。
- [ ] App 可安装、启动并完成首页人工观察。
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

## 当前阻塞：CocoaPods SQLite 下载

`pod install --no-repo-update` 已开始安装依赖，但在下载 `sqlite3` 的源码包时长时间停滞：

```text
https://www.sqlite.org/2026/sqlite-src-3520000.zip
```

当前没有把未完成的下载包加入仓库，也没有修改 Podfile 来绕过该依赖。需要网络下载完成或准备可信的 CocoaPods 缓存后，继续执行 `pod install --no-repo-update`。

## 下一步

1. 完成 SQLite CocoaPods 依赖下载并让 `pod install` 退出码为 0。
2. 在 `flutter config --no-enable-swift-package-manager` 下重试构建；Xcode 26.6 曾在 Flutter 自动添加 SPM 集成时触发内部异常，已记录为工具链兼容性风险。
3. 运行 `flutter build ios --simulator --debug`，再安装和启动固定的 iPhone 17 Pro Max 模拟器。

## 执行顺序

1. 恢复在线 Pub 访问，或确认完整 Pub 缓存。
2. 执行 `flutter pub get` 和 `flutter analyze`。
3. 执行 `flutter precache --ios`、`pod install`。
4. 在固定 iOS 模拟器上构建、安装、启动 Runner。
5. 检查 Packet Tunnel target、entitlements、bundle identifier 和 HiddifyCore framework。
6. 使用脱敏 Hysteria2/GeoIP 配置执行解析和真机验证。

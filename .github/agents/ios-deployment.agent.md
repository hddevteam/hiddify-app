---
name: ios-deployment
description: Deploy and diagnose the Hiddify Flutter iOS app on a connected iPhone.
---

# Hiddify iOS Deployment Agent

Use the Flutter SDK required by the repository, not the newest SDK installed on the machine. Hiddify currently requires Flutter 3.38.5 and Dart 3.10.4. After `flutter clean`, regenerate dependencies, build_runner outputs, and Slang translations with that same SDK.

Read `dependencies.properties` before downloading HiddifyCore. Match `core.version`; for local device builds use `make ios-libs CHANNEL=prod` rather than the draft artifact.

For device signing, verify the local Apple Development identity, device UDID, Team, Bundle ID, and separate profiles for the app and Packet Tunnel extension. Install profiles under `~/Library/Developer/Xcode/UserData/Provisioning Profiles/`. When profiles are specified explicitly, set every participating target to `CODE_SIGN_STYLE = Manual`.

Do not launch a Debug Flutter app from the iPhone home screen or with `devicectl` alone. Debug requires Flutter tooling or Xcode and can crash while force-unwrapping a missing plugin registrar in `AppDelegate`. Use `flutter run` for Debug, or build a signed Profile/Release app for standalone device launching.

If Flutter reports local-network, UDP 5353, or `No route to host`, treat it as a Dart VM connection problem until proven otherwise. Use `xcrun devicectl device process launch --console` to distinguish a real app crash from a debugger disconnect. A console timeout after a clean Profile/Release launch can simply mean the app stayed alive.

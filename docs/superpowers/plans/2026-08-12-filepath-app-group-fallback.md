# FilePath App Group Fallback Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Prevent Hiddify from crashing at launch when an unsigned simulator build cannot resolve its App Group container, while preserving the App Group path on signed iPhone builds.

**Architecture:** Keep `FilePath` as the single directory resolver. It will prefer the App Group URL and fall back to an app-local Application Support directory only when the group URL is unavailable. A focused XCTest will cover both resolver branches, followed by a signed-device build/install/launch verification.

**Tech Stack:** Swift, Foundation, XCTest, Xcode, Flutter iOS build tooling.

## Global Constraints

- Preserve `group.$(BASE_BUNDLE_IDENTIFIER)` for signed device builds.
- Do not change entitlements, bundle identifiers, or VPN behavior.
- Do not commit certificates, profiles, private keys, node configurations, or subscription URLs.
- Use the existing connected iPhone and existing local signing configuration.

---

### Task 1: Add the failing directory-resolution test

**Files:**
- Modify: `ios/Shared/FilePath.swift`
- Modify: `ios/RunnerTests/RunnerTests.swift`
- Modify: `ios/Runner.xcodeproj/project.pbxproj` to compile `FilePath.swift` in `RunnerTests`.

- [ ] Add a test for the unavailable App Group case that expects the Application Support fallback.
- [ ] Add a test for the available App Group case that expects the App Group URL unchanged.
- [ ] Run the focused XCTest and confirm the fallback test fails against the current force-unwrapped implementation.

### Task 2: Implement the minimal fallback

**Files:**
- Modify: `ios/Shared/FilePath.swift`

- [ ] Add a resolver that accepts an optional group URL, Application Support URL, and package name.
- [ ] Return the group URL when non-nil; otherwise return `<Application Support>/<packageName>`.
- [ ] Replace the force-unwrapped global group directory with this resolver.
- [ ] Run the focused XCTest and confirm both branches pass.

### Task 3: Build and verify on the connected iPhone

**Files:**
- No source changes expected.

- [ ] Detect the connected iPhone UDID and signing identity.
- [ ] Run the project's generated-code/dependency prerequisites with Flutter 3.38.5.
- [ ] Build the iOS app for the connected device using the existing signing configuration.
- [ ] Install and launch the app on the connected iPhone.
- [ ] Read device application metadata and launch logs to verify it remains running past AppDelegate initialization.

### Task 4: Commit and push the verified fix

**Files:**
- Commit only the focused Swift fix, test/project membership, and relevant documentation.

- [ ] Run `git diff --check` and the focused test/build verification.
- [ ] Commit with `fix: avoid App Group startup crash without container`.
- [ ] Push `agent/mvp01-ios-build` and verify the remote commit matches HEAD.

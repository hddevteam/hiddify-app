import Flutter
import UIKit
import XCTest

class RunnerTests: XCTestCase {

  func testSharedDirectoryUsesApplicationSupportWhenAppGroupIsUnavailable() {
    let applicationSupport = URL(fileURLWithPath: "/tmp/application-support", isDirectory: true)

    let result = FilePath.resolvedSharedDirectory(
      appGroupDirectory: nil,
      applicationSupportDirectory: applicationSupport,
      packageName: "apple.hiddify.com"
    )

    XCTAssertEqual(
      result,
      applicationSupport.appendingPathComponent("apple.hiddify.com", isDirectory: true)
    )
  }

  func testSharedDirectoryPrefersAppGroupWhenAvailable() {
    let appGroup = URL(fileURLWithPath: "/tmp/app-group", isDirectory: true)
    let applicationSupport = URL(fileURLWithPath: "/tmp/application-support", isDirectory: true)

    let result = FilePath.resolvedSharedDirectory(
      appGroupDirectory: appGroup,
      applicationSupportDirectory: applicationSupport,
      packageName: "apple.hiddify.com"
    )

    XCTAssertEqual(result, appGroup)
  }

}

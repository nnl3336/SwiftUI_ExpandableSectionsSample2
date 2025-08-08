//
//  SwiftUI_ExpandableSectionsSample2UITestsLaunchTests.swift
//  SwiftUI_ExpandableSectionsSample2UITests
//
//  Created by Yuki Sasaki on 2025/08/08.
//

import XCTest

final class SwiftUI_ExpandableSectionsSample2UITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

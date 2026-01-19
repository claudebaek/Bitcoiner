//
//  ScreenshotTests.swift
//  BitcoinerUITests
//
//  Created for App Store Screenshots
//

import XCTest

@MainActor
final class ScreenshotTests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["UI_TESTING"]
        setupSnapshot(app)
        app.launch()
        
        // Wait for launch screen to dismiss
        sleep(3)
    }
    
    func testTakeScreenshots() throws {
        // 1. Dashboard - Main screen with Bitcoin price
        snapshot("01_Dashboard")
        
        // Scroll down to see more content
        app.swipeUp()
        sleep(1)
        snapshot("02_Dashboard_Debt")
        
        // Scroll back up
        app.swipeDown()
        sleep(1)
        
        // 2. Market Tab
        let tabBar = app.tabBars.firstMatch
        tabBar.buttons.element(boundBy: 1).tap()
        sleep(2)
        snapshot("03_Market_Mining")
        
        // 3. Positions Tab
        tabBar.buttons.element(boundBy: 2).tap()
        sleep(2)
        snapshot("04_Positions")
        
        // 4. Learn Tab
        tabBar.buttons.element(boundBy: 3).tap()
        sleep(2)
        snapshot("05_Learn")
        
        // 5. Settings Tab
        tabBar.buttons.element(boundBy: 4).tap()
        sleep(2)
        snapshot("06_Settings")
    }
}

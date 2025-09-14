//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Алена Апарина on 11.09.2025.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        app = XCUIApplication()
        app.launch()

        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        app.terminate()
        app = nil
    }

    func testYesButton() throws {
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["Yes"].tap()

        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        let indexLabel = app.staticTexts["Index"]

        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }

    func testNoButton() throws {
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["No"].tap()

        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        let indexLabel = app.staticTexts["Index"]

        XCTAssertFalse(firstPosterData == secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }

    func testShowResultsAllert() throws {
        sleep(2)
        for _ in 1 ... 10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        let alert = app.alerts["Этот раунд окончен!"]

        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.buttons.firstMatch.exists)
    }

    func testDismissResultsAllert() throws {
        sleep(2)
        for _ in 1 ... 10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }

        let alert = app.alerts["Этот раунд окончен!"]
        alert.buttons.firstMatch.tap()
        sleep(2)

        let indexLabel = app.staticTexts["Index"]

        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }
}

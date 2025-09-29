//
//  MovieQuizPresenterTests.swift
//  MovieQuiz
//
//  Created by Алена Апарина on 14.09.2025.
//
@testable import MovieQuiz
import XCTest

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func showAnswerResult(isCorrect: Bool) { }

    func show(quiz step: QuizStepModel) { }

    func show(quiz result: QuizResult) { }

    func highlightImageBorder(isCorrectAnswer: Bool) { }

    func showLoadingIndicator() { }

    func hideLoadingIndicator() { }

    func showNetworkError(message: String) { }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)

        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, question: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)

        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}

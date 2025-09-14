//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Алена Апарина on 14.09.2025.
//
import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepModel)
    func show(quiz result: QuizResult)
    func showAnswerResult(isCorrect: Bool)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}

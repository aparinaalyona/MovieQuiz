//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Алена Апарина on 28.08.2025.
//

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}

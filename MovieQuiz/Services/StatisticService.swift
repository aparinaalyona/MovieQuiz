//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Алена Апарина on 28.08.2025.
//
import Foundation

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard

    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case totalCorrectAnswers
        case totalQuestionsAsked
    }

    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()

            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.correct, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.correct, forKey: Keys.bestGameDate.rawValue)
        }
    }

    var totalAccuracy: Double {
        let totalQuestions = totalQuestionsAsked
        guard totalQuestions > 0 else {
            return 0.0
        }
        let accuracy = Double(totalCorrectAnswer) / Double(totalQuestions) * 100
        return accuracy
    }

    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        totalCorrectAnswer += count
        totalQuestionsAsked += amount

        let gameResult = GameResult(correct: count, total: amount, date: Date())

        if gameResult.checkResults(bestGame) {
            bestGame = gameResult
        }
    }

    private var totalCorrectAnswer: Int {
        get {
            storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }

    private var totalQuestionsAsked: Int {
        get {
            storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue)
        }
    }
}

//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Алена Апарина on 28.08.2025.
//
import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func checkResults(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}

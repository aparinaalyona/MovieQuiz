//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Алена Апарина on 27.08.2025.
//
import UIKit

class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var currentIndex = 0

    //    private var questions: [QuizQuestion] = [
    //        QuizQuestion(image: "The Godfather", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(image: "The Dark Knight", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(image: "Kill Bill", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(image: "The Avengers", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(image: "Deadpool", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(image: "The Green Knight", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(image: "Old", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    //        QuizQuestion(
    //            image: "The Ice Age Adventures of Buck Wild",
    //            question: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: false
    //        ),
    //        QuizQuestion(image: "Tesla", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    //        QuizQuestion(image: "Vivarium", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    //    ]

    private var movies: [MostPopularMovie] = []

    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case let .success(mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case let .failure(error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0 ..< self.movies.count).randomElement() ?? 0

            guard let movie = self.movies[safe: index] else { return }

            var imageData = Data()

            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }

            let rating = Float(movie.rating) ?? 0

            let text = "Рейтинг этого фильма больше чем 8?"
            let correctAnswer = rating > 7

            let question = QuizQuestion(
                image: imageData,
                question: text,
                correctAnswer: correctAnswer
            )

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }

    func restart() {
        movies.shuffle()
        currentIndex = 0
    }
}

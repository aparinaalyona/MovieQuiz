import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - IBOutlets
    @IBOutlet private var idexLabel: UILabel!
    @IBOutlet private var previewImage: UIImageView!
    @IBOutlet private var questionTitle: UILabel!
    @IBOutlet private var questionTitleLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    private var correctAnswers: Int = 0

    private var currentQuestionIndex: Int = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureServices()
        configureUI()
    }

    private func configureServices() {
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
    }

    private func configureUI() {
        idexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionTitle.font = UIFont(name: "YSDisplay-Bold", size: 23)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
    }

    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }

    // MARK: - IBActions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        handleAnswer(true)
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        handleAnswer(false)
    }

    private func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }

    private func handleAnswer(_ givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        setButtonsEnabled(false)
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    // MARK: - Private Methods
    private func convert(model: QuizQuestion) -> QuizStepModel {
        let questionStep = QuizStepModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.question,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionStep
    }

    private func show(quiz step: QuizStepModel) {
        previewImage.image = step.image
        idexLabel.text = step.questionNumber
        questionTitle.text = step.question
        setButtonsEnabled(true)
    }

    private func show(quiz result: QuizResult) {
        let bestGame = statisticService.bestGame
        let totalAccuracy = String(format: "%.2f", statisticService.totalAccuracy)

        let message = """
        Ваш результат: \(result.correct)/\(result.total)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
            Средняя точность: \(totalAccuracy)%
        """

        let model = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText
        ) { [weak self] in
            self?.restartGame()
        }

        alertPresenter.show(in: self, model: model)
    }

    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.restart()
        questionFactory?.requestNextQuestion()
    }

    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        previewImage.layer.borderWidth = 0
        previewImage.layer.borderColor = UIColor.clear.cgColor
        if currentQuestionIndex == questionsAmount - 1 {
            let text = "Ваш результат: \(correctAnswers)/10"
            let viewModel = QuizResult(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз",
                correct: correctAnswers,
                total: questionsAmount
            )
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }

    private func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.stopAnimating()
    }

    private func showNetworkError(message: String) {
        showLoadingIndicator()
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попрбовать еще раз"
        ) {
            [weak self] in
            guard let self = self else { return }

            self.correctAnswers = 0
            self.currentQuestionIndex = 0
            self.loadViewIfNeeded()
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter.show(in: self, model: model)
    }
}

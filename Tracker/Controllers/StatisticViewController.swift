import UIKit

final class StatisticViewController: UIViewController {
    private let colors = Colors()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerCategoryStore = TrackerCategoryStore()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics.title", comment: "")
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let cardsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var bestPeriodCard = StatisticCardView(title: NSLocalizedString("statistics.bestPeriod", comment: ""))
    private lazy var idealDaysCard = StatisticCardView(title: NSLocalizedString("statistics.idealDays", comment: ""))
    private lazy var completedCard = StatisticCardView(title: NSLocalizedString("statistics.completed", comment: ""))
    private lazy var averageCard = StatisticCardView(title: NSLocalizedString("statistics.average", comment: ""))

    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "empty_statistics") ?? UIImage(systemName: "face.dashed")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics.empty.title", comment: "")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colors.viewBackgroundColor
        titleLabel.textColor = colors.primaryTextColor
        placeholderLabel.textColor = colors.primaryTextColor

        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistics()
    }

    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(cardsStackView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)

        [bestPeriodCard, idealDaysCard, completedCard, averageCard].forEach {
            cardsStackView.addArrangedSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            cardsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            cardsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            placeholderImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),

            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func updateStatistics() {
        let records = Array(trackerRecordStore.records)
        let categories = trackerCategoryStore.categories
        let allTrackers = categories.flatMap { $0.trackers }

        let isEmpty = records.isEmpty
        cardsStackView.isHidden = isEmpty
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty

        guard !isEmpty else { return }

        let calendar = Calendar.current
        let recordsByDay = Dictionary(grouping: records) { calendar.startOfDay(for: $0.date) }
        let sortedDays = recordsByDay.keys.sorted()
        var bestStreak = 0
        var currentStreak = 0
        var previousDay: Date?

        for day in sortedDays {
            if let prev = previousDay,
               let nextDay = calendar.date(byAdding: .day, value: 1, to: prev),
               calendar.isDate(day, inSameDayAs: nextDay) {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
            bestStreak = max(bestStreak, currentStreak)
            previousDay = day
        }
        var posixCalendar = Calendar(identifier: .gregorian)
        posixCalendar.locale = Locale(identifier: "en_US_POSIX")

        var idealDaysCount = 0
        for (day, dayRecords) in recordsByDay {
            let weekdayNumber = posixCalendar.component(.weekday, from: day)
            guard let weekDay = WeekDay(rawValue: weekdayNumber) else { continue }

            let scheduledTrackers = allTrackers.filter { tracker in
                guard let schedule = tracker.schedule, !schedule.isEmpty else { return true }
                return schedule.contains(weekDay)
            }

            if !scheduledTrackers.isEmpty {
                let completedIds = Set(dayRecords.map { $0.trackerId })
                let scheduledIds = Set(scheduledTrackers.map { $0.id })
                if scheduledIds.isSubset(of: completedIds) {
                    idealDaysCount += 1
                }
            }
        }
        let completedCount = records.count
        let averageValue = Int(round(Double(completedCount) / Double(recordsByDay.count)))

        bestPeriodCard.update(value: bestStreak)
        idealDaysCard.update(value: idealDaysCount)
        completedCard.update(value: completedCount)
        averageCard.update(value: averageValue)
    }
}

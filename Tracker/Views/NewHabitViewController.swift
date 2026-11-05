//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Anton Rachkov on 07.10.2026.
//

import UIKit

protocol NewHabitViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker)
}

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectSchedule(_ schedule: [WeekDay])
}

final class NewHabitViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: NewHabitViewControllerDelegate?
    private let trackerCategoryStore = TrackerCategoryStore()
    
    var selectedCategoryTitle: String = "Важное"
    var selectedSchedule: [WeekDay] = []
    var selectedEmoji: String = "🪴"
    var selectedColor: UIColor = .systemGreen
    
    let emojis: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
    
    let colors: [UIColor] = [
        .systemRed, .systemOrange, .systemBlue, .systemPurple, .systemGreen, .systemPink,
        .systemTeal, .systemYellow, .systemIndigo, .systemMint, .systemBrown, .systemCyan,
        .systemGray, .systemGray2, .systemGray3, .systemGray4, .systemGray5, .black
    ]
    
    let titleLabel = UILabel()
    let nameTextField = UITextField()
    let tableView = UITableView()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()
    
    let cancelButton = UIButton(type: .system)
    let createButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
    }
    
    func setupViews() {
        titleLabel.text = "Новая привычка"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        nameTextField.placeholder = "Введите название трекера"
        nameTextField.backgroundColor = .systemGray6
        nameTextField.layer.cornerRadius = 16
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        nameTextField.leftViewMode = .always
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameTextField)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.rowHeight = 75
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseIdentifier)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseIdentifier)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.systemRed.cgColor
        cancelButton.layer.cornerRadius = 16
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.backgroundColor = .black
        createButton.layer.cornerRadius = 16
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -4),
            
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 4)
        ])
    }
    
    @objc func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc func createTapped() {
        let name = nameTextField.text ?? ""
        if name.isEmpty { return }
        
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: selectedSchedule
        )
        
        do {
            try trackerCategoryStore.addTracker(tracker, toCategoryWithTitle: selectedCategoryTitle)
            delegate?.didCreateTracker(tracker)
            dismiss(animated: true)
        } catch {
            print("Failed to save tracker: \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.backgroundColor = .systemGray6
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = selectedCategoryTitle
        } else {
            cell.textLabel?.text = "Расписание"
            if selectedSchedule.isEmpty {
                cell.detailTextLabel?.text = ""
            } else {
                cell.detailTextLabel?.text = "Выбрано дней: \(selectedSchedule.count)"
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let viewModel = CategoryViewModel(
                categoryStore: trackerCategoryStore,
                selectedCategoryTitle: selectedCategoryTitle
            )
            let categoriesVC = CategoriesViewController(viewModel: viewModel)
            categoriesVC.delegate = self
            navigationController?.pushViewController(categoriesVC, animated: true)
        } else if indexPath.row == 1 {
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCell.reuseIdentifier,
                for: indexPath
            ) as? EmojiCell else {
                return UICollectionViewCell()
            }
            let emoji = emojis[indexPath.item]
            cell.configure(with: emoji, isSelected: emoji == selectedEmoji)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCell.reuseIdentifier,
                for: indexPath
            ) as? ColorCell else {
                return UICollectionViewCell()
            }
            let color = colors[indexPath.item]
            cell.configure(with: color, isSelected: color == selectedColor)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as? SectionHeaderView else {
            return UICollectionReusableView()
        }
        header.titleLabel.text = indexPath.section == 0 ? "Emoji" : "Цвет"
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor((collectionView.bounds.width - 25) / 6)
        return CGSize(width: width, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedEmoji = emojis[indexPath.item]
        } else {
            selectedColor = colors[indexPath.item]
        }
        collectionView.reloadSections(IndexSet(integer: indexPath.section))
    }
}

extension NewHabitViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(_ schedule: [WeekDay]) {
        selectedSchedule = schedule
        tableView.reloadData()
    }
}

extension NewHabitViewController: CategoriesViewControllerDelegate {
    func didSelectCategory(_ category: TrackerCategory) {
        self.selectedCategoryTitle = category.title
        self.tableView.reloadData()
    }
}

final class SectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "SectionHeaderView"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 19)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ScheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    let days: [WeekDay] = [
        .monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday
    ]
    
    let dayNames = [
        "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"
    ]
    
    var selectedDays: [WeekDay] = []
    let tableView = UITableView()
    let doneButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Расписание"
        setupViews()
    }
    
    func setupViews() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = .black
        doneButton.layer.cornerRadius = 16
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "dayCell")
        cell.backgroundColor = .systemGray6
        cell.selectionStyle = .none
        cell.textLabel?.text = dayNames[indexPath.row]
        
        let switchView = UISwitch()
        switchView.tag = indexPath.row
        switchView.isOn = selectedDays.contains(days[indexPath.row])
        switchView.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        return cell
    }
    
    @objc func switchToggled(_ sender: UISwitch) {
        let day = days[sender.tag]
        if sender.isOn {
            selectedDays.append(day)
        } else {
            var indexToRemove = -1
            for i in 0..<selectedDays.count {
                if selectedDays[i] == day {
                    indexToRemove = i
                }
            }
            if indexToRemove >= 0 {
                selectedDays.remove(at: indexToRemove)
            }
        }
    }
    
    @objc func doneTapped() {
        delegate?.didSelectSchedule(selectedDays)
        navigationController?.popViewController(animated: true)
    }
}

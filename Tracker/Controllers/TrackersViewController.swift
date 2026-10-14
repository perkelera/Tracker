//
//  ViewController.swift
//  Tracker
//
//  Created by Anton Rachkov on 28.09.2026.
//

import UIKit

struct GeometricParams {
    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
    let paddingWidth: CGFloat
    
    init(cellCount: Int, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat) {
        self.cellCount = cellCount
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacing = cellSpacing
        self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }
}

final class TrackersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating, NewHabitViewControllerDelegate {
    
    var categories: [TrackerCategory] = []
    var visibleCategories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var currentDate: Date = Date()
    
    private let params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
    private var collectionView: UICollectionView!
    private var placeholderImage: UIImageView!
    private var placeholderText: UILabel!
    private var datePicker: UIDatePicker!
    private var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        
        let plusButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(plusButtonTapped)
        )
        plusButton.tintColor = .label
        navigationItem.leftBarButtonItem = plusButton
        
        setupCollectionView()
        addDatePicker()
        addSearchController()
        setupPlaceHolder()
        
        currentDate = Calendar.current.startOfDay(for: Date())
        filterTrackersByDateAndSearch()
    }
    
    @objc private func plusButtonTapped() {
        let newHabitVC = NewHabitViewController()
        newHabitVC.delegate = self
        let navController = UINavigationController(rootViewController: newHabitVC)
        present(navController, animated: true)
    }
    
    private func setupPlaceHolder() {
        placeholderImage = UIImageView()
        placeholderImage.image = UIImage(named: "star") ?? UIImage(systemName: "star")
        placeholderImage.contentMode = .scaleAspectFit
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderImage)
        
        placeholderText = UILabel()
        placeholderText.text = "Что будем отслеживать?"
        placeholderText.textAlignment = .center
        placeholderText.font = .systemFont(ofSize: 12, weight: .medium)
        placeholderText.textColor = .label
        placeholderText.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderText)
        
        NSLayoutConstraint.activate([
            placeholderImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),
            placeholderText.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderText.centerXAnchor.constraint(equalTo: placeholderImage.centerXAnchor),
            placeholderText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func addDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.date = currentDate
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 100)
        ])
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func addSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Поиск"
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(
            CategoryHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CategoryHeaderView.identifier
        )
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = Calendar.current.startOfDay(for: sender.date)
        filterTrackersByDateAndSearch()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterTrackersByDateAndSearch()
    }
    
    private func filterTrackersByDateAndSearch() {
        let calendar = Calendar.current
        let dayNumber = calendar.component(.weekday, from: currentDate)
        guard let currentDay = WeekDay(rawValue: dayNumber) else { return }
        
        let searchText = searchController?.searchBar.text?.lowercased() ?? ""
        
        visibleCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let matchesSchedule = tracker.schedule?.contains(currentDay) ?? true
                let matchesSearch = searchText.isEmpty || tracker.name.lowercased().contains(searchText)
                return matchesSchedule && matchesSearch
            }
            if filteredTrackers.isEmpty { return nil }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        let isEmpty = visibleCategories.isEmpty
        placeholderImage.isHidden = !isEmpty
        placeholderText.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        
        collectionView.reloadData()
    }
    
    func didCreateTracker(_ tracker: Tracker) {
        let defaultCategoryTitle = "Важное"
        
        if categories.isEmpty {
            categories = [TrackerCategory(title: defaultCategoryTitle, trackers: [tracker])]
        } else {
            let firstCategory = categories[0]
            var updatedTrackers = firstCategory.trackers
            updatedTrackers.append(tracker)
            categories = [TrackerCategory(title: firstCategory.title, trackers: updatedTrackers)]
        }
        
        filterTrackersByDateAndSearch()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: CategoryHeaderView.identifier,
                for: indexPath
              ) as? CategoryHeaderView else {
            return UICollectionReusableView()
        }
        
        header.titleLabel.text = visibleCategories[indexPath.section].title
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        let isDone = completedTrackers.contains { record in
            record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: currentDate)
        }
        let totalDoneCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
        let isFutureDate = currentDate > Calendar.current.startOfDay(for: Date())
        
        cell.cardView.backgroundColor = tracker.color
        cell.titleLabel.text = tracker.name
        cell.doneButton.backgroundColor = tracker.color
        cell.daysLabel.text = "\(totalDoneCount) дн."
        
        let iconName = isDone ? "checkmark" : "plus"
        cell.doneButton.setImage(UIImage(systemName: iconName), for: .normal)
        cell.doneButton.alpha = isDone ? 0.3 : 1.0
        cell.doneButton.isEnabled = !isFutureDate
        
        cell.doneButtonAction = { [weak self] in
            guard let self = self, !isFutureDate else { return }
            
            if isDone {
                self.completedTrackers.removeAll {
                    $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: self.currentDate)
                }
            } else {
                let newRecord = TrackerRecord(trackerId: tracker.id, date: self.currentDate)
                self.completedTrackers.append(newRecord)
            }
            self.collectionView.reloadItems(at: [indexPath])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - params.paddingWidth
        let cellWidth = availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: params.leftInset, bottom: 16, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
}

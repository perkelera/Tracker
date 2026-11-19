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

final class TrackersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating, NewHabitViewControllerDelegate, FiltersViewControllerDelegate {
    
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let colors = Colors()
    private let pinnedTrackersKey = "pinnedTrackerIds"
    
    var categories: [TrackerCategory] = []
    var visibleCategories: [TrackerCategory] = []
    var completedTrackers: Set<TrackerRecord> = []
    var currentDate: Date = Date()
    private var selectedFilter: TrackerFilter = .all
    
    private var pinnedTrackerIds: Set<UUID> {
        get {
            let saved = UserDefaults.standard.stringArray(forKey: pinnedTrackersKey) ?? []
            return Set(saved.compactMap { UUID(uuidString: $0) })
        }
        set {
            UserDefaults.standard.set(newValue.map { $0.uuidString }, forKey: pinnedTrackersKey)
        }
    }
    
    private let params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
    private var collectionView: UICollectionView!
    private var placeholderImage: UIImageView!
    private var placeholderText: UILabel!
    private var datePicker: UIDatePicker!
    private var searchController: UISearchController!
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("filters.title", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 55/255, green: 114/255, blue: 231/255, alpha: 1.0)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("trackers.title", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = colors.viewBackgroundColor
        
        let plusButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(plusButtonTapped)
        )
        plusButton.tintColor = colors.primaryTextColor
        navigationItem.leftBarButtonItem = plusButton
        
        setupCollectionView()
        setupFiltersButton()
        addDatePicker()
        addSearchController()
        setupPlaceHolder()
        
        trackerCategoryStore.delegate = self
        
        currentDate = Calendar.current.startOfDay(for: Date())
        loadDataFromCoreData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDataFromCoreData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.report(event: .open, screen: .main)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.shared.report(event: .close, screen: .main)
    }
    
    private func loadDataFromCoreData() {
        categories = trackerCategoryStore.categories
        completedTrackers = trackerRecordStore.records
        filterTrackersByDateAndSearch()
    }
    
    @objc private func plusButtonTapped() {
        AnalyticsService.shared.report(event: .click, screen: .main, item: .addTrack)
        
        let newHabitVC = NewHabitViewController()
        newHabitVC.delegate = self
        let navController = UINavigationController(rootViewController: newHabitVC)
        present(navController, animated: true)
    }
    
    @objc private func filtersButtonTapped() {
        AnalyticsService.shared.report(event: .click, screen: .main, item: .filter)
        
        let filtersVC = FiltersViewController()
        filtersVC.selectedFilter = selectedFilter
        filtersVC.delegate = self
        present(filtersVC, animated: true)
    }
    
    private func setupFiltersButton() {
        view.addSubview(filtersButton)
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupPlaceHolder() {
        placeholderImage = UIImageView()
        placeholderImage.image = UIImage(named: "star") ?? UIImage(systemName: "star")
        placeholderImage.contentMode = .scaleAspectFit
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderImage)
        
        placeholderText = UILabel()
        placeholderText.text = NSLocalizedString("trackers.empty.title", comment: "")
        placeholderText.textAlignment = .center
        placeholderText.font = .systemFont(ofSize: 12, weight: .medium)
        placeholderText.textColor = colors.primaryTextColor
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
        datePicker.locale = Locale.current
        datePicker.date = currentDate
        datePicker.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        datePicker.layer.cornerRadius = 8
        datePicker.layer.masksToBounds = true
        datePicker.overrideUserInterfaceStyle = .light
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
        searchController.searchBar.placeholder = NSLocalizedString("trackers.search.placeholder", comment: "")
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
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
    
    func didSelectFilter(_ filter: TrackerFilter) {
        selectedFilter = filter
        if filter == .today {
            let today = Calendar.current.startOfDay(for: Date())
            currentDate = today
            datePicker.date = today
        }
        filterTrackersByDateAndSearch()
    }
    
    private func filterTrackersByDateAndSearch() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        let dayNumber = calendar.component(.weekday, from: currentDate)
        guard let currentDay = WeekDay(rawValue: dayNumber) else { return }
        
        let searchText = searchController?.searchBar.text?.trimmingCharacters(in: .whitespaces).lowercased() ?? ""
        let pinnedIds = pinnedTrackerIds
        
        var hasTrackersForSelectedDate = false
        var pinnedTrackers: [Tracker] = []
        var regularCategories: [TrackerCategory] = []
        
        for category in categories {
            var unpinnedInCategory: [Tracker] = []
            for tracker in category.trackers {
                let matchesSchedule: Bool
                if let schedule = tracker.schedule, !schedule.isEmpty {
                    matchesSchedule = schedule.contains(currentDay)
                } else {
                    matchesSchedule = true
                }
                
                if matchesSchedule {
                    hasTrackersForSelectedDate = true
                }
                
                let matchesSearch = searchText.isEmpty || tracker.name.lowercased().contains(searchText)
                
                let isCompletedToday = completedTrackers.contains { record in
                    record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: currentDate)
                }
                
                let matchesFilter: Bool
                switch selectedFilter {
                case .all, .today:
                    matchesFilter = true
                case .completed:
                    matchesFilter = isCompletedToday
                case .uncompleted:
                    matchesFilter = !isCompletedToday
                }
                
                guard matchesSchedule && matchesSearch && matchesFilter else { continue }
                
                if pinnedIds.contains(tracker.id) {
                    pinnedTrackers.append(tracker)
                } else {
                    unpinnedInCategory.append(tracker)
                }
            }
            if !unpinnedInCategory.isEmpty {
                regularCategories.append(TrackerCategory(title: category.title, trackers: unpinnedInCategory))
            }
        }
        
        var resultCategories: [TrackerCategory] = []
        if !pinnedTrackers.isEmpty {
            resultCategories.append(
                TrackerCategory(
                    title: NSLocalizedString("trackers.pinnedCategory", comment: ""),
                    trackers: pinnedTrackers
                )
            )
        }
        resultCategories.append(contentsOf: regularCategories)
        visibleCategories = resultCategories
        
        let isEmpty = visibleCategories.isEmpty
        placeholderImage.isHidden = !isEmpty
        placeholderText.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        filtersButton.isHidden = !hasTrackersForSelectedDate
        
        let isActiveFilter = (selectedFilter == .completed || selectedFilter == .uncompleted)
        filtersButton.setTitleColor(isActiveFilter ? .systemRed : .white, for: .normal)
        
        if isEmpty {
            if !searchText.isEmpty || isActiveFilter {
                placeholderImage.image = UIImage(named: "nothing_found") ?? UIImage(systemName: "magnifyingglass")
                placeholderText.text = NSLocalizedString("trackers.nothingFound.title", comment: "")
            } else {
                placeholderImage.image = UIImage(named: "star") ?? UIImage(systemName: "star")
                placeholderText.text = NSLocalizedString("trackers.empty.title", comment: "")
            }
        }
        
        collectionView.reloadData()
    }
    
    private func originalCategoryTitle(for trackerId: UUID) -> String {
        for category in categories {
            if category.trackers.contains(where: { $0.id == trackerId }) {
                return category.title
            }
        }
        return NSLocalizedString("newHabit.defaultCategory", comment: "")
    }
    
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String) {
        try? trackerCategoryStore.addTracker(tracker, toCategoryWithTitle: categoryTitle)
        loadDataFromCoreData()
    }
    
    func didUpdateTracker(_ tracker: Tracker, categoryTitle: String) {
        try? trackerCategoryStore.updateTracker(tracker, inCategoryWithTitle: categoryTitle)
        loadDataFromCoreData()
    }
    
    private func togglePin(for tracker: Tracker) {
        var ids = pinnedTrackerIds
        if ids.contains(tracker.id) {
            ids.remove(tracker.id)
        } else {
            ids.insert(tracker.id)
        }
        pinnedTrackerIds = ids
        filterTrackersByDateAndSearch()
    }
    
    private func editTracker(at indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let totalDoneCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
        
        let editVC = NewHabitViewController()
        editVC.delegate = self
        editVC.editingTracker = tracker
        editVC.selectedCategoryTitle = originalCategoryTitle(for: tracker.id)
        editVC.completedDaysCount = totalDoneCount
        
        let navController = UINavigationController(rootViewController: editVC)
        present(navController, animated: true)
    }
    
    private func confirmDeleteTracker(at indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("deleteAlert.message", comment: ""),
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("contextMenu.delete", comment: ""),
            style: .destructive
        ) { [weak self] _ in
            guard let self = self else { return }
            var ids = self.pinnedTrackerIds
            ids.remove(tracker.id)
            self.pinnedTrackerIds = ids
            
            try? self.trackerRecordStore.removeAllRecords(forTrackerId: tracker.id)
            try? self.trackerCategoryStore.deleteTracker(withId: tracker.id)
            self.loadDataFromCoreData()
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("deleteAlert.cancel", comment: ""),
            style: .cancel
        )
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
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
        let isPinned = pinnedTrackerIds.contains(tracker.id)
        
        let isDone = completedTrackers.contains { record in
            record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: currentDate)
        }
        let totalDoneCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
        let isFutureDate = currentDate > Calendar.current.startOfDay(for: Date())
        
        cell.cardView.backgroundColor = tracker.color
        cell.titleLabel.text = tracker.name
        cell.emojiLabel.text = tracker.emoji
        cell.pinImageView.isHidden = !isPinned
        cell.doneButton.backgroundColor = tracker.color
        cell.daysLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("daysCount", comment: "Number of completed days"),
            totalDoneCount
        )
        let iconName = isDone ? "checkmark" : "plus"
        cell.doneButton.setImage(UIImage(systemName: iconName), for: .normal)
        cell.doneButton.alpha = isDone ? 0.3 : 1.0
        cell.doneButton.isEnabled = !isFutureDate
        
        cell.doneButtonAction = { [weak self] in
            guard let self = self, !isFutureDate else { return }
            
            AnalyticsService.shared.report(event: .click, screen: .main, item: .track)
            
            let record = TrackerRecord(trackerId: tracker.id, date: self.currentDate)
            
            if isDone {
                try? self.trackerRecordStore.removeRecord(record)
                self.completedTrackers.remove(record)
            } else {
                try? self.trackerRecordStore.addNewRecord(record)
                self.completedTrackers.insert(record)
            }
            
            if self.selectedFilter == .completed || self.selectedFilter == .uncompleted {
                self.filterTrackersByDateAndSearch()
            } else {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }
            let tracker = self.visibleCategories[indexPath.section].trackers[indexPath.item]
            let isPinned = self.pinnedTrackerIds.contains(tracker.id)
            
            let pinTitle = isPinned
                ? NSLocalizedString("contextMenu.unpin", comment: "")
                : NSLocalizedString("contextMenu.pin", comment: "")
            let pinAction = UIAction(title: pinTitle) { [weak self] _ in
                self?.togglePin(for: tracker)
            }
            
            let editAction = UIAction(
                title: NSLocalizedString("contextMenu.edit", comment: "")
            ) { [weak self] _ in
                AnalyticsService.shared.report(event: .click, screen: .main, item: .edit)
                self?.editTracker(at: indexPath)
            }
            
            let deleteAction = UIAction(
                title: NSLocalizedString("contextMenu.delete", comment: ""),
                attributes: .destructive
            ) { [weak self] _ in
                AnalyticsService.shared.report(event: .click, screen: .main, item: .delete)
                self?.confirmDeleteTracker(at: indexPath)
            }
            
            return UIMenu(children: [pinAction, editAction, deleteAction])
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(roundedRect: cell.cardView.frame, cornerRadius: 16)
        return UITargetedPreview(view: cell, parameters: parameters)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(roundedRect: cell.cardView.frame, cornerRadius: 16)
        return UITargetedPreview(view: cell, parameters: parameters)
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

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        loadDataFromCoreData()
    }
}

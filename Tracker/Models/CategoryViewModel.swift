import Foundation

final class CategoryViewModel {
    
    var onCategoriesChanged: (() -> Void)?
    var onCategorySelected: ((TrackerCategory) -> Void)?
    
    private let categoryStore: TrackerCategoryStore
    
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesChanged?()
        }
    }
    
    private(set) var selectedCategoryTitle: String?
    
    init(
        categoryStore: TrackerCategoryStore = TrackerCategoryStore(),
        selectedCategoryTitle: String? = nil
    ) {
        self.categoryStore = categoryStore
        self.selectedCategoryTitle = selectedCategoryTitle
        self.categoryStore.delegate = self
        fetchCategories()
    }
    
    func fetchCategories() {
        categories = categoryStore.categories
    }
    
    var numberOfCategories: Int {
        categories.count
    }
    
    func category(at index: Int) -> TrackerCategory {
        categories[index]
    }
    
    func isSelected(at index: Int) -> Bool {
        categories[index].title == selectedCategoryTitle
    }
    
    func selectCategory(at index: Int) {
        let selectedCategory = categories[index]
        selectedCategoryTitle = selectedCategory.title
        onCategorySelected?(selectedCategory)
    }
    
    func addNewCategory(title: String) {
        let newCategory = TrackerCategory(title: title, trackers: [])
        try? categoryStore.addNewCategory(newCategory)
        fetchCategories()
    }
}

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        fetchCategories()
    }
}

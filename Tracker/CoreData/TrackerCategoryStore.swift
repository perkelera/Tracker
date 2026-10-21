//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Anton Rachkov on 20.10.2026.
//

import UIKit
import CoreData

struct TrackerCategoryStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate)
}

final class TrackerCategoryStore: NSObject {
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private let context: NSManagedObjectContext
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    var categories: [TrackerCategory] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        let trackerStore = TrackerStore(context: context)
        
        return objects.compactMap { (categoryCoreData: TrackerCategoryCoreData) -> TrackerCategory? in
            guard let title = categoryCoreData.title else { return nil }
            
            let request = TrackerCoreData.fetchRequest()
            request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.category.title), title)
            let trackersCoreData = (try? self.context.fetch(request)) ?? []
            let trackers = trackersCoreData.compactMap { try? trackerStore.tracker(from: $0) }
            
            return TrackerCategory(title: title, trackers: trackers)
        }
    }
    
    func addNewCategory(_ category: TrackerCategory) throws {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        try context.save()
    }
    
    func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), title)
        let existingCategories = try context.fetch(request)
        
        let categoryCoreData: TrackerCategoryCoreData
        if let found = existingCategories.first {
            categoryCoreData = found
        } else {
            categoryCoreData = TrackerCategoryCoreData(context: context)
            categoryCoreData.title = title
        }
        
        let trackerStore = TrackerStore(context: context)
        let trackerCoreData = TrackerCoreData(context: context)
        trackerStore.updateExistingTracker(trackerCoreData, with: tracker)
        
        trackerCoreData.category = categoryCoreData
        
        try context.save()
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let insertedIndexes = insertedIndexes, let deletedIndexes = deletedIndexes else { return }
        
        delegate?.store(
            self,
            didUpdate: TrackerCategoryStoreUpdate(
                insertedIndexes: insertedIndexes,
                deletedIndexes: deletedIndexes
            )
        )
        
        self.insertedIndexes = nil
        self.deletedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}

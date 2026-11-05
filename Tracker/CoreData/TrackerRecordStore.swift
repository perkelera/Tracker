//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Anton Rachkov on 20.10.2026.
//

import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func storeDidUpdate(_ store: TrackerRecordStore)
}

final class TrackerRecordStore: NSObject {
    weak var delegate: TrackerRecordStoreDelegate?
    
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
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
    
    var records: Set<TrackerRecord> {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        let recordsArray = objects.compactMap { recordCoreData -> TrackerRecord? in
            guard let id = recordCoreData.trackerId, let date = recordCoreData.date else { return nil }
            return TrackerRecord(trackerId: id, date: date)
        }
        return Set(recordsArray)
    }
    
    func addNewRecord(_ record: TrackerRecord) throws {
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.trackerId = record.trackerId
        recordCoreData.date = record.date
        try context.save()
    }
    
    func removeRecord(_ record: TrackerRecord) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(TrackerRecordCoreData.trackerId),
            record.trackerId as CVarArg,
            #keyPath(TrackerRecordCoreData.date),
            record.date as CVarArg
        )
        
        let records = try context.fetch(request)
        if let recordToDelete = records.first {
            context.delete(recordToDelete)
            try context.save()
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate(self)
    }
}

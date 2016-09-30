//
//  CoreDataStack.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/29/16.
//  Copyright © 2016 masters3d. All rights reserved.
//


import CoreData

final class CoreDataStack {
 
    static let shared = CoreDataStack()
    var errorHandler: (Error) -> Void = {_ in }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { [weak self](storeDescription, error) in
            if let error = error {
                NSLog("CoreData error \(error), \(error._userInfo)")
                self?.errorHandler(error)
            }
        print("Location of SQL file for Core Data")
        let applicationSupportURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.applicationSupportDirectory, in: .userDomainMask).last
          print(applicationSupportURL)
            })
        return container
    }()
    
    lazy var viewContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()
    
    func performForegroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.viewContext.perform {
            block(self.viewContext)
        }
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.persistentContainer.performBackgroundTask(block)
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                NSLog("CoreData error \(error), \(error._userInfo)")
                self.errorHandler(error)
            }
        }
    }
    
}

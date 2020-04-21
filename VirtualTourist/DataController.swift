//
//  DataController.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/22/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit
import CoreData

extension DataController {

   fileprivate func coreDataPinFetchAll() -> [Pin] {
    var results = [Pin]()

        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors =  [NSSortDescriptor(key:"latitude", ascending: true)]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
       guard  let _ = try? frc.performFetch() else { return []}
        guard let objects = frc.fetchedObjects else { return [] }
            results = objects
        
        return results
    }
    

    fileprivate func coreDataPhotosFetchForPin(_ pin:Pin) -> [Photo]? {
    var results = [Photo]()
        let allPins = self.coreDataPinFetchAll()
        if let indexOfPin = allPins.index(of: pin),
            let photosSet = allPins[indexOfPin].photos,
            let photos = photosSet as? Set<Photo> {
            
           results = Array(photos).sorted(by: { (left, right) -> Bool in
           guard let lTime = left.timeCreated,
           let rTime = right.timeCreated else { return false}
           
               return lTime.timeIntervalSince1970 < rTime.timeIntervalSince1970
            })
        } else {
            results = []
        }
    
    return results
    }
}

class DataController {

    static var shared = DataController()
    
    var errorHandlerDelegate:ErrorReporting? {didSet{
    
        guard let delegate = errorHandlerDelegate
            else {
                CoreDataStack.shared.errorHandler = {_ in }
                return }
        // isSucess
        CoreDataStack.shared.errorHandler = delegate.reportErrorFromOperation
    
    }}
    
    private func getPlaceHolderPhotos(for pin:PinAnnotation) -> [Photo] {
        let image = #imageLiteral(resourceName: "Placeholder")
        let data = image.pngData()
        var photos = [Photo]()
        
        for each in 1...APIConstants.albumSize {
            let photo_id = "\(pin.coordinate.shortDescription)PlaceHolder\(each)"
            let eachPhoto =  Photo.coreDataObject(height: Double(image.size.height), imageData: data!, title: "none given", width: Double(image.size.height),photo_id:photo_id, pin:pin)
            photos.append(eachPhoto)
            // saving Core Data
            CoreDataStack.shared.saveContext()
        }
        return photos
    }
    
    func getPhotos(for pin:PinAnnotation, newSet:Bool = false) -> [Photo] {
    var results = [Photo]()
        if let result = self.coreDataPhotosFetchForPin(pin) {
            results = newSet ? self.getPlaceHolderPhotos(for: pin) : result
        } else {
            results = self.getPlaceHolderPhotos(for: pin)
        }
        return results
    }
    
    func getAllPins() -> [PinAnnotation] {
    var result = [PinAnnotation]()
        result = self.coreDataPinFetchAll()
        
    return result
    }
    
    func addPhotos(_ photosToAdd: [Photo], to pin:PinAnnotation) {
        photosToAdd.forEach { (eachPhoto) in
            pin.addToPhotos(eachPhoto)
        }
        CoreDataStack.shared.saveContext()
    }
    
    func removeAllPhotos(for pin:PinAnnotation) {
    
       guard let photosToRemote = pin.photos as? Set<Photo>else {return}
        removePhotos(Array(photosToRemote), for: pin)
        
    }
    
    func removePhotos(_ photosToRemove: [Photo], for pin:PinAnnotation) {
        photosToRemove.forEach { (eachPhoto) in
            pin.removeFromPhotos(eachPhoto)
            CoreDataStack.shared.viewContext.delete(eachPhoto)
        }
        CoreDataStack.shared.saveContext()
    }
    
    func removePhoto(withPhotoId:String, for pin:PinAnnotation) ->Void {
        if let photosForPin = self.coreDataPhotosFetchForPin(pin),
        let photoToRemove = photosForPin.filter ({$0.photo_id == withPhotoId }).first{
            removePhotos([photoToRemove], for: pin)
        }
    }
    
    func editPhoto(withPhotoId:String, for pin:PinAnnotation, withBlock:(Photo) ->Void) {
        if let photosForPin = self.coreDataPhotosFetchForPin(pin),
        let photoToEdit = photosForPin.filter ({$0.photo_id == withPhotoId }).first{
            withBlock(photoToEdit)
        }
        CoreDataStack.shared.saveContext()
    }
    
    func remove(_ pin:PinAnnotation) {
        removeAllPhotos(for: pin)
        CoreDataStack.shared.viewContext.delete(pin)
        CoreDataStack.shared.saveContext()
    
    }
    
    
}

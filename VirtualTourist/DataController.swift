//
//  DataController.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/22/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit
import CoreData


class DataController {

    static var dataController:DataController {
        return (UIApplication.shared.delegate as! AppDelegate).dataController
    }
    
    static func contextProducer() -> NSManagedObjectContext {
        return DataController.dataController.coreData.viewContext
    }

    internal let coreData = CoreDataStack.shared
    
    private var photos = [PinAnnotation : [Photo]]()
    
    private func getNewPhotos(for pin:PinAnnotation) -> [Photo] {
        let image = #imageLiteral(resourceName: "Placeholder")
        let data = UIImagePNGRepresentation(image)
        let tempPhoto = Photo.coreDataObject(height: Double(image.size.height), imageData: data!, title: "none given", width: Double(image.size.height), pin:pin)
        photos[pin] = Array(repeatElement(tempPhoto, count: APIConstants.albumSize))
        return photos[pin] ?? []
    }
    
    func getPhotos(for pin:PinAnnotation, newSet:Bool = false) -> [Photo] {
        if let result = photos[pin] {
            return newSet ? getNewPhotos(for: pin) : result
        } else {
            return getNewPhotos(for: pin)
        }
    }
    
    func set(photos photosToAdd: [Photo], for pin:PinAnnotation) {
        photos[pin] = photosToAdd
    }
    
    func setPhoto(_ photo:Photo, atIndex:Int, for pin:PinAnnotation) -> Bool {
        if var array = photos[pin],
            array.count != 0,
            array.count > atIndex,
            atIndex >= 0{
            
            array[atIndex] = photo
            photos[pin] = array
            return true
        }
        return false
    }
    
    func remove(_ pin:PinAnnotation) {
        photos[pin] = nil
    }
    
    
}

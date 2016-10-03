//
//  Model.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/22/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import Foundation
import MapKit
import CoreData

typealias PinAnnotation = Pin

// Core Data
@objc(Pin)
class Pin:NSManagedObject,MKAnnotation {
    var title: String? = ""
    var subtitle: String? = ""
    var coordinate: CLLocationCoordinate2D { return CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }

    static func coreDataObject(coordinate: CLLocationCoordinate2D) -> Pin {
        //let pin = NSEntityDescription.insertNewObject(forEntityName: "Pin", into:  CoreDataStack.shared.viewContext) as! Pin
        let pin = Pin(context:CoreDataStack.shared.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        return pin
    }
    
    static func coreDataObject(latitude:Double,longitude:Double) -> Pin {
        return coreDataObject(coordinate:CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    }
}

@objc(Photo)
class Photo: NSManagedObject {
    var image:UIImage? { return UIImage(data: imageData as! Data) }
    var isImagePlaceholder:Bool {
        if let image = image {
            let placeholder = #imageLiteral(resourceName: "Placeholder")
         return  UIImagePNGRepresentation(placeholder) == UIImagePNGRepresentation(image)
        } else {
            return false
        }
    }
}

extension Photo {
    static func coreDataObject(height: Double, imageData: Data, title: String, width: Double, photo_id:String, pin:PinAnnotation, timeCreated:Date = Date()) -> Photo {
        let photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into:  CoreDataStack.shared.viewContext) as! Photo
        photo.title = title
        photo.height = height
        photo.imageData = imageData as NSData?
        photo.width = width
        photo.photo_id = photo_id
        photo.pin = pin
        photo.timeCreated = timeCreated as NSDate
        return photo
    }
    
    static func coreDataEditObjectBlockCreator(height: Double, imageData: Data, title: String, width: Double, photo_id:String) -> (Photo) -> Void {
        
        let block:(Photo) -> Void = {
            photoToEdit in
            photoToEdit.title = title
            photoToEdit.height = height
            photoToEdit.imageData = imageData as NSData?
            photoToEdit.width = width
            photoToEdit.photo_id = photo_id
//            photoToEdit.pin = pin.coreDataPin
//            photoToEdit.timeCreated = timeCreated as NSDate
        }
        return block
    }
    
}

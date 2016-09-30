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

@objc(PinAnnotation)
class PinAnnotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
   init(title:String = "", subtitle: String = "", coordinate: CLLocationCoordinate2D){
        self.subtitle = subtitle
        self.title = title
        self.coordinate = coordinate
    }
    
//     Core Data Pin
    private let pinManagedObject = NSEntityDescription.insertNewObject(forEntityName: "Pin", into:  CoreDataStack.shared.viewContext) as! Pin
    
    var returnedFromCoreDataPin:Pin? = nil
    // Returns a new pin if none set in returnedFromCoreDataPin
    var coreDataPin:Pin {
        
        defer {
            //TODO:- We should probably do the saving on the Data Controller instead.
        //CoreDataStack.shared.saveContext()
                }
        
        if let pin = returnedFromCoreDataPin {
            pin.longitude = coordinate.longitude
            pin.latitude = coordinate.latitude
            return pin
        } else {
            pinManagedObject.longitude = coordinate.longitude
            pinManagedObject.latitude = coordinate.latitude
            return pinManagedObject

        }
    }
}

extension PinAnnotation {
    
    convenience init(coreDataPin: Pin) {
        self.init(coordinate:CLLocationCoordinate2D.init(latitude: coreDataPin.latitude, longitude: coreDataPin.longitude) )
        self.returnedFromCoreDataPin = coreDataPin
    }
}

// Core Data
@objc(Pin)
class Pin:NSManagedObject {}

@objc(Photo)
class Photo: NSManagedObject {
//    var title: String
//    var height: Double
//    var width: Double
//    var imageData: Data
//    var photo_id:String

    // path
    // pin
    
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
        photo.pin = pin.coreDataPin
        photo.timeCreated = timeCreated as NSDate
        //TODO:- We should probably do the saving on the Data Controller instead.
//        if saveCoreData { CoreDataStack.shared.saveContext() }
        return photo
    }
    
}

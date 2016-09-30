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
    
    var coreDataPin:Pin {
        pinManagedObject.longitude = coordinate.longitude
        pinManagedObject.latitude = coordinate.latitude
        return pinManagedObject
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
    
//    convenience init(height: Double, imageData: Data, title: String, width: Double, photo_id:String = "",context:NSManagedObjectContext = DataController.contextProducer()  ) {
//       guard let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) else { fatalError("Could not find Entity Photo") }
//        self.init(entity: entity, insertInto: context)
//        
//        DispatchQueue.main.async(execute: {
//        self.height = height
//        self.imageData = imageData as NSData?
//        self.title = title
//        self.width = width
//        self.photo_id = photo_id
//        })
//
//}
    
}

extension Photo {
    
    static func coreDataObject(height: Double, imageData: Data, title: String, width: Double, photo_id:String = "", pin:PinAnnotation) -> Photo {
        let photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into:  CoreDataStack.shared.viewContext) as! Photo
        photo.title = title
        photo.height = height
        photo.imageData = imageData as NSData?
        photo.width = width
        photo.photo_id = photo_id
        photo.pin = pin.coreDataPin
        return photo
    }
    
    func coreDataObjectEditing(height: Double, imageData: Data, title: String, width: Double, photo_id:String = "") -> Photo {
        
        let edited = self
        edited.title = title
        edited.height = height
        edited.imageData = imageData as NSData?
        edited.width = width
        edited.photo_id = photo_id
        
        return edited
    }
    
    
}

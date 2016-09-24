//
//  DataController.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/22/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit

class DataController {

private var photos = [Pin : [Photo]]()
private var pins = [Pin]()

func getPhotos(for pin:Pin) -> [Photo] {

    let image = #imageLiteral(resourceName: "Placeholder")
    
    let data = UIImagePNGRepresentation(image)
    
    let tempPhoto = Photo(height: Double(image.size.height), imageData: data!, title: "none given", width: Double(image.size.height))
    photos[pin] = Array(repeatElement(tempPhoto, count: 9))
    
    return photos[pin] ?? []
}

func set(photos photosToAdd: [Photo], for pin:Pin) {
    photos[pin] = photosToAdd
}


}

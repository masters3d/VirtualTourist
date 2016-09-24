//
//  Model.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/22/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import Foundation
import MapKit


class Pin:NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title:String = "", subtitle: String = "", coordinate: CLLocationCoordinate2D ) {
        self.subtitle = subtitle
        self.title = title
        self.coordinate = coordinate
    }

}

final class Photo {
    var title: String
    var height: Double
    var width: Double
    var imageData: Data

    // path
    // pin
    
    init(height: Double, imageData: Data, title: String, width: Double) {
        self.height = height
        self.imageData = imageData
        self.title = title
        self.width = width
}
    
}


















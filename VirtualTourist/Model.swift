//
//  Model.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/22/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D: Hashable {
	public var hashValue: Int {
        return (latitude.hashValue&*397) &+ longitude.hashValue;
    }

    static public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension Pin: Hashable {
    static func ==(lhs:Pin, rhs:Pin ) -> Bool {
        return lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.coordinate == rhs.coordinate
    }

    var hashValue: Int {
        return self.coordinate.hashValue
    }
}

final class Pin {
    let title: String
    let subtitle: String
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


















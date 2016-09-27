//
//  DetailPhotos+Extensions.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/26/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit
import MapKit

extension UIColor {
    open class var defaultBlue: UIColor { return UIColor(red: 0, green: 122/255, blue: 1, alpha: 1) }
}

extension DetailPhotosViewController {
    
    func setMap(_ map:MKMapView ,with pin:Pin) {
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegionMake(pin.coordinate, span)
        map.setRegion(region, animated: true)
        map.isUserInteractionEnabled = false
        map.addAnnotation(pin)
    }
    
    func setCollection(_ collection:UICollectionView) {
        let width = collection.frame.width / 3
        let layout = collection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
        
    }
    
}

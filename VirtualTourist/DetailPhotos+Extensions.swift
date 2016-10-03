//
//  DetailPhotos+Extensions.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/26/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit
import MapKit

extension OperationQueue {
    func isOperationInQueue(named:String) -> Bool {
       guard let _ =  self.operations.map({$0.name}).flatMap({$0}).filter({$0 == named}).first else { return false }
            return true
    }
}

enum Constants {
    static var newCollection:String { return "New Collection" }
    static var removeSelected:String { return "Remove Selected Pictures" }
}

extension UIColor {
    open class var defaultBlue: UIColor { return UIColor(red: 0, green: 122/255, blue: 1, alpha: 1) }
}

extension DetailPhotosViewController {
    func setMap(_ map:MKMapView ,with pin:PinAnnotation) {
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
//        layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
    }
}

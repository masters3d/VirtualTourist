//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/22/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add the edit button on the right
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // set gesture recognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressDetected(_:)))
        mapView.addGestureRecognizer(longPress)
        
    }
    
    func longPressDetected(_ gesture: UIGestureRecognizer) {
        if gesture.state == .began {
            if isEditing {
                print("need to implement this")
                print(mapView.selectedAnnotations)
            } else {
                let point = gesture.location(in: self.mapView)
                let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
                let annotation = Pin(coordinate: coordinate)
                mapView.addAnnotation(annotation)
            }
        }
    }
    

    lazy var infoView: UILabel = self.infoViewCreator()

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            view.addSubview(infoView)
        } else {
            infoView.removeFromSuperview()
        }
        
}

}


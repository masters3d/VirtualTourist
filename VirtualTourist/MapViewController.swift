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
        mapView.delegate = self
        
        // add the edit button on the right
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // set gesture recognizer
        mapView.addGestureRecognizer( UILongPressGestureRecognizer(
            target: self, action: #selector(longPressDetected(_:)))
            )
        
    }
    
    func longPressDetected(_ gesture: UIGestureRecognizer) {
        if gesture.state == .began {
            if isEditing {
                //TODO:-
                print("need to implement this")
                print(mapView.selectedAnnotations)
            } else {
                let point = gesture.location(in: self.mapView)
                let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
                let annotation = Pin(coordinate: coordinate)
                // add to map and data store
                addPin(annotation)
                
            }
        }
    }
    
    func addPin(_ pin:Pin) {
        mapView.addAnnotation(pin)
        let _ =  appDelegate.dataController.getPhotos(for: pin)
    }
    
    func removePin(_ pin:Pin) {
        mapView.removeAnnotation(pin)
        appDelegate.dataController.remove(pin)
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

    // Error Reporting
    
    var errorReported: Error?
    var isAlertPresenting: Bool = false


}


extension MapViewController: MKMapViewDelegate {

    // this removes anotation in select mode
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if isEditing {
            removePin(view.annotation as! Pin)
        } else {
            
        
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
    //TODO:- we can hook up DataContoller here
}
}



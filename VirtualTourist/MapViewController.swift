//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/22/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController, ErrorReporting {
    
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
        // add pins from data store
        DataController.dataController.getAllPins().forEach { (pin) in
            mapView.addAnnotation(pin)
        }
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
                let annotation = PinAnnotation(coordinate: coordinate)
                // add to map and data store
                addPin(annotation)
            }
        }
    }
    
    func addPin(_ pin:PinAnnotation) {
        mapView.addAnnotation(pin)
        if DataController.dataController.getPhotos(for: pin).isEmpty {
         let _ =  DataController.dataController.getPhotos(for: pin, newSet: true)
        }
        
    }
    
    func removePin(_ pin:PinAnnotation) {
        mapView.removeAnnotation(pin)
        DataController.dataController.remove(pin)
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

    // Pin to send to segue
    
    var pin:PinAnnotation?

}

extension MapViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    guard let identifier = segue.identifier else { return }
    switch identifier {
        case "showPhotoDetail":
            guard let pin = pin else { self.presentErrorPopUp(" Error showing Detail"); return }
            guard let destination = segue.destination as? DetailPhotosViewController else { return }
            destination.setPinForMap(pin)
         default: break
    }
    
}
}

extension MapViewController: MKMapViewDelegate {

    // this removes anotation in select mode
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if isEditing {
            removePin(view.annotation as! PinAnnotation)
        } else {
           pin = view.annotation as? PinAnnotation
        self.performSegue(withIdentifier: "showPhotoDetail", sender: self)
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
    //TODO:- we can hook up DataContoller here
}
}



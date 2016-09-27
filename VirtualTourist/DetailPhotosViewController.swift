//
//  DetailPhotosController.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/25/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit
import MapKit

class DetailPhotosViewController: UIViewController, ErrorReporting,
    UICollectionViewDelegate, UICollectionViewDataSource  {

    // Error Reporting Protocol Requirements
    var errorReported: Error?
    var isAlertPresenting: Bool = false
    
    // Pin passed in from segue
    var pin:Pin!
    func setPinForMap(_ pin:Pin) {
        self.pin = pin
    }
    
    var dataCache:DataController {
        return appDelegate.dataController
    }
    
    @IBOutlet weak var noImagesLabel: UILabel!

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }
    
    // this will layout 3 pictures across
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set UP
        setMap(mapView, with: pin)
        setCollection(collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataCache.getPhotos(for: pin).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCellReusableID", for: indexPath) as! DetailCell
            let photoObject =
                dataCache.getPhotos(for: pin)[indexPath.row]
        
            cell.imageView.image = photoObject.image
        
        
            if photoObject.isImagePlaceholder {
                cell.activityIndicatorStart()
                
                
                let block = { (data:Data?) in
                    if let data = data {
                        DispatchQueue.main.async(execute: {
                            cell.imageView.image = UIImage(data: data) })
                            cell.activityIndicatorStop()
                    }
                }
                
                let networkRequest = NetworkOperation(typeOfConnection: .lorempixel, delegate: self, successBlock: block , showActivityOnUI: false)
                
                networkRequest.start()

                
            } else {
                cell.activityIndicatorStop()
            }
        
        return cell
    }
    

}






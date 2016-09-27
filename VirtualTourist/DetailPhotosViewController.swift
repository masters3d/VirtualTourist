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

    // Bottom Button Logic
    
    var selectedIndex = Set<IndexPath>() {
        didSet{
            if selectedIndex.isEmpty {
                bottomLabelForActionButton.title = "New Collection"
                bottomLabelForActionButton.tintColor = UIColor.defaultBlue
            } else {
                bottomLabelForActionButton.title = "Remove Selected Pictures"
                bottomLabelForActionButton.tintColor = UIColor.red
            }
        }
    }
    
    @IBOutlet weak var bottomLabelForActionButton: UIBarButtonItem!

    @IBAction func newCollectionOrDeleteSelectedButton(_ sender: UIBarButtonItem) {
    }

    

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set UP
        setMap(mapView, with: pin)
        //this will layout 3 pictures across
        setCollection(collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataCache.getPhotos(for: pin).count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! DetailCell
        
        if selectedIndex.contains(indexPath) {
                selectedIndex.remove(indexPath)
                cell.imageView.alpha = 1
        } else {
            selectedIndex.insert(indexPath)
            cell.imageView.alpha = 0.2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCellReusableID", for: indexPath) as! DetailCell
        let photoObject =
            dataCache.getPhotos(for: pin)[indexPath.row]
        
        cell.imageView.image = photoObject.image
        
        if photoObject.isImagePlaceholder {
            cell.activityIndicatorStart()
            //TODO:- figure out a way to move this to the Data Controller
            let block = { (data:Data?) in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async(execute: {
                        cell.imageView.image = image
                        cell.activityIndicatorStop()
                        let photo = Photo(height: Double(image.size.height),
                                          imageData: data, title: "", width: Double(image.size.width))
                        if self.dataCache.setPhoto(photo, atIndex: indexPath.row, for: self.pin)
                        { } else {
                            print("*****There was an error setting photo")
                        }
                    })
                }
            }

            let networkRequest = NetworkOperation(typeOfConnection: .lorempixel, delegate: self, successBlock: block, showActivityOnUI: false)
            networkRequest.start()
            
        } else {
            cell.activityIndicatorStop()
            
        }
        return cell
    }
}






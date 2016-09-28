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
                bottomLabelForActionButton.title = Constants.newCollection
                bottomLabelForActionButton.tintColor = UIColor.defaultBlue
            } else {
                bottomLabelForActionButton.title = Constants.removeSelected
                bottomLabelForActionButton.tintColor = UIColor.red
            }
        }
    }
    
    
    @IBOutlet weak var bottomLabelForActionButton: UIBarButtonItem!

    @IBAction func newCollectionOrDeleteSelectedButton(_ sender: UIBarButtonItem) {
        guard let buttonTitle = sender.title  else { return }
        
        collectionView.performBatchUpdates({
            if buttonTitle == Constants.removeSelected {
                var photos = self.dataCache.getPhotos(for: self.pin)
                let indexes = self.selectedIndex.map{$0.row}
                photos = photos.removingObjects(atIndexes: indexes)
                
                // resetting the selection because the cell objects are reused
                for each in self.selectedIndex {
                    let cell = self.collectionView.cellForItem(at: each) as! DetailCell
                    cell.imageView.alpha = 1
                }
                
                self.collectionView.deleteItems(at: Array(self.selectedIndex))
                self.selectedIndex.removeAll()
                self.dataCache.set(photos: photos, for: self.pin)
                
            } else {
                let photos = self.dataCache.getPhotos(for: self.pin, newSet: true)
                self.dataCache.set(photos: photos, for: self.pin)
                self.collectionView.reloadSections(IndexSet(integer: 0))
            }
            }, completion: { success in
            self.updateNoImageLabel()
        })
    }


    func updateNoImageLabel(){
        if self.dataCache.getPhotos(for: self.pin).isEmpty {
            self.noImagesLabel.isHidden = false
        } else {
            self.noImagesLabel.isHidden = true
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
//        let flickrSuccessBlock: (Data?) -> Void = { (data) in
//            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
//                let dict = json as? Dictionary<String, Any>, let photos = dict["photos"] as? Dictionary<String, Any>,
//                let photoArray = photos["photo"] as? [Dictionary<String, Any>]
//                else { return }
//            print(photoArray)
//        }
//        
//        NetworkOperation.flickrRandomAroundPinClient(pin: pin, delegate: self, successBlock: flickrSuccessBlock)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateNoImageLabel()
        setMap(mapView, with: pin)
        //this will layout 3 pictures across
        setCollection(collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        updateNoImageLabel()
        return dataCache.getPhotos(for: pin).count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! DetailCell
        if selectedIndex.contains(indexPath) {
                cell.imageView.alpha = 1
                selectedIndex.remove(indexPath)

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
//            let block = dataCache.createSuccessBlock(forCell: cell, forIndexPath: indexPath, withPin: pin)
//            let networkRequest = NetworkOperation(typeOfConnection: .lorempixel, delegate: self, successBlock: block, showActivityOnUI: false)
//            networkRequest.start()

        let block = dataCache.createSuccessBlockForRandomPicAtPin(forCell: cell, delegate: self, forIndexPath: indexPath, withPin: pin)
        NetworkOperation.flickrRandomAroundPinClient(pin: pin, delegate: self, successBlock: block)
            
        } else {
            cell.activityIndicatorStop()
            
        }
        return cell
    }
}






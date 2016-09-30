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
    var pin:PinAnnotation!
    func setPinForMap(_ pin:PinAnnotation) {
        self.pin = pin
    }
    
    var dataCache:DataController {
        return DataController.dataController
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
                let allPhotos = self.dataCache.getPhotos(for: self.pin)
                let indexes = self.selectedIndex.map{$0.row}
                let photosToRemove = indexes.map{allPhotos[$0]}
                
                // resetting the selection because the cell objects are reused
                for each in self.selectedIndex {
                    let cell = self.collectionView.cellForItem(at: each) as! DetailCell
                    cell.imageView.alpha = 1
                }
                
                self.collectionView.deleteItems(at: Array(self.selectedIndex))
                self.selectedIndex.removeAll()
                self.dataCache.removePhotos(photosToRemove, for: self.pin)
                
            } else {
                //this adds place holder photos to coreData
                self.dataCache.removeAllPhotos(for: self.pin)
                let _ = self.dataCache.getPhotos(for: self.pin, newSet: true)
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
        
        updateNoImageLabel()
        
        guard !dataCache.getPhotos(for: pin).isEmpty else {
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadSections(IndexSet(integer: 0))
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
                }, completion: { (success) in
            })
        
            return cell
        }
        let photoObject =
            dataCache.getPhotos(for: pin)[indexPath.row]
        
        cell.imageView.image = photoObject.image
        
        if photoObject.isImagePlaceholder {
            cell.activityIndicatorStart()
        
        let block = dataCache.createSuccessBlockForRandomPicAtPin(forCell: cell, delegate: self, forPhotoID: photoObject.photo_id!, withPin: pin)
        NetworkOperation.flickrRandomAroundPinClient(pin: pin, delegate: self, successBlock: block)
            
        } else {
            cell.activityIndicatorStop()
            
        }
        return cell
    }
}






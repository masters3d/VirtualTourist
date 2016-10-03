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
    UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {

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
    
    // Operation Que
    let neworkOperationsQueue:OperationQueue = {
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 2
            return queue
            }()
    
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
                
                self.neworkOperationsQueue.cancelAllOperations()
                
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
        collectionView.prefetchDataSource = self
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
        print("operations-------------->\(neworkOperationsQueue.operations.count)")
        print("max Operatios-------------->\(neworkOperationsQueue.maxConcurrentOperationCount)")

        updateNoImageLabel()
        let photos = dataCache.getPhotos(for: pin)

        guard !photos.isEmpty else {
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadSections(IndexSet(integer: 0))
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
                }, completion: { (success) in
            })
        
            return cell
        }
        
        let photoObject = photos[indexPath.row]
        
        cell.imageView.image = photoObject.image
        
        guard photoObject.isImagePlaceholder else {
            cell.activityIndicatorStop()
            return cell
        }
        
        guard !neworkOperationsQueue.isOperationInQueue(named: photoObject.photo_id ?? "") else {
            cell.activityIndicatorStart()
            return cell
        }
        
        // check if operation is already going
        
        let cellBlock:(UIImage?)->Void = { (image) in cell.imageView.image = image
                        cell.activityIndicatorStop()
                    }
        
        let block = dataCache.createSuccessBlockForRandomPicAtPin(forCellBlock: cellBlock, delegate: self, forPhotoID: photoObject.photo_id!, withPin: pin)
        let operation = NetworkOperation.flickrRandomAroundPinClient(pin: pin, delegate: self, successBlock: block)
        operation.name = photoObject.photo_id
        
        neworkOperationsQueue.addOperation(operation)
        
        cell.activityIndicatorStart()
        return cell
    }

    
    // prefetching protocol
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let indexes = indexPaths.map({$0.row})
        let photoObjects = dataCache.getPhotos(for: pin).enumerated().filter({indexes.contains($0.offset)}).map{$0.element}
        
        for (indexPathofPhoto,photoObject) in zip(indexPaths,photoObjects){
        
            guard photoObject.isImagePlaceholder, !neworkOperationsQueue.isOperationInQueue(named: photoObject.photo_id ?? "") else { continue }
            
            let blockUpdateCell:(UIImage?)->Void = { _ in
                    self.collectionView.reloadItems(at: [indexPathofPhoto])
            }
            
            let block = dataCache.createSuccessBlockForRandomPicAtPin(forCellBlock: blockUpdateCell, delegate: self, forPhotoID: photoObject.photo_id!, withPin: pin)
            let operation = NetworkOperation.flickrRandomAroundPinClient(pin: pin, delegate: self, successBlock: block)
            operation.name = photoObject.photo_id
            neworkOperationsQueue.addOperation(operation)
        }
        
}
    

}






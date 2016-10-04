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
    
    // Error handeling for Data
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataController.shared.errorHandlerDelegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DataController.shared.errorHandlerDelegate = nil
    }
    
    // Pin passed in from segue
    var pin:PinAnnotation!
    func setPinForMap(_ pin:PinAnnotation) {
        self.pin = pin
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
                let allPhotos = DataController.shared.getPhotos(for: self.pin)
                let indexes = self.selectedIndex.map{$0.row}
                let photosToRemove = indexes.map{allPhotos[$0]}
                
                // resetting the selection because the cell objects are reused
                for each in self.selectedIndex {
                    let cell = self.collectionView.cellForItem(at: each) as! DetailCell
                    cell.imageView.alpha = 1
                }
                
                self.collectionView.deleteItems(at: Array(self.selectedIndex))
                self.selectedIndex.removeAll()
                DataController.shared.removePhotos(photosToRemove, for: self.pin)
                
                // this cancell the current operations but each cell is able to added them back on.
                self.pin.neworkOperationsQueue.cancelAllOperations()
                
            } else {
            
                // invalidate current Operations
                self.pin.neworkOperationsQueue.cancelAllOperations()
                
                //this adds place holder photos to coreData
                DataController.shared.removeAllPhotos(for: self.pin)
                
                let pagesNumberRequest = NetworkOperation.flickrNumberOfPageforPin(self.pin, delegate: self)
                self.pin.neworkOperationsQueue.addOperation(pagesNumberRequest)
                
                // sets temp photos on the pin
                let photos =  DataController.shared.getPhotos(for: self.pin, newSet: true)
                
                // start download of new photos
                for each in photos {
                    let block = DataController.shared.createSuccessBlockForRandomPicAtPin(forCellBlock: {_ in return}, delegate: self, forPhotoID: each.photo_id!, withPin: self.pin)
                    let operation = NetworkOperation.flickrRandomAroundPinClient(pin: self.pin, delegate: self, successBlock: block)
                    operation.name = each.photo_id
                    operation.addDependency(pagesNumberRequest)
                    self.pin.neworkOperationsQueue.addOperation(operation)
                }
                
                self.collectionView.reloadSections(IndexSet(integer: 0))
            }
            }, completion: { success in
            self.updateNoImageLabel()
        })
    }


    func updateNoImageLabel(){
        if DataController.shared.getPhotos(for: self.pin).isEmpty {
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
       return DataController.shared.getPhotos(for: pin).count
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
        print("operations-------------->\(self.pin.neworkOperationsQueue.operations.count)")
        print("max Operatios-------------->\(self.pin.neworkOperationsQueue.maxConcurrentOperationCount)")

        updateNoImageLabel()
        let photos = DataController.shared.getPhotos(for: pin)

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
        
        guard !self.pin.neworkOperationsQueue.isOperationInQueue(named: photoObject.photo_id ?? "") else {
            cell.activityIndicatorStart()
            return cell
        }
        
        // check if operation is already going
        
        let cellBlock:(UIImage?)->Void = { (image) in cell.imageView.image = image
                        cell.activityIndicatorStop()
                    }
        
        let block = DataController.shared.createSuccessBlockForRandomPicAtPin(forCellBlock: cellBlock, delegate: self, forPhotoID: photoObject.photo_id!, withPin: pin)
        let operation = NetworkOperation.flickrRandomAroundPinClient(pin: pin, delegate: self, successBlock: block)
        operation.name = photoObject.photo_id
        
        self.pin.neworkOperationsQueue.addOperation(operation)
        
        cell.activityIndicatorStart()
        return cell
    }

    
    // prefetching protocol
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let indexes = indexPaths.map({$0.row})
        let photoObjects = DataController.shared.getPhotos(for: pin).enumerated().filter({indexes.contains($0.offset)}).map{$0.element}
        
        for (indexPathofPhoto,photoObject) in zip(indexPaths,photoObjects){
        
            guard !self.pin.neworkOperationsQueue.isOperationInQueue(named: photoObject.photo_id ?? "") else {
                continue
            }
            guard photoObject.isImagePlaceholder, !self.pin.neworkOperationsQueue.isOperationInQueue(named: photoObject.photo_id ?? "") else { continue }
            
            let blockUpdateCell:(UIImage?)->Void = { _ in
                    self.collectionView.reloadItems(at: [indexPathofPhoto])
            }
            
            let block = DataController.shared.createSuccessBlockForRandomPicAtPin(forCellBlock: blockUpdateCell, delegate: self, forPhotoID: photoObject.photo_id!, withPin: pin)
            let operation = NetworkOperation.flickrRandomAroundPinClient(pin: pin, delegate: self, successBlock: block)
            operation.name = photoObject.photo_id
            self.pin.neworkOperationsQueue.addOperation(operation)
        }
        
}
    

}






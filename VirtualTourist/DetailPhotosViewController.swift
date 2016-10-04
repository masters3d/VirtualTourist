//
//  DetailPhotosController.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/25/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class DetailPhotosViewController: UIViewController, ErrorReporting,
    UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching, NSFetchedResultsControllerDelegate {

    // Error Reporting Protocol Requirements
    var errorReported: Error?
    var isAlertPresenting: Bool = false
    
    // Pin passed in from segue
    var pin:PinAnnotation! {didSet{ photoResultsController = DataController.coreDataFetchPhotosControllerForPin(pin)}}
    func setPinForMap(_ pin:PinAnnotation) {
        self.pin = pin
    }
    // result controller
    var photoResultsController:NSFetchedResultsController<Photo>!
    
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
                let allPhotos = DataController.shared.getAllPhotos(self.photoResultsController)
                let indexes = self.selectedIndex.map{$0.row}
                let photosToRemove = indexes.map{allPhotos[$0]}
                
                // resetting the selection because the cell objects are reused
                for each in self.selectedIndex {
                    let cell = self.collectionView.cellForItem(at: each) as! DetailCell
                    cell.imageView.alpha = 1
                }
                
                self.collectionView.performBatchUpdates({
                    self.collectionView.deleteItems(at: Array(self.selectedIndex))
                    self.selectedIndex.removeAll()
                    DataController.shared.removePhotos(photosToRemove, for: self.pin)
                    self.neworkOperationsQueue.cancelAllOperations()
                }, completion: { (_) in
                   //we could reload stuff here
                })
                
                
            } else {
                //this adds place holder photos to coreData
                self.collectionView.performBatchUpdates({
                    DataController.shared.removeAllPhotos(for: self.pin)
                    let _ = DataController.shared.getPlaceHolderPhotos(for: self.pin)
                    
//                    DataController.shared.getAllPhotos(self.photoResultsController)
//                    self.collectionView.reloadSections(IndexSet(integer: 0))

                  let _ =  self.reloadCollectionViewIfEmpty()
                })
            }
            }, completion: { success in
            self.updateNoImageLabel()
        })
    }


    func updateNoImageLabel(){
        if DataController.shared.getAllPhotos(photoResultsController).isEmpty {
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
        photoResultsController.delegate = self
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
        return DataController.shared.getAllPhotos(photoResultsController).count
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
        
        let photoObject = photoResultsController.object(at: indexPath)
        
        cell.imageView.image = photoObject.image
        
        guard photoObject.isImagePlaceholder else {
            cell.activityIndicatorStop()
            return cell
        }
        
        guard !neworkOperationsQueue.isOperationInQueue(named: photoObject.photo_id ?? "") else {
            cell.activityIndicatorStart()
            return cell
        }
        
        if reloadCollectionViewIfEmpty() {
            return cell
        }
        
        // check if operation is already going
        
        let cellBlock:(UIImage?)->Void = { (image) in cell.imageView.image = image
                        cell.activityIndicatorStop()
                    }
        
        let block = DataController.shared.createSuccessBlockForRandomPicAtPin(forCellBlock: cellBlock, delegate: self, forPhotoID: photoObject.photo_id!, withPin: pin)
        let operation = NetworkOperation.flickrRandomAroundPinClient(pin: pin, delegate: self, successBlock: block)
        operation.name = photoObject.photo_id
        
        neworkOperationsQueue.addOperation(operation)
        
        cell.activityIndicatorStart()
        return cell
    }

    
    // prefetching protocol
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let indexes = indexPaths.map({$0.row})
        let photoObjects = DataController.shared.getAllPhotos(photoResultsController).enumerated().filter({indexes.contains($0.offset)}).map{$0.element}
        
        for (_,photoObject) in zip(indexPaths,photoObjects){
        
            guard photoObject.isImagePlaceholder, !neworkOperationsQueue.isOperationInQueue(named: photoObject.photo_id ?? "") else { continue }
            
            let blockUpdateCell:(UIImage?)->Void = { _ in
                   // self.collectionView.reloadItems(at: [indexPathofPhoto])
            }
            
            let block = DataController.shared.createSuccessBlockForRandomPicAtPin(forCellBlock: blockUpdateCell, delegate: self, forPhotoID: photoObject.photo_id!, withPin: pin)
            let operation = NetworkOperation.flickrRandomAroundPinClient(pin: pin, delegate: self, successBlock: block)
            operation.name = photoObject.photo_id
            neworkOperationsQueue.addOperation(operation)
        }
    }
    
    // Fetch result controller 
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    
        switch type {
        case .update:
            if let indexPath = indexPath {
                self.collectionView.reloadItems(at: [indexPath])
            }
            if let newIndexPath = newIndexPath {
                self.collectionView.reloadItems(at: [newIndexPath])
            }
        case .delete:
            let _ = reloadCollectionViewIfEmpty()
        default: break
        
        }
    }
    
    func reloadCollectionViewIfEmpty() -> Bool{
        let photos = DataController.shared.getAllPhotos(photoResultsController)
        // this helps prevent the NSInternalInconsistencyException
        guard !photos.isEmpty else {
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadSections(IndexSet(integer: 0))
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
                }, completion: { (success) in
            })
            return true
        }
        return false
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      let _ = reloadCollectionViewIfEmpty()
    }
    
}






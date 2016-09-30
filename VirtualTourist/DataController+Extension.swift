//
//  DataController+Extension.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/27/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit


extension DataController {

func createSuccessBlockForRandomPicAtPin(forCell cell: DetailCell, delegate:ErrorReporting, forIndexPath indexPath:IndexPath, withPin pin: PinAnnotation) -> (Data?) -> (){
    let block = { (data:Data?) in
        
        guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
            let dict = json as? Dictionary<String, Any>, let photos = dict["photos"] as? Dictionary<String, Any>,
            let photoArray = photos["photo"] as? [Dictionary<String, Any>]
            else {print("error parsing at \(#line) \(#file)"); return}
        
            guard !photoArray.isEmpty else {
            
                //TODO: In core data I should just delte the object instead of setting it here.
                // feels too magical though
                self.set(photos: [], for: pin)
                
                DispatchQueue.main.async(execute: {
                   guard let detailViewController = delegate as? DetailPhotosViewController
                        else { print("Casting failed for DetailPhotosViewController "); return }
                    detailViewController.collectionView.reloadData()
                    
                    })
                                return
            }
        var randomImageDictionary:[String : Any]
        if photoArray.count > 1 {
             randomImageDictionary = photoArray[randomNumberFrom1To(photoArray.count-1)]
        } else {
             randomImageDictionary = photoArray[0]
        }
        guard let imageURL = randomImageDictionary["url_m"] as? String  else {print("ERROR: \(#line) \(#file)"); return}
        guard let title = randomImageDictionary["title"] as? String  else {print("ERROR: \(#line) \(#file)"); return}
        guard let photo_id = randomImageDictionary["id"] as? String  else {print("ERROR: \(#line) \(#file)"); return}

        let sucessBlock = { (imageData:Data?) in
            if let data = imageData, let image = UIImage(data: data) {
                DispatchQueue.main.async(execute: {
                    cell.imageView.image = image
                    cell.activityIndicatorStop()
                    
                    //TODO:- Editing the photo reference should set it
                    // Need to make a differeiciation here
                    // we are just creating a new file here.
                    let photo = Photo.coreDataObject(height: Double(image.size.height),
                                      imageData: data, title: title, width: Double(image.size.width), photo_id: photo_id, pin:pin)


                    if self.setPhoto(photo, atIndex: indexPath.row, for: pin)
                    { } else {
                        print("*****There was an error setting photo")
                    }
                })
            }
        }
        
        let imageNetworkRequest = NetworkOperation(typeOfConnection: ConnectionType.getOneFlickrImage(url: imageURL), delegate: delegate, successBlock: sucessBlock, showActivityOnUI: false)
        imageNetworkRequest.start()
        
    }

    return block
}

func createSuccessBlockForSample(forCell cell: DetailCell, forIndexPath indexPath:IndexPath, withPin pin: PinAnnotation) -> (Data?) -> (){
        let block = { (data:Data?) in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async(execute: {
                        cell.imageView.image = image
                        cell.activityIndicatorStop()
                        let photo = Photo.coreDataObject(height: Double(image.size.height),
                                          imageData: data, title: "", width: Double(image.size.width), pin:pin)
                        if self.setPhoto(photo, atIndex: indexPath.row, for: pin)
                        { } else {
                            print("*****There was an error setting photo")
                        }
                    })
                }
            }

    return block
}



}

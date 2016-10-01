//
//  DataController+Extension.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/27/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit


extension DataController {

func createSuccessBlockForRandomPicAtPin(forCell cell: DetailCell, delegate:ErrorReporting, forPhotoID photoId:String, withPin pin: PinAnnotation) -> (Data?) -> (){
    let block = { (data:Data?) in
        
        guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
            let dict = json as? Dictionary<String, Any>, let photos = dict["photos"] as? Dictionary<String, Any>,
            let photoArray = photos["photo"] as? [Dictionary<String, Any>]
            else {print("error parsing at \(#line) \(#file)"); return}
        
            guard !photoArray.isEmpty else {

                self.removeAllPhotos(for: pin)
                
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
        guard let imageURL = randomImageDictionary["url_s"] as? String  else {print("ERROR: \(#line) \(#file)"); return}
        guard let title = randomImageDictionary["title"] as? String  else {print("ERROR: \(#line) \(#file)"); return}
        guard let photo_id = randomImageDictionary["id"] as? String  else {print("ERROR: \(#line) \(#file)"); return}

        let sucessBlock = { (imageData:Data?) in
            if let data = imageData, let image = UIImage(data: data) {
                DispatchQueue.main.async(execute: {
                    cell.imageView.image = image
                    cell.activityIndicatorStop()

                let blockToEditObj = Photo.coreDataEditObjectBlockCreator(height: Double(image.size.height),
                                      imageData: data, title: title, width: Double(image.size.width), photo_id: photo_id)
                self.editPhoto(withPhotoId: photoId, for: pin, withBlock: blockToEditObj)
                })
            }
        }
        
        let imageNetworkRequest = NetworkOperation(typeOfConnection: ConnectionType.getOneFlickrImage(url: imageURL), delegate: delegate, successBlock: sucessBlock, showActivityOnUI: false)
        imageNetworkRequest.start()
    }

    return block
}

}

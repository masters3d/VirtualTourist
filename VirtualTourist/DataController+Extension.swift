//
//  DataController+Extension.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/27/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit


extension DataController {

func createSuccessBlockForRandomPicAtPin(forCell cell: DetailCell, delegate:ErrorReporting, forIndexPath indexPath:IndexPath, withPin pin: Pin) -> (Data?) -> (){
    let block = { (data:Data?) in
        
        guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
            let dict = json as? Dictionary<String, Any>, let photos = dict["photos"] as? Dictionary<String, Any>,
            let photoArray = photos["photo"] as? [Dictionary<String, Any>]
            else {print("error parsing at \(#line) \(#file)"); return}
        
        let randomImageDictionary = photoArray[randomNumberFrom1To(photoArray.count-1)]
        
        guard let imageURL = randomImageDictionary["url_m"] as? String  else {print("ERROR: \(#line) \(#file)"); return}
        
        let sucessBlock = { (imageData:Data?) in
            if let data = imageData, let image = UIImage(data: data) {
                DispatchQueue.main.async(execute: {
                    cell.imageView.image = image
                    cell.activityIndicatorStop()
                    let photo = Photo(height: Double(image.size.height),
                                      imageData: data, title: "", width: Double(image.size.width))
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

func createSuccessBlockForSample(forCell cell: DetailCell, forIndexPath indexPath:IndexPath, withPin pin: Pin) -> (Data?) -> (){
        let block = { (data:Data?) in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async(execute: {
                        cell.imageView.image = image
                        cell.activityIndicatorStop()
                        let photo = Photo(height: Double(image.size.height),
                                          imageData: data, title: "", width: Double(image.size.width))
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

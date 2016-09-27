//
//  DataController+Extension.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/27/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit


extension DataController {

func createSuccessBlock(forCell cell: DetailCell, forIndexPath indexPath:IndexPath, withPin pin: Pin) -> (Data?) -> (){
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

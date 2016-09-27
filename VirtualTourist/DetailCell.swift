//
//  DetailCell.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/25/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit

class DetailCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
}

extension DetailCell:ActivityReporting {

    func activityIndicatorStart() {
        DispatchQueue.main.async(execute: {
            [weak self] in
           self?.activityIndicator.startAnimating()
            print("DetailView Activity Start")
        })}
    func activityIndicatorStop() {
        DispatchQueue.main.async(execute: {
            [weak self] in
           self?.activityIndicator.stopAnimating()
            print("DetailView Activity Stop")
        })}
}

extension UIActivityIndicatorView {
    // probably better to extend this object with ActivityReporting
    // then pass this ActivityReporting object around
    // the process could directly stop and start. 
    // the obove inderection forces us to Dispatch on the main queue 
    // eventhough obove is called within the Main Queue
}



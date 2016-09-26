//
//  DetailViewController.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/25/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit
import MapKit


class DetailViewController: UIViewController, ErrorReporting {

// Error Reporting Protocol Requirements
    var errorReported: Error?
    var isAlertPresenting: Bool = false

    @IBOutlet weak var noImagesLabel: UILabel!

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        

        let randomImageSuccessBlock:(Data?) -> Void = { data in
            if let data = data {
                print(data)
            }
        }
        let randomImageNetwork = NetworkOperation(typeOfConnection: .lorempixel, delegate: self, successBlock: randomImageSuccessBlock)

        randomImageNetwork.start()
        
        }

}

//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/22/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add the edit button on the right
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    lazy var infoView: UILabel = {
        let size = CGSize(width: self.view.frame.size.width, height: 70 )
        let origin = CGPoint(x: self.view.frame.origin.x, y: self.view.frame.height - 70)
        let frame = CGRect(origin: origin , size: size)
        let info = UILabel(frame: frame )
        info.backgroundColor = UIColor.white
        info.textColor = UIColor.red
        info.textAlignment = .center
        info.text = "Tap Pins to Delete"
        info.font = UIFont.boldSystemFont(ofSize: 14)
        return info
    }()

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            view.addSubview(infoView)
        } else {
            infoView.removeFromSuperview()
        }
        
}

}


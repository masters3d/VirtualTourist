//
//  MapView+Extensions.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/23/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit


extension MapViewController {
    
    func infoViewCreator() -> UILabel {
        let size = CGSize(width: self.view.frame.size.width, height: 70 )
        let origin = CGPoint(x: self.view.frame.origin.x, y: self.view.frame.height - 70)
        let frame = CGRect(origin: origin , size: size)
        let info = UILabel(frame: frame )
        info.backgroundColor = UIColor.red
        info.textColor = UIColor.white
        info.textAlignment = .center
        info.text = "Tap Pins to Delete"
        info.font = UIFont.boldSystemFont(ofSize: 14)
        return info
    }
}

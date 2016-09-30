//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/28/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import MapKit


extension Double {

func roundingTo3Significante() -> Double {
    let number = Double(1000) * self
    return Double(number.rounded()/1000.0)
}
}

typealias BBox = CLLocationCoordinate2D
extension CLLocationCoordinate2D {

    var boundingBox:String {
        let minLon = max(longitude - 1, -180)
        let minLat = max(latitude - 1, -90)
        let maxLon = min(longitude + 1, 180)
        let maxLat = min(latitude + 1, 90)
        return "\(minLon),\(minLat),\(maxLon),\(maxLat)"
    }
    
    var shortDescription:String {
        return "\(longitude.roundingTo3Significante())x\(latitude.roundingTo3Significante())"}
}

enum APIConstants {
    
    static let albumSize = 20

    static let flickrBaseUrl = "https://api.flickr.com/services/rest"
    
    static var flickrAPIKey:String {
        guard let path = Bundle.main.path(forResource: "SecretAPIKeys", ofType: "plist"),
            let nsarray = NSArray(contentsOfFile: path),
            let array = nsarray as? Array<String>,
            let key = array.first
            else { fatalError("Flickr API key not included. Please overide the APIConstants.flickrAPIKey with your API key")}
        return key
    }
    // we used this for testing
    static let lorempixel = "https://loremflickr.com/320/240"
}

func randomNumberFrom1To(_ to:Int) -> Int {
    return Int(arc4random_uniform(UInt32(to))+1)
}

extension NetworkOperation {

    
    static func flickrRandomAroundPinClient(pin:PinAnnotation, delegate: ErrorReporting, successBlock:@escaping (Data?)->Void){
        
        let pageBlock:((Data?)->Void) = {
            data in
            
        
            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) else {print("error parsing at \(#line) \(#file)"); return}
             guard  let dict = json as? Dictionary<String, Any> else {print("error parsing at \(#line) \(#file)"); return}
            guard let photos = dict["photos"] as? Dictionary<String, Any> else {print("error parsing at \(#line) \(#file)"); return}
               guard var pages = photos["pages"] as? Int
                else {print("error parsing at \(#line) \(#file)"); return}
            
            if pages > 1 {
                pages = randomNumberFrom1To(pages)
            }
            let photosConnection = ConnectionType.flickrRandomAroundPin(bbox: pin.coordinate, page: pages)
            
            let networkRequestPhotos = NetworkOperation.init(typeOfConnection: photosConnection, delegate: delegate, successBlock: successBlock, showActivityOnUI: false)
            
            networkRequestPhotos.start()
            
        }
        let pageConnection = ConnectionType.flickrRandomAroundPin(bbox: pin.coordinate, page: 1)

        let networkRequestPage = NetworkOperation.init(typeOfConnection: pageConnection, delegate: delegate, successBlock: pageBlock, showActivityOnUI: false)
        
        networkRequestPage.start()
    }
}





















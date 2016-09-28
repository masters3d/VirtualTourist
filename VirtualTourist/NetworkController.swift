//
//  NetworkController.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/26/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit
import Swift

extension Array {

func removingObjects(atIndexes: [Int]) -> Array {
    return self.enumerated()
    .filter { !atIndexes.contains($0.offset) }
    .map { $0.element }
}
}

class NetworkOperation: Operation, URLSessionDataDelegate {
    //Error Reporting
    var delegate: ErrorReporting?

    // custom fields
    fileprivate var url: URL?
    fileprivate var keyString: String?
    var request: URLRequest?

    // default
    fileprivate var data = NSMutableData()
    fileprivate var startTime: TimeInterval? = nil
    fileprivate var totalTime: TimeInterval? = nil
    

    // Still need this workaround to overide getter only isFinish
    fileprivate var tempFinished: Bool = false
    override var isFinished: Bool {
        set {
            willChangeValue(forKey: "isFinished")
            tempFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
        get {
            return tempFinished
        }
    }
    
    //call back function that has data
    private var finishedData: Data?
    fileprivate func getFinishedData() -> Data? {
        return finishedData
    }
    
    // Inserts a block to start function
    fileprivate var startingBlock:()->Void = {}

    override func start() {

        startingBlock()

        // clears up any errors in the delegate
        DispatchQueue.main.async(execute: {
            self.delegate?.reportErrorFromOperation(.none)
        })

        if isCancelled {
            isFinished = true
            return
        }

        let config = URLSessionConfiguration.default
        let session = Foundation.URLSession(configuration: config, delegate: self, delegateQueue: nil)

        // session name for debugging
        session.sessionDescription = keyString

        if let request = request {
            let task = session.dataTask(with: request)
            startTime = Date.timeIntervalSinceReferenceDate
            task.resume()
        }
    }

    init(url: URL, keyForData: String) {
        super.init()
        self.url = url
        self.keyString = keyForData
        self.request = URLRequest(url: url)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {

        guard let httpResponse = response as? HTTPURLResponse else {
            fatalError("Unexpected response type")
        }

        switch httpResponse.statusCode {
        case 200:
            completionHandler(.allow)
        case 201:
            completionHandler(.allow)
        default:
            let connectionError = NSError(domain: "Check your login information.", code: httpResponse.statusCode, userInfo: nil)
            print(connectionError.localizedDescription)
            DispatchQueue.main.async(execute: {
                self.delegate?.reportErrorFromOperation(connectionError)
            })
            completionHandler(.cancel)
            isFinished = true
        }
        print("return code for server: \(httpResponse.statusCode) for session: \(session.sessionDescription  ?? "no description" )")
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive incomingData: Data) {
        data.append(incomingData)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Failed! \(error)")
            // sending error to delagate UI on the main queue
            DispatchQueue.main.async(execute: {
                self.delegate?.reportErrorFromOperation(error)
            })

            isFinished = true
            return
        }

        //MARk:-ProcessData() and save or use coredata
        //UserDefaults.standard.set(data, forKey: keyString ?? "")
        if data.length > 0 {
            self.finishedData =  data as Data
        }

        totalTime = Date.timeIntervalSinceReferenceDate - startTime! // this should always have a value
        isFinished = true
    }
}

extension NetworkOperation {

    internal convenience init(typeOfConnection: ConnectionType, delegate: ErrorReporting,
                    successBlock:@escaping (Data?)->Void = { _ in },
                    showActivityOnUI:Bool = true
                    ) {
        
                    self.init(typeOfConnection:typeOfConnection)
                    self.delegate = delegate
        
                    if showActivityOnUI {
                        self.startingBlock = {
                            DispatchQueue.main.async(execute: {
                                delegate.activityIndicatorStart()
                            } ) }
                        
                        self.completionBlock = {
                            DispatchQueue.main.async(execute: {
                                delegate.activityIndicatorStop()
                            } )
                            successBlock(self.getFinishedData())
                            }
                    } else {
                        self.completionBlock = { successBlock(self.getFinishedData()) }
                    }
        } // convenience
}



extension NetworkOperation {

    static func escapeForURL(_ input: String) -> String? {
        return input.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    }
    
   private static func parameterFromDict(_ dict:[String : Any]) -> [URLQueryItem] {
        var result = [URLQueryItem]()
        for each in dict {
            let item = URLQueryItem(name: each.key, value: String(describing: each.value))
            result.append(item)
        }
        return result
    }
    
    static func componentsMaker(baseUrl:String, querryKeyValue:[String : Any] )-> URLComponents? {
        var components = URLComponents.init(string: baseUrl)!
        components.queryItems = parameterFromDict(querryKeyValue)
        return components
    }
}


//MARK: -  CONFIGURATION FLICKR CLIENT

enum ConnectionType {
    case lorempixel
    case flickrRandomAroundPin(bbox:BBox, page:Int )
    case getOneFlickrImage(url:String)
    
    var stringValue:String {
        switch self {
        case .lorempixel: return "lorempixel"
        case .flickrRandomAroundPin(let payload) : return "flickrRandomAroundPin\(payload.bbox.shortDescription)Page\(payload.page)"
        case .getOneFlickrImage(let payload) : return "getOneFlickrImage \(payload.components(separatedBy: "/").last ?? "")"
        }
    }
}

extension NetworkOperation {
    fileprivate convenience init(typeOfConnection: ConnectionType) {
        switch typeOfConnection {
        case .lorempixel:
            self.init(url:URL(string: APIConstants.lorempixel)!, keyForData:typeOfConnection.stringValue)
            
        case .flickrRandomAroundPin(let payload):
            let querryDict:[String:Any] = ["extras": "url_m", "safe_search": 1, "bbox": payload.bbox.boundingBox, "api_key": APIConstants.flickrAPIKey, "method": "flickr.photos.search", "per_page": 250, "format": "json", "nojsoncallback": 1]
            guard  let compotentsForUrl = NetworkOperation.componentsMaker(baseUrl:APIConstants.flickrBaseUrl, querryKeyValue: querryDict), let url = compotentsForUrl.url else { fatalError("Malform URL") }

            self.init(url: url, keyForData:typeOfConnection.stringValue)
        case .getOneFlickrImage(let url) :
            self.init(url:URL(string: url)!,keyForData:typeOfConnection.stringValue)
        }
    }
}




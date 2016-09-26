//
//  SharedErrorHandeling.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/25/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit

protocol ActivityReporting {
    func activityIndicatorStart()
    func activityIndicatorStop()
}

extension ActivityReporting {
    func activityIndicatorStart() {
        print("activityIndicatorStart")
    }
    func activityIndicatorStop() {
        print("activityIndicatorStop")
    }
}

protocol ErrorReporting: class, ActivityReporting {
    // optional for UIViewControllers
    func reportErrorFromOperation(_ operationError: Error?)
    
    //Required
    var errorReported: Error? { get set }
    var isAlertPresenting: Bool { get set }
}

// UIView handeling
extension ErrorReporting where Self : UIViewController  {

    //Consumes error by setting it to nil after presenting
   private func presentErrorConsumingPopUp() {
        if let error = self.errorReported {
            presentErrorPopUp(error.localizedDescription)
            self.errorReported = nil
        } else {
            print("Could not run presentErrorConsumingPopUp")
        }
    }

    func presentErrorPopUp(_ description: String) {
        self.isAlertPresenting = true
        let errorActionSheet = UIAlertController(title: "Error: Please Try again", message: description, preferredStyle: .alert)
        let tryAgain = UIAlertAction(title: "Okay", style: .default, handler: nil) 
        errorActionSheet.addAction(tryAgain)
        self.present(errorActionSheet, animated: true, completion: {
            self.isAlertPresenting = false
          })
    }

    // Error reporting
    func reportErrorFromOperation(_ operationError: Error?) {
            print("presenting error:\(isAlertPresenting)")
        if let operationError = operationError ,
            self.errorReported == nil && isAlertPresenting == false {
            // sets the error on the delegate
            self.errorReported = operationError
            // presents errors and sets it to nil
            self.presentErrorConsumingPopUp()
            self.activityIndicatorStop()

        } else {
            self.errorReported = nil
        }
    }
}


//
//  utils.swift
//  ceburilo-ios
//
//  Created by James on 05/06/2017.
//  Copyright © 2017 James. All rights reserved.
//

import UIKit

func displayAlert(_ title: String?, message: String?, viewcontroller: UIViewController!) {
    let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
    
    alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
    viewcontroller.present(alert, animated: true, completion: nil)
}

extension String {
    func dropLast(_ n: Int = 1) -> String {
        return String(characters.dropLast(n))
    }
    var dropLast: String {
        return dropLast()
    }
}

let notificationName = Notification.Name("Notification-Path")


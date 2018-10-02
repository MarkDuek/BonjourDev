//
//  ActionViewController.swift
//  BonjourDev
//
//  Created by Mark Duek on 27/09/18.
//  Copyright © 2018 Mark Duek. All rights reserved.
//

import Foundation
import UIKit

/**
 ViewController of the Apple TV Action Scene
 - Author: Mark Duek
 - Version: 0.1 Plus Ultra
 - Important: Nothing at all
 */

class TVActionViewController: UIViewController {
    var backGroundColor: UIColor!
    var timer: Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        //creating timer
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(changeColor), userInfo: nil, repeats: true)
    }
    @objc func changeColor() {
        if SocketManager.shared.colorToChange == "yes" {
            switch self.view.backgroundColor {
            case UIColor.black:
                forceTheChange(color: UIColor.orange)
            case UIColor.orange:
                forceTheChange(color: UIColor.blue)
            case UIColor.blue:
                forceTheChange(color: UIColor.black)
            default:
                print("Nothing Happends")
            }
        }
        SocketManager.shared.colorToChange = "NotChange"
    }
    func forceTheChange(color: UIColor){
        self.view.backgroundColor = color
        self.reloadInputViews()
    }
}

//
//  UI Extension.swift
//  BonjourDev
//
//  Created by Mark Duek on 27/09/18.
//  Copyright © 2018 Mark Duek. All rights reserved.
//

import Foundation
import UIKit

//MARK: - UIButton Extensions

extension UIButton {
    
    /**
     Initiates a default Label
     - Parameters:
        - label: Button text
        - top: Distance from the top of the screen
        - controller: ViewController where you are initianting the button
     
     */
    convenience init(label: String, top: Float, controller: UIViewController) {
        
        self.init(type: .system)
        
        self.setTitle(label, for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.adjustsImageWhenHighlighted = true
        self.isUserInteractionEnabled = true
        self.titleLabel?.font = UIFont(name: (self.titleLabel?.font.fontName)!, size: 30)
        
        controller.view.addSubview(self)
        print(UIDevice.current.model)
        if UIDevice.current.model == "Apple TV" {
            self.backgroundColor = UIColor.white
            self.setTitleColor(UIColor.black, for: .normal)


            self.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor, constant: (CGFloat(top))).isActive = true
            self.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor).isActive = true
            self.heightAnchor.constraint(equalToConstant: 124).isActive = true
            self.widthAnchor.constraint(equalToConstant: 436).isActive = true
            
        }else {
            self.backgroundColor = UIColor.white
            self.setTitleColor(UIColor.black, for: .normal)


            self.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor, constant: (CGFloat(top))).isActive = true
            self.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor).isActive = true
            self.heightAnchor.constraint(equalToConstant: 80).isActive = true
            self.widthAnchor.constraint(equalToConstant: 280).isActive = true
        }
        
    }
}

//MARK: - UILabel Extensions


extension UILabel {
    
    /**
     Initiates a default Label
     - Parameters:
        - txt: Label text
        - controller: ViewController where you are initianting the button
     
     */
    convenience init (txt: String, controller: UIViewController) {
        
        self.init()
        
        self.numberOfLines = 0
        self.text = txt
        if UIDevice.current.model == "Apple TV" {
            
            self.font = UIFont(name: self.font.fontName, size: 80)
            self.textColor = UIColor.black

        }
        else {
            
            self.font = UIFont(name: self.font.fontName, size: 30)
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
    
        controller.view.addSubview(self)
        if UIDevice.current.model == "Apple TV" {
            self.textColor = UIColor.black
            self.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor, constant: -328).isActive = true

        }
        else {
            self.textColor = UIColor.devOrange
            self.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor, constant: -180).isActive = true
        }
        
        self.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor).isActive = true
    }
}

//MARK: - UIColor Extensions

extension UIColor {
    
    static let devOrange = UIColor(red: 242.0/255, green: 101.0/255, blue: 34.0/255, alpha: 1.0)
    
    /**
     Cycles betwen black and orange colors
     */
    var nextColor: UIColor {
        switch self {
        case .black:
            return .devOrange
        case .devOrange:
            return .black
        default:
            return .black
        }
    }
}


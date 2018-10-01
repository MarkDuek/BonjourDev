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
 ViewController of the Mobile Action Scene
 - Author: Mark Duek
 - Version: 0.1 Plus Ultra
 - Important: Nothing at all
 */


class ActionViewController: UIViewController {
    var btn: UIButton!
    var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAll()
        
    }
    
    //MARK: - Creating Itens

    /**
     Create all elements in the scene
     */
    func createAll(){
        btn = UIButton(label: "Change Color!", top: 9, controller: self)
        label = UILabel(txt: "Mudar a cor", controller: self)
        self.view.backgroundColor = .devOrange
        
        
    }
    func showThatIsConnected(){
        SocketManager.shared.client.send(dictionary: ["isConnected": true])
    }
    
}

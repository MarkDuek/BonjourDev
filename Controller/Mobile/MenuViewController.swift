//
//  ViewController.swift
//  BonjourDev
//
//  Created by Mark Duek on 27/09/18.
//  Copyright © 2018 Mark Duek. All rights reserved.
//

import UIKit
/**
 ViewController of the Mobile Menu Scene
 - Author: Mark Duek
 - Version: 0.1 Plus Ultra
 - Important: Nothing at all
 */


class MenuViewController: UIViewController {
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
        btn = UIButton(label: "Buscar", top: 9, controller: self)
        btn.addTarget(self, action: #selector(changeView), for:UIControlEvents.touchUpInside)
        label = UILabel(txt: "Tutorial Bonjour", controller: self)
        self.view.backgroundColor = .black

    }
    
    @objc func changeView(_ sender: UIButton) {
        if sender.titleLabel?.text == "Buscar" {
            self.dismiss(animated: false, completion: nil)
            self.present(SearchingViewController() as UIViewController, animated: false, completion: nil)
        }
    }
}



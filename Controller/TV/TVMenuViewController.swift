//
//  MenuViewController.swift
//  Folclore Incrivel
//
//  Created by Bruno Arnaud on 10/09/2018.
//  Copyright © 2018 Rodrigo Bukowitz. All rights reserved.
//

import Foundation
import UIKit

/**
 ViewController of the Apple TV Menu Scene
 - Author: Mark Duek
 - Version: 0.1 Plus Ultra
 - Important: Nothing at all
*/

class TVMenuViewController: UIViewController {
    var btn: UIButton!
    var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAll()
    }

//    override func viewDidAppear(_ animated: Bool) {
//        if (GameSocketManager.shared.server != nil) {
//            GameSocketManager.shared.server.closeServerSockets()
//            GameMaster.shared.players = []
//        }
//    }
    
     //MARK: - Creating Itens

    /**
     Create the background
     */
    func createBackGround() {
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        bg.layer.zPosition = -1
        bg.backgroundColor = .devOrange

        self.view.addSubview(bg)
    }
    /**
     Create all elements in the scene
     */
    func createAll() {
        createBackGround()
        btn = UIButton(label: "Abrir Servidor", top: -80, controller: self)
        btn.addTarget(self, action: #selector(changeView), for: .allEvents)
        label = UILabel(txt: "Tutorial Bonjour", controller: self)
    }

    //MARK: - Button Action
    
    /**
     Change the view depending on the button
     */
    @objc func changeView(_ sender: UIButton) {
        if sender.titleLabel?.text == "Abrir Servidor"{
            self.dismiss(animated: false, completion: nil)
            self.present(TVSearchViewController() as UIViewController, animated: true, completion: nil)
        }
    }

}



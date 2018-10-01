//
//  SearchingViewController.swift
//  BonjourDev
//
//  Created by Mark Duek on 27/09/18.
//  Copyright © 2018 Mark Duek. All rights reserved.
//

import Foundation
import UIKit

/**
 ViewController of the Apple TV Searching for Clients Scene
 - Author: Mark Duek
 - Version: 0.1 Plus Ultra
 - Important: Nothing at all
 */

class TVSearchViewController: UIViewController {
    var btn: UIButton!
    var timer : Timer!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Rodrigo")
        SocketManager.shared.setUpServer(name: "testeDevPlusUltra")
        createAll()
    }
    
    //MARK: - Creating Itens

    /**
     Create all elements in the scene
     */
    func createAll() {
        createBackGround()
        createActivityIndicatory()
        btn = UIButton(label: "Começar", top: -80, controller: self)
        btn.addTarget(self, action: #selector(changeView), for: .allEvents)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector (changeColorWhenConnected) , userInfo: nil, repeats: true)

    }
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
     Creates the activity indicator
     */
    @objc func createActivityIndicatory() {
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: self.view.frame.width/2.3, y:  self.view.frame.height/10, width: self.view.frame.width/8, height: self.view.frame.width/8))
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
  
        self.view.addSubview(actInd)
        actInd.startAnimating()
    }
    
    @objc func changeColorWhenConnected() {
        print("ENTROU")
        if SocketManager.shared.isConnected == true  {
            print("BDWIHBIWBCI")
            self.view.backgroundColor = .black
        }
    }
    
    /**
     Change the view depending on the button
     */
    @objc func changeView(_ sender: UIButton) {
        if sender.titleLabel?.text == "Começar"{
            self.present(TVActionViewController() as UIViewController, animated: true, completion: nil)
        }
    }


}

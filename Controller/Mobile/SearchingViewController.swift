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
 ViewController of the Mobile Searching for Server Scene
 - Author: Mark Duek
 - Version: 0.1 Plus Ultra
 - Important: Nothing at all
 */


class SearchingViewController: UIViewController {
    var label: UILabel!
    var timer : Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        SocketManager.shared.setUpClient()
        createAll()
        self.view.backgroundColor = .black
        
    }
    //MARK: - Creating Itens

    /**
     Create all elements in the scene
     */
    func createAll(){
        createActivityIndicatory()
        label = UILabel(txt: "Buscando por Servidor", controller: self)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(changeView), userInfo: nil, repeats: true)
    }
    
    /**
     Creates the activity indicator
     */
    func createActivityIndicatory() {
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        actInd.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(actInd)
        actInd.startAnimating()
        actInd.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -60).isActive = true
        actInd.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    //MARK: - Change Scene
    
    @objc func changeView(){
//                self.dismiss(animated: false, completion: nil)
        if SocketManager.shared.isConnected {
            self.present(ActionViewController() as UIViewController, animated: false, completion: nil)

        }
    }
}

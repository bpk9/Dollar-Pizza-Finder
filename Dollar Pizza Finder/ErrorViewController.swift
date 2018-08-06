//
//  ErrorViewController.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 8/6/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit.UIViewController

class ErrorViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
}

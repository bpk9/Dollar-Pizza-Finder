//
//  InfoLauncherView.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/19/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit

class InfoLauncherView: UIView {
    
    // UI elements

    
    // init function
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "InfoLauncherView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    func loadUI(data: MarkerData) {
        
    }
    
}


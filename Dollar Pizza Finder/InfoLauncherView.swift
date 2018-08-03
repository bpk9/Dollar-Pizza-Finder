//
//  InfoLauncherView.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/19/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit

protocol InfoDelegate {
    func runSegue(_ identifier: String)
}

class InfoLauncherView: UIView {
    
    // UI elements
    @IBOutlet var directionsBtn: UIButton!
    @IBOutlet var moreInfoBtn: UIButton!
    
    // instance delegate
    var delegate: InfoDelegate?
    
    // init function
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "InfoLauncherView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    func loadUI(data: MarkerData) {
        
        if let leg = data.routes?.first?.legs.first {
            self.directionsBtn.alpha = 1
            self.directionsBtn.setTitle("Directions - " + data.routes!.first!.legs.first!.duration.text, for: .normal)
        } else {
            self.directionsBtn.alpha = 0.5
            self.directionsBtn.setTitle("Directions not available", for: .normal)
        }
    }
    
    // show directions view when button is tapped
    @IBAction func directionsAction(_ sender: Any) {
        if self.directionsBtn.alpha == 1 {
            delegate?.runSegue("directionsFromHome")
        }
    }
    
    // show more info view when button is tapped
    @IBAction func moreInfoAction(_ sender: Any) {
        delegate?.runSegue("placeInfo")
    }
    
}


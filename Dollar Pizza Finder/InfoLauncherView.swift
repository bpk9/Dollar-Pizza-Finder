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
    
    // instance delegate
    var delegate: InfoDelegate?
    
    // init function
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "InfoLauncherView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    func loadUI(data: MarkerData) {
        self.directionsBtn.setTitle("Directions -- " + data.route!.legs.first!.duration.text, for: .normal)
    }
    
    // show directions view when button is tapped
    @IBAction func directionsAction(_ sender: Any) {
        delegate?.runSegue("directionsFromHome")
    }
    
    // show more info view when button is tapped
    @IBAction func moreInfoAction(_ sender: Any) {
        delegate?.runSegue("placeInfo")
    }
    
}


//
//  DirectionsMarkerView.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/6/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit

class DirectionsMarkerView: UIView {
    
    // UI Elements
    @IBOutlet var title: UILabel!
    
    // init function
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "DirectionsMarkerView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
}

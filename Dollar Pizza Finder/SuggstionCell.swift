//
//  Suggstion.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/19/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit

class SuggestionCell: UIView {
    
    // ui elements
    @IBOutlet var name: UILabel!
    @IBOutlet var rating: UILabel!
    @IBOutlet var distance: UILabel!
    
    // init function
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "SuggestionCell", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    // load ui elements from data
    func loadUI(data: MarkerData) {
        
    }
    
}

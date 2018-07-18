//
//  TableCell.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/17/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit

class TableCell: UITableViewCell {
    
    // ui elements
    @IBOutlet var name: UILabel!
    
    // load ui elements from data
    func loadUI(data: MarkerData) {
        self.name.text = data.place.name
    }
    
}

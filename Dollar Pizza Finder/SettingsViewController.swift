//
//  SettingsViewController.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/23/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    // ui elements
    @IBOutlet var directionsMode: UISegmentedControl!
    @IBOutlet var onlyOpen: UISwitch!
    @IBOutlet var sortBy: UISegmentedControl!
    
    // load ui elements from settings values
    override func loadView() {
        super.loadView()
        
        // load directions mode
        directionsMode.selectedSegmentIndex = UserDefaults.standard.value(forKey: "directionsMode") as! Int
        
    }
    
    // called when directions mode is changed
    @IBAction func directionsModeChanged(_ sender: Any) {
        UserDefaults.standard.set(self.directionsMode.selectedSegmentIndex, forKey: "directionsMode")
    }
    
    // called when only open is changed
    @IBAction func onlyOpenChanged(_ sender: Any) {
    }
    
    // called when sort by is changed
    @IBAction func sortByChanged(_ sender: Any) {
    }
    
}

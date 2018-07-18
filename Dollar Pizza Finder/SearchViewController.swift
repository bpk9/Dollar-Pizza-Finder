//
//  SearchViewController.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/17/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit
import GoogleMaps

class SearchViewController: UITableViewController {
    
    // view components
    @IBOutlet var search: UISearchBar!
    
    // markers on map
    var markers: [GMSMarker]!
    
    // marker selected
    var selectedMarker: GMSMarker?
    
    // init view when appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set selected marker to nil
        self.selectedMarker = nil
    }
    
    // returns number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return markers.count
    }
    
    // returns cell for table view at given index
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create cell and fill with data
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell") as! TableCell
        cell.loadUI(data: markers[indexPath.row].userData as! MarkerData)
        
        return cell
    }
    
    // when cell is tapped by user
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedMarker = self.markers[indexPath.row]
        performSegue(withIdentifier: "unwindHome", sender: self)
    }
    
    // height of cells
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
}

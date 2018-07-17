//
//  SearchViewController.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/17/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit
import GoogleMaps

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // view components
    @IBOutlet var search: UISearchBar!
    @IBOutlet var table: UITableView!
    
    // markers on map
    var markers: [GMSMarker]!
    
    // init view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up table view
        self.table.delegate = self
        self.table.dataSource = self
    }
    
    // returns number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return markers.count
    }
    
    // returns cell for table view at given index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get data from marker at index
        let data = markers[indexPath.row].userData as! MarkerData
        
        // create cell and fill with data
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell") as! TableCell
        cell.name.text = data.place.name
        
        return cell
    }
    
}

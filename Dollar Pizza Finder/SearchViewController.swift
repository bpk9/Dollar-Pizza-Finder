//
//  SearchViewController.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/17/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit
import GoogleMaps

class SearchViewController: UITableViewController, UISearchBarDelegate {
    
    // view components
    @IBOutlet var search: UISearchBar!
    
    // markers on map
    var markers: [GMSMarker]!
    var filtered = [GMSMarker]()
    
    // currently searching
    var isSearching: Bool = false
    
    // marker selected
    var selectedMarker: GMSMarker?
    
    // set up ui elements when view loads
    override func viewDidLoad() {
        self.search.delegate = self
    }
    
    // init view when appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set selected marker to nil
        self.selectedMarker = nil
    }
    
    // returns number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filtered.count
        }
        return markers.count
        
    }
    
    // returns cell for table view at given index
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var places: [GMSMarker]!
        
        if isSearching {
            places = filtered
        } else {
            places = markers
        }
        
        // create cell and fill with data
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell") as! TableCell
        cell.loadUI(data: places[indexPath.row].userData as! MarkerData)
        
        return cell
    }
    
    // when cell is tapped by user
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        var places: [GMSMarker]!
        
        if isSearching {
            places = filtered
        } else {
            places = markers
        }
        
        self.selectedMarker = places[indexPath.row]
        performSegue(withIdentifier: "unwindHome", sender: self)
    }
    
    // height of cells
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.isSearching = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isSearching = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.isSearching = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filtered.removeAll(keepingCapacity: false)
        let predicate = searchBar.text!
        self.filtered = self.markers.filter({ ($0.userData as! MarkerData).place.name.range(of: predicate) != nil })
        self.filtered.sort{ ($0.userData as! MarkerData).place.name < ($1.userData as! MarkerData).place.name }
        self.isSearching = (self.filtered.count == 0) ? false: true
        self.tableView.reloadData()
    }
    
}

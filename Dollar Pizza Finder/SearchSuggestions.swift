//
//  SearchSuggestions.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/19/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit
import GoogleMaps.GMSMarker

protocol SearchDelegate {
    func showBar(_ searchBar: UISearchBar)
    func hideBar()
}

class SearchSuggestions: NSObject, UISearchBarDelegate, SuggestionDelegate {
    
    // application elements
    let window: UIWindow
    var map: GMSMapView
    var userLocation: CLLocation
    
    // ui elements
    var searchBar: UISearchBar = UISearchBar()
    var stack: UIStackView!
    var tint: UIView!
    
    // search delegate
    var delegate: SearchDelegate?
    
    // visibility bool
    var isVisible: Bool
    
    // num of rows in table
    var rows: Int = 3
    
    // marker data
    var markers: [SuggestionCell] = [SuggestionCell]()
    var filtered: [SuggestionCell]!
    
    init(map: GMSMapView, userLocation: CLLocation, markers: [GMSMarker], navBarHeight: CGFloat) {
        // init variables
        self.window = UIApplication.shared.keyWindow!
        self.isVisible = false
        self.map = map
        self.userLocation = userLocation
        super.init()
        
        // set up search bar
        self.searchBar.placeholder = "Search for a place"
        self.searchBar.showsCancelButton = true
        self.searchBar.delegate = self
        
        // height of app header
        let y = UIApplication.shared.statusBarFrame.height + navBarHeight
        
        // set up suggestions view
        self.stack = UIStackView(frame: CGRect(x: 0, y: y, width: self.window.frame.width, height: 0))
        self.stack.axis = .vertical
        self.stack.distribution = .fillProportionally
        self.stack.isUserInteractionEnabled = true
        self.addStackData(markers: markers)
        
        // set up background tint
        self.tint = UIView(frame: CGRect(x: 0, y: y, width: self.window.frame.width, height: self.window.frame.height - y))
        self.tint.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.tint.alpha = 0
        self.tint.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideSearch)))
        
    }
    
    func showSearch() {
        
        // add tint
        self.window.addSubview(self.tint)
        
        // add search bar
        self.delegate!.showBar(self.searchBar)
        self.searchBar.becomeFirstResponder()
        self.searchBar.text = ""
        
        // add suggestions
        self.window.addSubview(self.stack)
        self.filtered = self.markers
        self.refreshStackData()
        
        // animate  tint in
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.tint.alpha = 1
 
        }, completion: { (success) -> Void in
            self.isVisible = true
        })
        
        
    }
    
    // hides search bar elements
    @objc func hideSearch() {
        
        self.removeAllViews()
        
        let oldFrame = self.stack.frame
        
        UIView.animate(withDuration: 0.5, animations: {
            // remove search bar
            self.delegate!.hideBar()
            
            // remove suggestions
            self.stack.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y, width: oldFrame.width, height: 0)
            
            // remove tint
            self.tint.alpha = 0
            
        }, completion: { (success) -> Void in
            self.tint.removeFromSuperview()
            self.stack.removeFromSuperview()
            self.isVisible = false
        })
        
    }
    
    // initializes stack data
    func addStackData(markers: [GMSMarker]) {
        for marker in markers {
            let cell = SuggestionCell.instanceFromNib() as! SuggestionCell
            cell.marker = marker
            cell.delegate = self
            cell.loadUI(currentLocation: self.userLocation)
            self.stack.addArrangedSubview(cell)
            self.markers.append(cell)
        }
    }
    
    // updates stack view for filtered data
    func refreshStackData() {
        
        let onlyOpen = UserDefaults.standard.value(forKey: "onlyOpen") as? Bool ?? true
        
        self.removeAllViews()
        
        // add views from filter
        for cell in self.filtered {
            let data = cell.marker.userData as! MarkerData
            let openNow = data.place.opening_hours?.open_now ?? false
            if !onlyOpen || openNow {
                self.stack.addArrangedSubview(cell)
            }
        }
        
        // update stack frame based on num of elements
        self.updateStackFrame()
        
    }
    
    // clear all markers from stack
    func removeAllViews() {
        for view in self.stack.subviews {
            view.removeFromSuperview()
        }
    }
    
    // TODO updates stack view frame based on visible elemtnts
    func updateStackFrame() {
        let oldFrame = self.stack.frame
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.stack.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y, width: oldFrame.width, height: CGFloat(50 * self.stack.arrangedSubviews.count))
            }, completion: nil)
    }
    
    // called when search bar cancel button is tapped
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.hideSearch()
    }
    
    // called when text in search bar changes
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            self.filtered = self.markers
        } else {
            self.filtered.removeAll(keepingCapacity: false)
            let predicate = searchBar.text!.lowercased()
            self.filtered = self.markers.filter({ ($0.marker.userData as! MarkerData).place.name.lowercased().range(of: predicate) != nil })
            self.filtered.sort{ ($0.marker.userData as! MarkerData).place.name > ($1.marker.userData as! MarkerData).place.name }
        }
        
        self.refreshStackData()
    }
    
    // called when cell is tapped
    func suggestionCell(didTap marker: GMSMarker) {
        self.map.selectedMarker = marker
        self.hideSearch()
        self.map.moveCamera(GMSCameraUpdate.setTarget(self.map.selectedMarker!.position))
    }
    
    // updates cells when sorting changes
    func updateCells(markers: [GMSMarker]) {
        self.markers.removeAll()
        self.addStackData(markers: markers)
    }
    
}

//
//  SearchSuggestions.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/19/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit

protocol SearchDelegate {
    func showBar(_ searchBar: UISearchBar)
    func hideBar()
}

class SearchSuggestions: NSObject, UISearchBarDelegate {
    
    // application elements
    let window: UIWindow
    
    // ui elements
    var searchBar: UISearchBar = UISearchBar()
    var collection: UICollectionView!
    var tint: UIView!
    
    // search delegate
    var delegate: SearchDelegate?
    
    // visibility bool
    var isVisible: Bool
    
    // num of rows in table
    var rows: Int = 3
    
    // marker data
    
    
    init(navBarHeight: CGFloat) {
        // init variables
        self.window = UIApplication.shared.keyWindow!
        self.isVisible = false
        super.init()
        
        // set up search bar
        self.searchBar.placeholder = "Search for a place"
        self.searchBar.showsCancelButton = true
        self.searchBar.delegate = self
        
        // set up background tint
        let y = UIApplication.shared.statusBarFrame.height + navBarHeight
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
        
        // animate tint in
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            /*let oldFrame = self.collection.frame
            self.collection.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y, width: oldFrame.width, height: 150)
            */
            
            self.tint.alpha = 1
 
        }, completion: { (success) -> Void in
            self.isVisible = true
        })
        
        
    }
    
    @objc func hideSearch() {
        
        UIView.animate(withDuration: 0.5, animations: {
            // remove search bar
            self.delegate!.hideBar()
            
            // remove tint
            self.tint.alpha = 0
            
        }, completion: { (success) -> Void in
            self.tint.removeFromSuperview()
            self.isVisible = false
        })
        
    }
    
    // called when search bar cancel button is tapped
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.hideSearch()
    }
    
    /*func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell(
        return UITableViewCell(frame: CGRect(x: 0, y: 0, width: self.table.frame.width, height: 50))
    }*/
    
}

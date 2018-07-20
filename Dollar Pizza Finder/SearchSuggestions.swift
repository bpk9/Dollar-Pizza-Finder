//
//  SearchSuggestions.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/19/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit

class SearchSuggestions: NSObject {
    
    // application window
    let window: UIWindow
    
    // ui elements
    var collection: UICollectionView!
    var tint: UIView!
    
    // num of rows in table
    var rows: Int = 3
    
    // marker data
    
    init(y: CGFloat) {
        self.window = UIApplication.shared.keyWindow!
        super.init()
        
        self.tint = UIView(frame: CGRect(x: 0, y: y, width: self.window.frame.width, height: self.window.frame.height - y))
        self.tint.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.tint.alpha = 0
        
    }
    
    func showSuggestions() {
        
        self.window.addSubview(self.tint)
        //self.window.addSubview(self.collection)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            /*let oldFrame = self.collection.frame
            self.collection.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y, width: oldFrame.width, height: 150)
            */
            
            self.tint.alpha = 1
 
        }, completion: nil)
        
        
    }
    
    /*func hideSuggestions() {
        
        UIView.animate(withDuration: 0.5, animations: {
            let oldFrame = self.table.frame
            self.table.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y, width: oldFrame.width, height: 0)
        }, completion: { (success) -> Void in
            self.table.removeFromSuperview()
        })
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell(
        return UITableViewCell(frame: CGRect(x: 0, y: 0, width: self.table.frame.width, height: 50))
    }*/
    
}

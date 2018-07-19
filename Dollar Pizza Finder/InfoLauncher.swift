//
//  DirectionsLauncher.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/19/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit

class InfoLauncher {
    
    // data from tapped marker
    var data: MarkerData
    
    // window for display
    var window: UIWindow
    
    // view to contain info
    let collectionView: UICollectionView = {
        let layout = UICollectionViewLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
    }()
    
    init(markerData: MarkerData) {
        
        // get window
        self.window = UIApplication.shared.keyWindow!
        
        // init data for view
        self.data = markerData
        
    }
    
    // slide in info menu from bottom of screen
    func showInfo() {
        
        // add subview to window
        window.addSubview(collectionView)
            
        // init frame for subview below visible window
        collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: 100)
            
        // animate subview into view from below
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.collectionView.frame = CGRect(x: 0, y: self.window.frame.height - 100, width: self.window.frame.width, height: 100)
            
        }, completion: nil)
        
    }
    
    // slide info out to bottomof screen
    func hideInfo() {
        
        UIView.animate(withDuration: 0.5, animations: {
            // animare out of screen
            self.collectionView.frame = CGRect(x: 0, y: self.window.frame.height, width: self.window.frame.width, height: 100)
        
        }, completion: { (success) -> Void in
            // remove from view when completed
            self.collectionView.removeFromSuperview()
        })
        
    }
}

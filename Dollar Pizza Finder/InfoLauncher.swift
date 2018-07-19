//
//  DirectionsLauncher.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/19/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit

class InfoLauncher: NSObject {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
    }()
    
    override init() {
        super.init()
        
        
    }
    
    // slide in info menu from bottom of screen
    func showInfo() {
        if let window = UIApplication.shared.keyWindow {
            
            // add subview to window
            window.addSubview(collectionView)
            
            // init frame for subview below visible window
            collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: 100)
            
            // animate subview into view from below
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { self.collectionView.frame = CGRect(x: 0, y: window.frame.height - 100, width: window.frame.width, height: 100) }, completion: nil)
            
        }
    }
    
}

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
            
            window.addSubview(collectionView)
            
            let height: CGFloat = 100
            let y = window.frame.height - height
            collectionView.frame = CGRect(x: 0, y: y, width: window.frame.width, height: height)
            
        }
    }
    
}

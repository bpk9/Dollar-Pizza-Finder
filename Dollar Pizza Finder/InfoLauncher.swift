//
//  DirectionsLauncher.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/19/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit

class InfoLauncher {
    
    // window for display
    var window: UIWindow
    
    // map on home screen
    var map: UIView!
    
    // view to contain info
    let infoView: UIView = InfoLauncherView.instanceFromNib()
    
    init(map: UIView) {
        
        // get window
        self.window = UIApplication.shared.keyWindow!
        
        // get map
        self.map = map
    }
    
    // slide in info menu from bottom of screen
    func showInfo() {
        
        // add subview to window
        window.addSubview(self.infoView)
            
        // init frame for subview below visible window
        self.infoView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: 100)
            
        // animate subview into view from below
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            // move map up
            let oldFrame = self.map.frame
            self.map.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y, width: oldFrame.width, height: oldFrame.height - 70)
            
            // bring frame in
            self.infoView.frame = CGRect(x: 0, y: self.window.frame.height - 70, width: self.window.frame.width, height: 70)
            
        }, completion: nil)
        
    }
    
    // slide info out to bottom of screen
    func hideInfo() {
        
        UIView.animate(withDuration: 0.5, animations: {
            // animate info out of screen
            self.infoView.frame = CGRect(x: 0, y: self.window.frame.height, width: self.window.frame.width, height: 70)
            
            // move map down
            let oldFrame = self.map.frame
            self.map.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y, width: oldFrame.width, height: oldFrame.height + 70)
        
        }, completion: { (success) -> Void in
            // remove from view when completed
            self.infoView.removeFromSuperview()
        })
        
    }
}

//
//  DirectionsLauncher.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/19/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit
import GoogleMaps.GMSMapView

class InfoLauncher {
    
    // window for display
    var window: UIWindow
    
    // map on home screen
    var map: GMSMapView!
    
    // check if launcher is visible
    var isVisible: Bool = false
    
    // view to contain info
    let infoView: InfoLauncherView = InfoLauncherView.instanceFromNib() as! InfoLauncherView
    
    // directions mode
    var directionsMode: String = "transit"
    
    init(map: GMSMapView) {
        
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
            let oldFrame = self.map.superview!.frame
            self.map.superview!.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y, width: oldFrame.width, height: oldFrame.height - 70)
            
            // bring frame in
            self.infoView.frame = CGRect(x: 0, y: self.window.frame.height - 70, width: self.window.frame.width, height: 70)
            
        }, completion: { (success) -> Void in
            self.isVisible = true
        })
        
    }
    
    // slide info out to bottom of screen
    func hideInfo() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            // animate info out of screen
            self.infoView.frame = CGRect(x: 0, y: self.window.frame.height, width: self.window.frame.width, height: 70)
            
            // move map down
            let oldFrame = self.map.superview!.frame
            self.map.superview!.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y, width: oldFrame.width, height: oldFrame.height + 70)
        
        }, completion: { (success) -> Void in
            // remove from view when completed
            self.infoView.removeFromSuperview()
            self.isVisible = false
        })
        
    }
    
    // update info on info marker
    func updateInfo() {
        
        // load settings
        self.loadSettings()
        
        // get data from marker
        var data = self.map.selectedMarker!.userData as! MarkerData
        
        if data.route != nil {
            self.infoView.loadUI(data: data)
        } else {
            let directions = GoogleDirections(origin: self.map.myLocation!.coordinate, destination: data.place.place_id, mode: self.directionsMode)
            directions.getDirections() { (route) -> () in
                data.route = route
                self.map.selectedMarker!.userData = data
                self.infoView.loadUI(data: data)
            }
        }
    }
    
    // load app settings
    func loadSettings() {
        if let value = UserDefaults.standard.value(forKey: "directionsMode") as? Int {
            print("Found value: " + String(value))
            self.directionsMode = self.getDirectionsMode(index: value)
        } else {
            UserDefaults.standard.set(1, forKey: "directionsMode")
            self.directionsMode = "transit"
        }
        
    }
    
    // return directions mode from settings index
    func getDirectionsMode(index: Int) -> String {
        switch index {
        case 0: return "driving"
        case 1: return "transit"
        case 2: return "walking"
        case 3: return "biking"
        default: return "transit"
        }
    }
    
}

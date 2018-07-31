//
//  PlaceInfoViewController.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/18/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit
import CoreLocation.CLLocation
import GooglePlaces.GMSPlacePhotoMetadataList

class PlaceInfoViewController: UIViewController {
    
    // ui elements
    @IBOutlet var directionsBtn: UIButton!
    @IBOutlet var navItem: UINavigationItem!
    @IBOutlet var photosView: UIScrollView!
    
    // last known location of user
    var currentLocation: CLLocationCoordinate2D!
    
    // marker data
    var data: MarkerData!
    
    // load data for place when view appears
    override func viewWillAppear(_ animated: Bool) {
        
        // set title to name of place
        self.navItem.title = self.data.place.name
        
        // add photos to scroll view
        let photodata = self.data.photo.data
        self.addPhotos(metadata: photodata)
        self.photosView.contentSize = CGSize(width: photodata.results.count * 150, height: 150)
        
        // update button text if route exists
        if let leg = self.data.routes?.first?.legs.first {
            self.directionsBtn.setTitle("Directions -- " + leg.duration.text, for: .normal)
        } else {
            self.directionsBtn.isHidden = true
        }
        
    }
    
    // prepare data for new storyboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if let vc = segue.destination as? DirectionsViewController {
            vc.data = self.data
        }
    
    }
    
    // add photos to scroll view
    func addPhotos(metadata: GMSPlacePhotoMetadataList) {
        let results = metadata.results
        for i in 0..<results.count {
            let imageView = UIImageView(frame: CGRect(x: CGFloat(i * 150), y: 10, width: 150, height: 150))
            GooglePlaces.loadImageForMetadata(photoMetadata: results[i]) { (photo) -> () in
                imageView.image = photo
            }
            self.photosView.addSubview(imageView)
        }
    }
    
}

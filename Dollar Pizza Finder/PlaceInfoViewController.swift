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

class PlaceInfoViewController: UIViewController, UITableViewDataSource {
    
    // ui elements
    @IBOutlet var directionsBtn: UIButton!
    @IBOutlet var navItem: UINavigationItem!
    @IBOutlet var photosView: UIScrollView!
    @IBOutlet var reviewsTable: UITableView!
    @IBOutlet var distance: UILabel!
    @IBOutlet var rating: UILabel!
    @IBOutlet var call: UIButton!
    @IBOutlet var website: UIButton!
    
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
        
        // set up reviews table
        self.reviewsTable.dataSource = self
        self.reviewsTable.reloadData()
        
        // set up distance label
        self.distance.text = self.data.routes?.first?.legs.first?.distance.text
        
        // set up overall rating
        self.rating.text = GooglePlaces.starString(rating: self.data.place.rating)
        
        // hide call button if phone number is not listed
        if self.data.place.formatted_phone_number == nil {
            self.call.isHidden = true
        }
        
        // hide website button if website is not listed
        if self.data.place.website == nil {
            self.website.isHidden = true
        }
        
        // update button text if route exists
        if let leg = self.data.routes?.first?.legs.first {
            self.directionsBtn.alpha = 1
            self.directionsBtn.setTitle("Directions -- " + leg.duration.text, for: .normal)
        } else {
            self.directionsBtn.alpha = 0.5
            self.directionsBtn.setTitle("Directions not available", for: .normal)
        }
        
    }
    
    // prepare data for new storyboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if let vc = segue.destination as? DirectionsViewController {
            vc.data = self.data
        }
    
    }
    
    // title for section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Reviews"
    }
    
    // number of rows in table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.place.reviews.count
    }
    
    // height of each cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    // create cell for each review
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell") as! ReviewCell
        let review = self.data.place.reviews[indexPath.row]
        cell.loadUI(review: review)
        return cell
    }
    
    // call place
    @IBAction func callPlace(_ sender: Any) {
        if let phoneNumber = self.data.place.formatted_phone_number {
            if let url = URL(string: "tel://\(self.getRawNum(input: phoneNumber))") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    // open website
    @IBAction func visitWebsite(_ sender: Any) {
        if let website = self.data.place.website {
            if let url = URL(string: website) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    // show directions if available
    @IBAction func directionsAction(_ sender: Any) {
        if self.data.routes?.first != nil {
            performSegue(withIdentifier: "moreInfoDirections", sender: nil)
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
    
    // only retrive digits from phone number
    func getRawNum(input: String) -> String {
        var output = ""
        for character in input {
            let char = String(character)
            if Int(char) != nil {
                output += char
            }
        }
        return output
    }
    
}

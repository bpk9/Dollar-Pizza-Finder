//
//  ReviewCell.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/31/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit.UITableViewCell

class ReviewCell: UITableViewCell {
    
    // ui elements
    @IBOutlet var name: UILabel!
    @IBOutlet var rating: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var photo: UIImageView!
    @IBOutlet var review: UILabel!
    
    // load ui from review data
    func loadUI(review: Review) {
        
        self.name.text = review.author_name
        
        self.rating.text = GooglePlaces.starString(rating: review.rating)
        
        self.time.text = review.relative_time_description
        
        self.setImage(url: URL(string: review.profile_photo_url)!)
        
        self.review.text = review.text
    }
    
    // get image from url
    func setImage(url: URL) {
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url)
            DispatchQueue.main.async {
                let image = UIImage(data: data!)
                self.photo.image = image
            }
        }
    }
    
}

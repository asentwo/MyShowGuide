//
//  MainShowCell.swift
//  GuideBoxGuideNew1.0
//
//  Created by Justin Doo on 10/14/15.
//  Copyright © 2015 Justin Doo. All rights reserved.
//

import UIKit




class TvShowInfo: NSObject, NSCoding {

  var poster: String
  var title: String
  var id: NSNumber
  
 init(poster: String, title: String, id: NSNumber) {

    self.poster = poster
    self.title = title
    self.id = id

  }
  
  // MARK: - comply wiht NSCoding protocol
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(poster, forKey: "poster")
    aCoder.encodeObject(title, forKey: "title")
    aCoder.encodeObject(id, forKey: "id")
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    
    // decoding could fail, for example when no Blog was saved before calling decode
    guard let unarchivedPoster = aDecoder.decodeObjectForKey("poster") as? String,
          let unarchivedTitle =  aDecoder.decodeObjectForKey("title") as? String,
          let unarchivedId = aDecoder.decodeObjectForKey("id") as? NSNumber
     
    else {
        // option 1 : return an default Blog
      self.init(poster: "unkown", title:"unkown", id: 0)
      return
        
        // option 2 : return nil, and handle the error at higher level
    }
  
    // convenience init must call the designated init
    self.init(poster: unarchivedPoster, title: unarchivedTitle, id: unarchivedId)
  }
  
}






class TvShowCell: UITableViewCell {
  
  @IBOutlet var MainPosterImage: UIImageView!
  @IBOutlet var MainTitleLabel: UILabel!
  @IBOutlet var imageWrapper: UIView!
  @IBOutlet weak var saveButton: UIButton!
  
  }


//
//  MainShowCell.swift
//  GuideBoxGuideNew1.0
//
//  Created by Justin Doo on 10/14/15.
//  Copyright © 2015 Justin Doo. All rights reserved.
//

import UIKit




class TvShowInfo: NSObject {

  var poster: String
  var title: String
  var id: NSNumber
  var objectID: String?
  
  init(poster: String, title: String, id: NSNumber) {

    self.poster = poster
    self.title = title
    self.id = id
  }
  
  init(poster: String, title: String, id: NSNumber, objectID: String) {
    
    self.poster = poster
    self.title = title
    self.id = id
    self.objectID = objectID
  }
  
}


class TvShowCell: UITableViewCell {
  
  @IBOutlet var MainPosterImage: UIImageView!
  @IBOutlet var MainTitleLabel: UILabel!
  @IBOutlet var imageWrapper: UIView!
  @IBOutlet weak var saveButton: UIButton!

  }



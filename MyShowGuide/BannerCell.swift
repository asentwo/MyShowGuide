//
//  bannerCell.swift
//  GuideBoxGuideNew1.0
//
//  Created by Justin Doo on 10/19/15.
//  Copyright © 2015 Justin Doo. All rights reserved.
//

import UIKit


class BannerCell: UITableViewCell {

  @IBOutlet var bannerImage: UIImageView!
  
  override func awakeFromNib() {
  
      bannerImage.alpha = 0.0
    UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseIn], animations: {
      self.bannerImage.alpha = 1.0
      }, completion: nil)    }
  }
  
  
  

//
//  photosCollection.swift
//  GuideBoxGuideNew1.0
//
//  Created by Justin Doo on 10/23/15.
//  Copyright © 2015 Justin Doo. All rights reserved.
//

import UIKit


class photosCollectionCell: UICollectionViewCell {
  
  @IBOutlet var photoImage: UIImageView!

  override func awakeFromNib() {
    
  photoImage.alpha = 0.0
    UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseIn], animations: {
      self.photoImage.alpha = 1.0
      }, completion: nil)  }
}

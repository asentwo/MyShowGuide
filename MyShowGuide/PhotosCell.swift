//
//  photosCell2.swift
//  GuideBoxGuideNew1.0
//
//  Created by Justin Doo on 10/23/15.
//  Copyright © 2015 Justin Doo. All rights reserved.
//

import UIKit
import SDWebImage

class PhotosCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
  
  @IBOutlet var collectionView: UICollectionView!

  var photosArray = [String]()
  
  override func awakeFromNib() {
    collectionView.delegate = self
    collectionView.dataSource = self
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return photosArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosCollectionCell", for: indexPath) as! photosCollectionCell
    
    let photo = photosArray[indexPath.row]
    cell.photoImage.sd_setImage(with: URL(string: photo))
    
    return cell
  }
}














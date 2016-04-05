//
//  photosCell2.swift
//  GuideBoxGuideNew1.0
//
//  Created by Justin Doo on 10/23/15.
//  Copyright © 2015 Justin Doo. All rights reserved.
//

import UIKit

class PhotosCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
  
  @IBOutlet var collectionView: UICollectionView!

  var photosArray = [String]()
  
  override func awakeFromNib() {
    collectionView.delegate = self
    collectionView.dataSource = self
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return photosArray.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photosCollectionCell", forIndexPath: indexPath) as! photosCollectionCell
    
    let photo = photosArray[indexPath.row]
    cell.photoImage.sd_setImageWithURL(NSURL(string: photo))
    
    return cell
  }
}














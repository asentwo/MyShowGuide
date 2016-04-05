//
//  TestTableCell.swift
//  GuideBoxGuideNew1.0
//
//  Created by Justin Doo on 10/23/15.
//  Copyright © 2015 Justin Doo. All rights reserved.
//

import UIKit

class TestTableCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
  

  @IBOutlet var collectionView: UICollectionView!

  

  
  var castArray = [DetailShowInfo](){
    didSet {
      // whenever the imageArray changes, reload the imagesList
      if let collectionView = collectionView {
        collectionView.reloadData()
      }
    }
  }
  var photosArray = [Photos]()/*{
    didSet {
      // whenever the imageArray changes, reload the imagesList
      if let collectionView = collectionView {
        collectionView.reloadData()
      }
    }
  }*/

  

  
   //  var testURL = "http://api-public.guidebox.com/v1.43/us/rKk09BXyG0kXF1lnde9GOltFq6FfvNQd/show/621"
  
  
 override func awakeFromNib() {

  collectionView.delegate = self
  collectionView.dataSource = self
 // collectionView.reloadData()
  
  
  }
  
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    
   print(photosArray.count)
    
  
    
   return photosArray.count
    
    
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("testCollectionCell", forIndexPath: indexPath) as! TestCollectionCell

    
   //cell.testImage.image = UIImage(named: "shep eazy")
    
    
 cell.testImage.sd_setImageWithURL(NSURL(string: photosArray[0].fanart))
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let itemsPerRow:CGFloat = 4
    let hardCodedPadding:CGFloat = 5
    let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding
    let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
    return CGSize(width: itemWidth, height: itemHeight)
  }

}

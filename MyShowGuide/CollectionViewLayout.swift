////
////  CollectionViewLayout.swift
////  GuideBoxGuide3.0
////
////  Created by Justin Doo on 3/6/16.
////  Copyright © 2016 Justin Doo. All rights reserved.
////
//
import Foundation
import UIKit


extension ChannelViewController: UICollectionViewDelegateFlowLayout {

  
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
   
    let width =  UIScreen.mainScreen().bounds.width/2
    
    
    let size = CGSize(width: width, height: 100)
    return size
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
    let spacing = CGFloat(0)
    return spacing
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    let spacing = CGFloat(0)
    return spacing
  }
  
}
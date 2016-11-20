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
  
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let width =  UIScreen.main.bounds.width/2
    
    if UIDevice.current.userInterfaceIdiom == .pad {
      let size = CGSize(width: width, height: 200)
      return size
    } else {
      let size = CGSize(width: width, height: 100)
      return size
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    let spacing = CGFloat(0)
    return spacing
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    let spacing = CGFloat(0)
    return spacing
  }
  
}

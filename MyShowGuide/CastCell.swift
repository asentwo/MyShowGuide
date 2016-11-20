//
//  CastCell2.swift
//  GuideBoxGuideNew1.0
//
//  Created by Justin Doo on 10/23/15.
//  Copyright © 2015 Justin Doo. All rights reserved.
//

import UIKit


class CastCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
  
  @IBOutlet var collectionView: UICollectionView!

  var castArray = [CastInfo]()
  
  override func awakeFromNib() {
    
    collectionView.delegate = self
    collectionView.dataSource = self    
         }
  
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
  
  return castArray.count
  }
  
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "castCollectionCell", for: indexPath) as! castCollectionCell
    let cast = castArray[indexPath.row]
    
    if cast.name != "" {
    
      cell.nameLabel.text = cast.name } else {
      cast.name = "N/A"
    }
    
    if cast.characterName != "" {
    
      cell.characterNameLabel.text = cast.characterName
    } else {
      cast.characterName = "N/A"
    }
    return cell
  }
}










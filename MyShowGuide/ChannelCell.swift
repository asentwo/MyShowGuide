//
//  ChannelCell.swift
//  GuideBoxGuide2.0
//
//  Created by Justin Doo on 2/9/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

import UIKit


class ChannelInfo: NSObject {
  
  var logo: String
  var channelName: String
  var id: NSNumber 
  
  init(logo: String, channelName: String , id: NSNumber) {
    
    self.logo = logo
    self.channelName = channelName
    self.id = id
  }
}


class ChannelCell : UICollectionViewCell {
  
  @IBOutlet var channelImageView: UIImageView!
  
}
//
//  VideoCell.swift
//  MyShowGuide
//
//  Created by Justin Doo on 4/12/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {
  
  
  @IBOutlet weak var videoWebView: UIWebView!
  @IBOutlet weak var videoInfoLabel: UILabel!
  
  
}

class VideoInfo {
  
  var videoView: String?
  var videoViewInfo: String?
  }
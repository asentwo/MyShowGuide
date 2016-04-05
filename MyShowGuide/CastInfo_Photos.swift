//
//  castInfo.swift
//  GuideBoxGuideNew1.0
//
//  Created by Justin Doo on 10/19/15.
//  Copyright © 2015 Justin Doo. All rights reserved.
//

import Foundation
import UIKit


class CastInfo {
  
  var name: String
  var characterName: String
  
  init(name: String, characterName: String) {
    
    self.name = name
    self.characterName = characterName
  }
}


class Photos {
  
  var poster: String
  var artwork: String
  var fanart: String
  
  init(poster: String, artwork: String, fanart: String) {
    
    self.poster = poster
    self.artwork = artwork
    self.fanart = fanart
  }
}


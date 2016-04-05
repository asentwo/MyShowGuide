//
//  TVInfo.swift
//  MrRobotGuide
//
//  Created by Justin Doo on 9/29/15.
//  Copyright © 2015 Justin Doo. All rights reserved.
//

import Foundation

class DetailShowInfo {
  
  var banner : String
  var overview : String
  var firstAired : String
  var network : String
  var rating : String

  
  init (banner: String, overview: String,firstAired: String, network: String,rating: String)
  {
    self.banner = banner
    self.overview = overview
    self.firstAired = firstAired
    self.network = network
    self.rating = rating
  }
}


class JustDetailsShowInfo {
  
  var firstAired : String
  var network : String
  var rating : String

  
  init (firstAired: String, network: String, rating: String) {
    
    self.firstAired = firstAired
    self.network = network
    self.rating = rating
  }
}


class ArtInfo {
  
  var poster: String?
  var artwork: String?
  var fanart: String?
  
  init (poster: String?, artwork: String?, fanart: String?){
    self.poster = poster
    self.artwork = artwork
    self.fanart = fanart
  }
}


class SocialInfo {
  
  var facebook: String?
  var twitter: String?
  
  init(facebook: String?, twitter: String?){
    
    self.facebook = facebook
    self.twitter = twitter
  }
}


class ExploreInfo {
  var metacritic: String?
  var imdbID: String?
    var wiki: NSNumber?
    var id: NSNumber?
  
  init(metacritic: String?,imdbID: String?, wiki: NSNumber?, id: NSNumber?){
    self.metacritic = metacritic
    self.imdbID = imdbID
    self.wiki = wiki
    self.id = id
  }
}




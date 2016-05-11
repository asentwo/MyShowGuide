//
//  GlobalFunctions.swift
//  GuideBoxGuide3.0
//
//  Created by Justin Doo on 2/18/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

import Foundation

//MARK: Constants

//var userLoggedIn = false
var savedFavoriteArray:[TvShowInfo] = []

//MARK: Delay

func delay(delay:Double, closure:()->()) {
  dispatch_after(
    dispatch_time(
      DISPATCH_TIME_NOW,
      Int64(delay * Double(NSEC_PER_SEC))
    ),
    dispatch_get_main_queue(), closure)
}


//MARK: Null to Nil

func nullToNil(value : AnyObject?) -> AnyObject? {
  if value is NSNull {
    return nil
  } else {
    return value
  }
}


//MARK: Cancel Spinner

func CancelSpinner() {
  delay(4, closure: {
    SwiftSpinner.show("Sorry..There has been an error.")
    delay(2, closure: {
      SwiftSpinner.hide()})
  })

}
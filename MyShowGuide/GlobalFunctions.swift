//
//  GlobalFunctions.swift
//  GuideBoxGuide3.0
//
//  Created by Justin Doo on 2/18/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

import Foundation

//MARK: Constants

let customColor = UIColor.black
let myShowGuideLogo = UIImage(named: "80x80clear")
var savedFavoriteArray:[TvShowInfo] = []

//MARK: Delay

func delay(_ delay:Double, closure:@escaping ()->()) {
  DispatchQueue.main.asyncAfter(
    deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}


//MARK: Null to Nil

func nullToNil(_ value : AnyObject?) -> AnyObject? {
  if value is NSNull {
    return nil
  } else {
    return value
  }
}


//MARK: Cancel Spinner

func CancelSpinner() {
  delay(4, closure: {
    _ = SwiftSpinner.show("Sorry..There has been an error.")
    delay(2, closure: {
      SwiftSpinner.hide()})
  })

}

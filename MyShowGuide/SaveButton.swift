//
//  SaveButton.swift
//  MyShowGuide
//
//  Created by Justin Doo on 4/17/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

import Foundation
import UIKit

class SaveButton: UIButton {
  
  // Images
  let buttonChecked = UIImage(named: "save_icon_greenCheck")
  let buttonUnChecked = UIImage(named: "save_icon_white")
  
  
  //Bool Property
  override var selected: Bool{
    didSet{
      if selected {
        self.setImage(buttonChecked, forState: UIControlState.Normal)
      }else{
        self.setImage(buttonUnChecked, forState: UIControlState.Normal)
      }
      //NSUserDefaults.standardUserDefaults().setObject(selected, forKey: "isBtnChecked")
     // NSUserDefaults.standardUserDefaults().synchronize()
    }
  }
  
  override init(frame: CGRect){
    super.init(frame:frame)
    self.layer.masksToBounds = true
    self.setImage(buttonUnChecked, forState: UIControlState.Normal)
    
    self.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
  }
  
  func buttonClicked(sender: UIButton) {
    self.selected = !self.selected
  }
}
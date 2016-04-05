//
//  HomeViewController.swift
//  GuideBoxGuide2.0
//
//  Created by Justin Doo on 2/9/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
  

  //MARK: ViewDidLoad
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.blackColor()
    self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
  }
  
  //MARK: Segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "homeToChannelSegue" {
      let channelVC = segue.destinationViewController as! ChannelTableViewController
      
      switch sender!.tag {
        
      case 1: channelVC.channel = "all"
      case 2: channelVC.channel = "online"
      case 3: channelVC.channel = "television"
      default: ""
      }
    }
  }
  
  //MARK: IBActions
  
  @IBAction func allButtonPressed(sender: UIButton!) {
    self.performSegueWithIdentifier("homeToChannelSegue", sender: sender)
  }
  
  @IBAction func onlineButtonPressed(sender: UIButton!) {
    self.performSegueWithIdentifier("homeToChannelSegue", sender: sender)
  }
  
  @IBAction func tvButtonPressed(sender: UIButton!) {
    self.performSegueWithIdentifier("homeToChannelSegue", sender: sender)
  }
}

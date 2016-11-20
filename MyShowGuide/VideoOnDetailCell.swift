//
//  VideoOnDetailCell.swift
//  MyShowGuide
//
//  Created by Justin Doo on 4/12/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

import Foundation
import UIKit

class VideoOnDetailCell: UITableViewCell, UIWebViewDelegate {
  
  @IBOutlet weak var videoDetailWebView: UIWebView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  
  func webViewDidStartLoad(_ webView: UIWebView) {
    activityIndicator.isHidden = false
    activityIndicator.startAnimating()
  }
  func webViewDidFinishLoad(_ webView: UIWebView){
    activityIndicator.isHidden = true
    activityIndicator.stopAnimating()
  }
}

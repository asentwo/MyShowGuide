//
//  videoViewController.swift
//  MyShowGuide
//
//  Created by Justin Doo on 4/12/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

// KRH2

import UIKit

class VideoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  //MARK: Constants
  var task : NSURLSessionTask?
 // var videoURL: String?
  var videoArray:[String]?
  var videoInfoArray:[String]?
  var spinnerActive = false
  var showToVideo: NSNumber = 0
  let apiKey = "rKk09BXyG0kXF1lnde9GOltFq6FfvNQd"
  @IBOutlet weak var videoTableView: UITableView!
  

  //MARK: ViewDidLoad
  override func viewDidLoad() {
    let videoURL = "https://api-public.guidebox.com/v1.43/US/7TLlNLmsiWjDDfX8mijsIywdsnrZAH/show/617/clips/all/0/25/all/all/true"
      
      //"https://api-public.guidebox.com/v1.43/US/\(apiKey)/show/\(showToVideo)/clips/all/0/25/all/all/true"
    print("\(videoURL)")
    getJSON(videoURL)
  }
  
  //MARK: JSON
  
  func getJSON (urlString: String) {
    
    let url = NSURL(string: urlString)!
    let session = NSURLSession.sharedSession()
    task = session.dataTaskWithURL(url) {(data, response, error) in
      dispatch_async(dispatch_get_main_queue()) {
        if (error == nil) {
          self.updateDetailShowInfo(data!)
        } else {
          SwiftSpinner.hide()
          self.spinnerActive = false
          self.showNetworkError()
        }
      }
    }
    task!.resume()
  }
  
  
  func updateDetailShowInfo (data: NSData!) {
    do {

      let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
      
      if let results = jsonResult["results"] as? [[String:AnyObject]] where !results.isEmpty {
        
        videoArray = []
        
        for result in results {
          if let freeIOSServices = result["free_ios_sources"] as? [[String:AnyObject]] where !results.isEmpty {
                      let free = freeIOSServices[0]
                      let videoView = free["embed"] as? String
                      print("\(videoView!)")
                      videoArray?.append(videoView!)
            print("\(videoArray!.count)")
          }
        }
        
//        let result = results[0]
        
        
//        if let freeIOSServices = result["free_ios_sources"] as? [[String:AnyObject]] where !results.isEmpty {
//          let free = freeIOSServices[0]
//          let videoView = free["embed"] as? String
//          print("\(videoView!)")
//          videoArray?.append(videoView!)
// 
//    }
    }
      
    } catch {
      showNetworkError()
    }
    self.videoTableView.reloadData()
  }

  //MARK: TableView
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return videoArray!.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("videoCell") as! VideoCell
    SwiftSpinner.hide()
    spinnerActive = false
    let localVideoURL = videoArray![indexPath.row]
    cell.videoInfoLabel.text = videoInfoArray![indexPath.row]
    
    cell.videoWebView.loadHTMLString("<iframe width=\"560\" height=\"315\" src=\"\(localVideoURL)\" frameborder=\"0\" allowfullscreen></iframe>", baseURL: nil)
    return cell
  }
  //MARK: Network Error Indicator
  
  func showNetworkError () {
    let alert = UIAlertController(title: "Whoops?", message: "There was a connection error. Please try again.", preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Default, handler: {_ in self.navigationController?.popViewControllerAnimated(true)})
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
    
  }
}
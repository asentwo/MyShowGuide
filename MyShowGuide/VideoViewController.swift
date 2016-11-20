//
//  videoViewController.swift
//  MyShowGuide
//
//  Created by Justin Doo on 4/12/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  //MARK: Constants
  var task : URLSessionTask?
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
  
  func getJSON (_ urlString: String) {
    
    let url = URL(string: urlString)!
    let session = URLSession.shared
    task = session.dataTask(with: url, completionHandler: {(data, response, error) in
      DispatchQueue.main.async {
        if (error == nil) {
          self.updateDetailShowInfo(data!)
        } else {
          SwiftSpinner.hide()
          self.spinnerActive = false
          self.showNetworkError()
        }
      }
    }) 
    task!.resume()
  }
  
  
  func updateDetailShowInfo (_ data: Data!) {
    do {

      let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
      
      if let results = jsonResult["results"] as? [[String:AnyObject]], !results.isEmpty {
        
        videoArray = []
        
        for result in results {
          if let freeIOSServices = result["free_ios_sources"] as? [[String:AnyObject]], !results.isEmpty {
                      let free = freeIOSServices[0]
                      let videoView = free["embed"] as? String
                      print("\(videoView!)")
                      videoArray?.append(videoView!)
            print("\(videoArray!.count)")
          }
        }
    }
      
    } catch {
      showNetworkError()
    }
    self.videoTableView.reloadData()
  }

  //MARK: TableView
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return videoArray!.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell") as! VideoCell
    SwiftSpinner.hide()
    spinnerActive = false
    let localVideoURL = videoArray![indexPath.row]
    cell.videoInfoLabel.text = videoInfoArray![indexPath.row]
    
    cell.videoWebView.loadHTMLString("<iframe width=\"560\" height=\"315\" src=\"\(localVideoURL)\" frameborder=\"0\" allowfullscreen></iframe>", baseURL: nil)
    return cell
  }
  //MARK: Network Error Indicator
  
  func showNetworkError () {
    let alert = UIAlertController(title: NSLocalizedString("Whoops?", comment: ""), message: NSLocalizedString("There was a connection error. Please try again.", comment: ""), preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: {_ in self.navigationController?.popViewController(animated: true)})
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
    
  }
}

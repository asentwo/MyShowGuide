//
//  DetailTvTableViewController.swift
//  GuideBoxGuideNew1.0
//
//  Created by Justin Doo on 10/16/15.
//  Copyright © 2015 Justin Doo. All rights reserved.
//


import UIKit


class DetailTvTableViewController: UITableViewController, UITextViewDelegate {
  
  //MARK: Constants/ IBOutlets
  
  var postersShown = [Bool](count: 8, repeatedValue: false)
  var task : NSURLSessionTask?
  
  var newURL : String?
  var detailToWebsite: String?
  var spinnerActive = false
  var showToDetailSite: NSNumber = 0
  let apiKey = "rKk09BXyG0kXF1lnde9GOltFq6FfvNQd"
  var totalResultsArray: [AnyObject] = []
  
  @IBOutlet var DetailTvTableView: UITableView!
  
  //MARK: Arrays - different array for each cell so the numberOfRowsInSection.count is correct
  
  var bannerArray: [String] = []
  var overViewArray: [String] = []
  var detailsArray: [JustDetailsShowInfo] = []
  var photosArray: [String] = []
  var socialArray: [SocialInfo] = []
  var exploreArray: [ExploreInfo] = []
  var castLocalArray: [CastInfo] = []
  var genre: String?
  var videoURL: [String] = []
  var videoCell: VideoOnDetailCell!
  
  //MARK: ViewDidLoad
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    SwiftSpinner.show(NSLocalizedString("Retrieving your show info...", comment: ""))
    spinnerActive = true
    self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    let newURL = "http://api-public.guidebox.com/v1.43/us/\(apiKey)/show/\(showToDetailSite)"
    getJSON(newURL)
    print ("XXXXXXXX\(newURL)")
    let videoURL = "https://api-public.guidebox.com/v1.43/US/\(self.apiKey)/show/\(self.showToDetailSite)/clips/all/0/25/all/all/true"
    self.getVideoJSON(videoURL)
  }
  
  //MARK: JSON
  
  func getJSON (urlString: String) {
    
    let url = NSURL(string: urlString)!
    let urlConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
    urlConfig.timeoutIntervalForRequest = 8
    urlConfig.timeoutIntervalForResource = 8
    let session = NSURLSession(configuration: urlConfig)
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
      
      let banner = jsonResult["banner"] as? String ?? ""
      let overview = jsonResult["overview"] as? String ?? "N/A"
      let firstAired = jsonResult["first_aired"] as? String ?? "N/A"
      let network = jsonResult["network"] as? String ?? "N/A"
      let rating = jsonResult["rating"] as? String ?? "N/A"
      
      let showInfo = JustDetailsShowInfo(firstAired: firstAired, network: network, rating: rating)
      detailsArray.append(showInfo)
      bannerArray.append(banner)
      overViewArray.append(overview)
      totalResultsArray.append(detailsArray)
      totalResultsArray.append(bannerArray)
      totalResultsArray.append(overViewArray)
    
      if let castArray = jsonResult["cast"] as? [NSDictionary] {
        for castItem in castArray {
          let name = castItem["name"] as? String ?? "N/A"
          let characterName = castItem["character_name"] as? String ?? "N/A"
          let castInfo = CastInfo(name: name, characterName: characterName)
          castLocalArray.append(castInfo)
        }
      }
      totalResultsArray.append(castLocalArray)
      
      let poster = jsonResult["poster"] as? String ?? "N/A"
      let artwork = jsonResult["artwork_608x342"] as? String ?? "N/A"
      let fanart = jsonResult["fanart"] as? String ?? "N/A"
      
      photosArray.append(poster)
      photosArray.append(fanart)
      photosArray.append(artwork)
      totalResultsArray.append(photosArray)
      
      if let channels = jsonResult["channels"] as? [[String:AnyObject]] where !channels.isEmpty {
        let channel = channels[0] // now the compiler knows it's [String:AnyObject]
        let social = channel["social"] as? NSDictionary
        let facebookDict = social!["facebook"] as? NSDictionary
        let facebook = nullToNil(facebookDict!["link"]) as? String ?? "N/A"
        let twitterDict = social!["twitter"] as? NSDictionary
        let twitter = nullToNil(twitterDict!["link"]) as? String ?? "N/A"
        
        let socialInfo = SocialInfo(facebook: facebook, twitter: twitter)
        socialArray.append(socialInfo)
        totalResultsArray.append(socialArray)
      }
      
      let metacritic = nullToNil(jsonResult["metacritic"]) as? String
      let imdbID = nullToNil(jsonResult["imdb_id"]) as? String
      let wiki = nullToNil(jsonResult["wikipedia_id"]) as? NSNumber
      let id = nullToNil(jsonResult["id"]) as? NSNumber
      
      let exploreInfo = ExploreInfo(metacritic: metacritic, imdbID: imdbID, wiki: wiki, id: id)
      exploreArray.append(exploreInfo)
      totalResultsArray.append(exploreArray)
    }
    catch {
      showNetworkError()
    }
  }
  
  
  func getVideoJSON (urlString: String) {
    let url = NSURL(string: urlString)!
    let urlConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
    urlConfig.timeoutIntervalForRequest = 10
    urlConfig.timeoutIntervalForResource = 10
    let session = NSURLSession(configuration: urlConfig)
    task = session.dataTaskWithURL(url) {(data, response, error) in
      
    //Updates data on worker thread instead of main, makes the tableView load faster
        if (error == nil) {
          self.updateVideo(data!)
        } else {
    //Only uses main thread for ui
          dispatch_async(dispatch_get_main_queue()) {
            SwiftSpinner.hide()
            self.spinnerActive = false
            self.showNetworkError()
          }
        }
    }
    task!.resume()
  }
  
  
  func updateVideo (data: NSData!) {
    do {
      let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
      
      if let results = jsonResult["results"] as? [[String:AnyObject]] where !results.isEmpty {
        let result = results[0]
        if let freeIOSServices = result["free_ios_sources"] as? [[String:AnyObject]] where !results.isEmpty {
          if !freeIOSServices.isEmpty {let free = freeIOSServices[0]
            let videoView = free["embed"] as? String
            videoURL.append(videoView!)
            totalResultsArray.append(videoURL)
          }
        }
      }
    }
    catch {
  //Since the updateVideo is on worker thread, have to get back to main thread to show error or reload tableView
      dispatch_async(dispatch_get_main_queue()) {
        self.showNetworkError()
      }
    }
    
    dispatch_async(dispatch_get_main_queue()) {
      self.DetailTvTableView.reloadData()
    }
  }
  
  
  //MARK: TableView
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return totalResultsArray.count
  }
  
  override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 10.0
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    switch section {
    case 0: return bannerArray.count
    case 1: return videoURL.count
    case 2: return overViewArray.count
    case 3: return min(1, castLocalArray.count)
    case 4: return detailsArray.count
    case 5: return socialArray.count
    case 6: return exploreArray.count
    case 7: return min(1, photosArray.count)
      
    default: fatalError("Unknown Selection")
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    SwiftSpinner.hide()
    spinnerActive = false
    
    switch indexPath.section {
      
    case 0:
      let cell = tableView.dequeueReusableCellWithIdentifier("bannerCell", forIndexPath: indexPath) as! BannerCell
      
      if bannerArray[indexPath.row] != "" {
        cell.bannerImage.sd_setImageWithURL(NSURL(string: bannerArray[indexPath.row]))
      }
      
      self.DetailTvTableView.rowHeight = 100
      DetailTvTableView.allowsSelection = false
      return cell
      
    case 1:
      let cell = tableView.dequeueReusableCellWithIdentifier("videoDetail", forIndexPath: indexPath) as!
      VideoOnDetailCell
      print("\(videoURL)")
      cell.videoDetailWebView.delegate = cell
      cell.videoDetailWebView.allowsInlineMediaPlayback = true
      if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        self.DetailTvTableView.rowHeight = 400
        cell.videoDetailWebView.loadHTMLString("<iframe width=\"\(cell.videoDetailWebView.frame.width)\" height=\"\(400)\" src=\"\(videoURL[indexPath.row])/?&playsinline=1\" frameborder=\"0\" allowfullscreen></iframe>", baseURL: nil)
      } else {
        self.DetailTvTableView.rowHeight = 200
        cell.videoDetailWebView.loadHTMLString("<iframe width=\"\(cell.videoDetailWebView.frame.width)\" height=\"\(200)\" src=\"\(videoURL[indexPath.row])/?&playsinline=1\" frameborder=\"0\" allowfullscreen></iframe>", baseURL: nil)
      }
      
      
      return cell
      
    case 2:
      let cell = tableView.dequeueReusableCellWithIdentifier("overviewCell", forIndexPath: indexPath) as! OverviewCell
      let overViewText = overViewArray[indexPath.row]
      if overViewText != "" {
        cell.overView.text = overViewText
      } else {
        cell.overView.text = "N/A"
      }
      self.DetailTvTableView.rowHeight = 200
      return cell
      
    case 3:
      let cell = tableView.dequeueReusableCellWithIdentifier("castCell", forIndexPath: indexPath) as! CastCell
      cell.castArray = self.castLocalArray
      cell.collectionView.reloadData()
      self.DetailTvTableView.rowHeight = 111
      return cell
      
      
    case 4:
      let cell = tableView.dequeueReusableCellWithIdentifier("detailsCell") as! DetailsCell
      let details = detailsArray[indexPath.row]
      if details.firstAired != "" {
        cell.firstAiredData.text = details.firstAired
      } else {
        cell.firstAiredData.text = "N/A"
      }
      if details.network != "" {
        cell.networkData.text = details.network
      } else {
        cell.networkData.text = "N/A"
      }
      if details.rating != "" {
        cell.ratingData.text = details.rating
      } else {
        cell.ratingData.text = "N/A"
      }
      
      self.DetailTvTableView.rowHeight = 135
      DetailTvTableView.allowsSelection = false
      return cell
      
    case 5:
      let cell = tableView.dequeueReusableCellWithIdentifier("socialCell", forIndexPath: indexPath) as! SocialCell
      let socialData = socialArray[indexPath.row]
      if socialData.twitter != "" {
        cell.TwitterData.text = socialData.twitter
      } else {
        cell.TwitterData.text = "N/A"
      }
      if socialData.facebook != "" {
        cell.FaceBookData.text = socialData.facebook
      } else {
        cell.FaceBookData.text = "N/A"
      }
      self.DetailTvTableView.rowHeight = 150
      return cell
      
    case 6:
      let cell = tableView.dequeueReusableCellWithIdentifier("exploreCell", forIndexPath: indexPath) as! ExploreCell
      self.DetailTvTableView.rowHeight = 70
      DetailTvTableView.allowsSelection = false
      return cell
      
      
    case 7:
      let cell = tableView.dequeueReusableCellWithIdentifier("photosCell", forIndexPath: indexPath) as! PhotosCell
      cell.photosArray = self.photosArray
      cell.collectionView.reloadData()
      self.DetailTvTableView.rowHeight = 331
      return cell
      
    default: ""
    }
    return cell
  }
  
  override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if self.overViewArray.count == 0 {
      return nil
    } else {
      return indexPath
    }
  }
  
  
  
  //MARK: IBActions
  
  @IBAction func metacriticButton(sender: AnyObject) {
    if self.exploreArray[0].metacritic != nil {detailToWebsite = exploreArray[0].metacritic}
    else {detailToWebsite = "http://www.metacritic.com/"}
    performSegueWithIdentifier("DetailToWebsiteSegue", sender: self)
  }
  
  @IBAction func IMDBButton(sender: AnyObject) {
    if self.exploreArray[0].imdbID != "" {detailToWebsite = "https://www.imdb.com/title/\(exploreArray[0].imdbID!)"}
    else {detailToWebsite = "https://www.imdb.com"}
    performSegueWithIdentifier("DetailToWebsiteSegue", sender: self)
  }
  
  @IBAction func WikiButton(sender: AnyObject) {
    if self.exploreArray[0].wiki != nil {detailToWebsite = "https://en.wikipedia.org/wiki?curid=\(exploreArray[0].wiki!)"}
    else {detailToWebsite = "https://en.wikipedia.org/wiki/Television"}
    performSegueWithIdentifier("DetailToWebsiteSegue", sender: self)
  }
  
  //MARK: Segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue .identifier == "DetailToWebsiteSegue" {
      let websiteViewController = segue.destinationViewController as! WebsiteViewController
      websiteViewController.website = detailToWebsite
    } else if segue.identifier == "DetailToVideoSegue" {
      let videoViewController = segue.destinationViewController as! VideoViewController
      videoViewController.showToVideo = showToDetailSite
    }
  }
  
  //MARK: Network Error Indicator
  
  func showNetworkError () {
    let alert = UIAlertController(title: NSLocalizedString("Whoops?", comment: ""), message: NSLocalizedString("There was a connection error. Please try again.", comment: ""), preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Default, handler: {_ in self.navigationController?.popViewControllerAnimated(true)})
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
    
  }
}





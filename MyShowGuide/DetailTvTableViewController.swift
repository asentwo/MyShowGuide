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
  
  //MARK: ViewDidLoad
  
  override func viewDidLoad() {
    super.viewDidLoad()
    SwiftSpinner.show("Retrieving your show info...")
    spinnerActive = true
    delay(5, closure: {
      if self.spinnerActive == true {
        SwiftSpinner.hide()
        self.showNetworkError()
      }
    })
    self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    let newURL = "http://api-public.guidebox.com/v1.43/us/\(apiKey)/show/\(showToDetailSite)"
    getJSON(newURL)
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
      
      let banner = jsonResult["banner"] as? String ?? ""
      let overview = jsonResult["overview"] as? String ?? "N/A"
      let firstAired = jsonResult["first_aired"] as? String ?? "N/A"
      let network = jsonResult["network"] as? String ?? "N/A"
      let rating = jsonResult["rating"] as? String ?? "N/A"
      
      let showInfo = JustDetailsShowInfo(firstAired: firstAired, network: network, rating: rating)
      detailsArray.append(showInfo)
      bannerArray.append(banner)
      overViewArray.append(overview)
      
      if let castArray = jsonResult["cast"] as? [NSDictionary] {
        for castItem in castArray {
          let name = castItem["name"] as? String ?? "N/A"
          let characterName = castItem["character_name"] as? String ?? "N/A"
          let castInfo = CastInfo(name: name, characterName: characterName)
          castLocalArray.append(castInfo)
        }
      }
      
      let poster = jsonResult["poster"] as? String ?? "N/A"
      let artwork = jsonResult["artwork_608x342"] as? String ?? "N/A"
      let fanart = jsonResult["fanart"] as? String ?? "N/A"
      
      photosArray.append(poster)
      photosArray.append(fanart)
      photosArray.append(artwork)
      
      if let channels = jsonResult["channels"] as? [[String:AnyObject]] where !channels.isEmpty {
        let channel = channels[0] // now the compiler knows it's [String:AnyObject]
        let social = channel["social"] as? NSDictionary
        let facebookDict = social!["facebook"] as? NSDictionary
        let facebook = nullToNil(facebookDict!["link"]) as? String ?? "N/A"
        let twitterDict = social!["twitter"] as? NSDictionary
        let twitter = nullToNil(twitterDict!["link"]) as? String ?? "N/A"
        
        let socialInfo = SocialInfo(facebook: facebook, twitter: twitter)
        socialArray.append(socialInfo)

      }
     // let channels = jsonResult["channels"]?[0] as? [String: AnyObject]


      
      let metacritic = nullToNil(jsonResult["metacritic"]) as? String
      let imdbID = nullToNil(jsonResult["imdb_id"]) as? String
      let wiki = nullToNil(jsonResult["wikipedia_id"]) as? NSNumber
      let id = nullToNil(jsonResult["id"]) as? NSNumber
      
      let exploreInfo = ExploreInfo(metacritic: metacritic, imdbID: imdbID, wiki: wiki, id: id)
      exploreArray.append(exploreInfo)
      
    }
    catch {
      showNetworkError()
    }
     self.DetailTvTableView.reloadData()
  }
  
  //MARK: TableView
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 7
  }
  
  override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 20.0
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    switch section {
    case 0: return bannerArray.count
    case 1: return overViewArray.count
    case 2: return min(1, castLocalArray.count)
    case 3: return detailsArray.count
    case 4: return exploreArray.count
    case 5: return socialArray.count
    case 6: return min(1, photosArray.count)
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
      } else {
        cell.bannerImage.sd_setImageWithURL(NSURL(string: "placeholder_tableView"))
      }
      self.DetailTvTableView.rowHeight = 100
      DetailTvTableView.allowsSelection = false
      return cell
      
    case 1:
      let cell = tableView.dequeueReusableCellWithIdentifier("overviewCell", forIndexPath: indexPath) as! OverviewCell
      let overViewText = overViewArray[indexPath.row]
      if overViewText != "" {
        cell.overView.text = overViewText
      } else {
        cell.overView.text = "N/A"
      }
      self.DetailTvTableView.rowHeight = 200
      return cell
      
    case 2:
      let cell = tableView.dequeueReusableCellWithIdentifier("castCell", forIndexPath: indexPath) as! CastCell
      cell.castArray = self.castLocalArray
      cell.collectionView.reloadData()
      self.DetailTvTableView.rowHeight = 111
      return cell
      
    case 3:
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
      
    case 4:
      let cell = tableView.dequeueReusableCellWithIdentifier("exploreCell", forIndexPath: indexPath) as! ExploreCell
      self.DetailTvTableView.rowHeight = 70
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
    }
  }
  
  //MARK: Network Error Indicator
  
  func showNetworkError () {
    let alert = UIAlertController(title: "Whoops?", message: "There was a connection error. Please try again.", preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Default, handler: {_ in self.navigationController?.popViewControllerAnimated(true)})
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
    
  }

}





//
//  DetailTvTableViewController.swift
//  GuideBoxGuideNew1.0
//
//  Created by Justin Doo on 10/16/15.
//  Copyright © 2015 Justin Doo. All rights reserved.
//


import UIKit
import JSSAlertView


class DetailTvTableViewController: UITableViewController, UITextViewDelegate {
  
  //MARK: Constants/ IBOutlets
  
  var postersShown = [Bool](repeating: false, count: 8)
  var task : URLSessionTask?
  
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
    
    self.navigationController!.navigationBar.tintColor = UIColor.white
    let newURL = "http://api-public.guidebox.com/v1.43/us/\(apiKey)/show/\(showToDetailSite)"
    getJSON(newURL)
    
    print ("\(newURL)")
    print("\(spinnerActive)")
    let videoURL = "https://api-public.guidebox.com/v1.43/US/\(self.apiKey)/show/\(self.showToDetailSite)/clips/all/0/25/all/all/true"
    self.getVideoJSON(videoURL)
  }
  
  //MARK: JSON
  
  func getJSON (_ urlString: String) {
    
    let url = URL(string: urlString)!
    let urlConfig = URLSessionConfiguration.default
    urlConfig.timeoutIntervalForRequest = 8
    urlConfig.timeoutIntervalForResource = 8
    let session = URLSession(configuration: urlConfig)
    task = session.dataTask(with: url, completionHandler: {(data, response, error) in
      DispatchQueue.main.async {
        if (error == nil) {
          self.updateDetailShowInfo(data!)
          print("Made it this far")
        } else {
          SwiftSpinner.hide()
          self.spinnerActive = false
          
          JSSAlertView().show(
            self,
            title: NSLocalizedString("Whoops?", comment: ""),
            text: NSLocalizedString( "There was a connection error. Please try again.", comment: ""),
            buttonText: "Ok",
            iconImage: myShowGuideLogo)
          
          
        }
      }
    }) 
    task!.resume()
  }
  
  
  func updateDetailShowInfo (_ data: Data!) {
    do {
      let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
      
      let banner = jsonResult["banner"] as? String ?? ""
      let overview = jsonResult["overview"] as? String ?? "N/A"
      let firstAired = jsonResult["first_aired"] as? String ?? "N/A"
      let network = jsonResult["network"] as? String ?? "N/A"
      let rating = jsonResult["rating"] as? String ?? "N/A"
      
      let showInfo = JustDetailsShowInfo(firstAired: firstAired, network: network, rating: rating)
      detailsArray.append(showInfo)
      bannerArray.append(banner)
      overViewArray.append(overview)
      totalResultsArray.append(detailsArray as AnyObject)
      totalResultsArray.append(bannerArray as AnyObject)
      totalResultsArray.append(overViewArray as AnyObject)
      
      if let castArray = jsonResult["cast"] as? [NSDictionary] {
        for castItem in castArray {
          let name = castItem["name"] as? String ?? "N/A"
          let characterName = castItem["character_name"] as? String ?? "N/A"
          let castInfo = CastInfo(name: name, characterName: characterName)
          castLocalArray.append(castInfo)
        }
      }
      totalResultsArray.append(castLocalArray as AnyObject)
      
      let poster = jsonResult["poster"] as? String ?? "N/A"
      let artwork = jsonResult["artwork_608x342"] as? String ?? "N/A"
      let fanart = jsonResult["fanart"] as? String ?? "N/A"
      
      photosArray.append(poster)
      photosArray.append(fanart)
      photosArray.append(artwork)
      totalResultsArray.append(photosArray as AnyObject)
      
      if let channels = jsonResult["channels"] as? [[String:AnyObject]], !channels.isEmpty {
        let channel = channels[0] // now the compiler knows it's [String:AnyObject]
        let social = channel["social"] as? NSDictionary
        let facebookDict = social!["facebook"] as? [String:AnyObject]
        let facebook = nullToNil(facebookDict!["link"]) as? String ?? "N/A"
        let twitterDict = social!["twitter"] as? [String:AnyObject]
        let twitter = nullToNil(twitterDict!["link"]) as? String ?? "N/A"
        
        let socialInfo = SocialInfo(facebook: facebook, twitter: twitter)
        socialArray.append(socialInfo)
        totalResultsArray.append(socialArray as AnyObject)
      }
      
      let metacritic = nullToNil(jsonResult["metacritic"]) as? String
      let imdbID = nullToNil(jsonResult["imdb_id"]) as? String
      let wiki = nullToNil(jsonResult["wikipedia_id"]) as? NSNumber
      let id = nullToNil(jsonResult["id"]) as? NSNumber
      
      let exploreInfo = ExploreInfo(metacritic: metacritic, imdbID: imdbID, wiki: wiki, id: id)
      exploreArray.append(exploreInfo)
      totalResultsArray.append(exploreArray as AnyObject)
    }
    catch {
      JSSAlertView().show(
        self,
        title: NSLocalizedString("Whoops?", comment: ""),
        text: NSLocalizedString( "There was a connection error. Please try again.", comment: ""),
        buttonText: "Ok",
        iconImage: myShowGuideLogo)
      
    }
  }
  
  
  func getVideoJSON (_ urlString: String) {
    let url = URL(string: urlString)!
    let urlConfig = URLSessionConfiguration.default
    urlConfig.timeoutIntervalForRequest = 8
    urlConfig.timeoutIntervalForResource = 8
    let session = URLSession(configuration: urlConfig)
    task = session.dataTask(with: url, completionHandler: {(data, response, error) in
      
      //Updates data on worker thread instead of main, makes the tableView load faster
      if (error == nil) {
        self.updateVideo(data!)
      } else {
        print("Video did not load")
        print("\(self.spinnerActive)")
        if  self.spinnerActive == true {
          
          DispatchQueue.main.async {
            SwiftSpinner.hide()
            self.spinnerActive = false
            
            JSSAlertView().show(
              self,
              title: NSLocalizedString("Whoops?", comment: ""),
              text: NSLocalizedString( "There was a connection error. Please try again.", comment: ""),
              buttonText: "Ok",
              iconImage: myShowGuideLogo)
          }
        }
      }
    }) 
    task!.resume()
  }
  
  
  func updateVideo (_ data: Data!) {
    do {
      let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
      
      if let results = jsonResult["results"] as? [[String:AnyObject]], !results.isEmpty {
        let result = results[0]
        if let freeIOSServices = result["free_ios_sources"] as? [[String:AnyObject]], !results.isEmpty {
          if !freeIOSServices.isEmpty {let free = freeIOSServices[0]
            let videoView = free["embed"] as? String
            videoURL.append(videoView!)
            totalResultsArray.append(videoURL as AnyObject)
          }
        }
      }
    }
    catch {
      print("Video did not load")
      print("\(self.spinnerActive)")
      if  self.spinnerActive == true {
        
        DispatchQueue.main.async {
          SwiftSpinner.hide()
          self.spinnerActive = false
          
          JSSAlertView().show(
            self,
            title: NSLocalizedString("Whoops?", comment: ""),
            text: NSLocalizedString( "There was a connection error. Please try again.", comment: ""),
            buttonText: "Ok",
            iconImage: myShowGuideLogo)
        }
      }
    }
    
    DispatchQueue.main.async {
      self.DetailTvTableView.reloadData()
    }
  }
  
  
  //MARK: TableView
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return totalResultsArray.count
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 10.0
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
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
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    SwiftSpinner.hide()
    spinnerActive = false
    
    switch indexPath.section {
      
    case 0:
      let cell = tableView.dequeueReusableCell(withIdentifier: "bannerCell", for: indexPath) as! BannerCell
      
      if bannerArray[indexPath.row] != "" {
        cell.bannerImage.sd_setImage(with: URL(string: bannerArray[indexPath.row]))
      }
      
      self.DetailTvTableView.rowHeight = 100
      DetailTvTableView.allowsSelection = false
      return cell
      
    case 1:
      let cell = tableView.dequeueReusableCell(withIdentifier: "videoDetail", for: indexPath) as!
      VideoOnDetailCell
      print("\(videoURL)")
      cell.videoDetailWebView.delegate = cell
      cell.videoDetailWebView.allowsInlineMediaPlayback = true
      if UIDevice.current.userInterfaceIdiom == .pad {
        self.DetailTvTableView.rowHeight = 400
        cell.videoDetailWebView.loadHTMLString("<iframe width=\"\(cell.videoDetailWebView.frame.width)\" height=\"\(400)\" src=\"\(videoURL[indexPath.row])/?&playsinline=1\" frameborder=\"0\" allowfullscreen></iframe>", baseURL: nil)
      } else {
        self.DetailTvTableView.rowHeight = 200
        cell.videoDetailWebView.loadHTMLString("<iframe width=\"\(cell.videoDetailWebView.frame.width)\" height=\"\(200)\" src=\"\(videoURL[indexPath.row])/?&playsinline=1\" frameborder=\"0\" allowfullscreen></iframe>", baseURL: nil)
      }
      
      
      return cell
      
    case 2:
      let cell = tableView.dequeueReusableCell(withIdentifier: "overviewCell", for: indexPath) as! OverviewCell
      let overViewText = overViewArray[indexPath.row]
      if overViewText != "" {
        cell.overView.text = overViewText
      } else {
        cell.overView.text = "N/A"
      }
      self.DetailTvTableView.rowHeight = 200
      return cell
      
    case 3:
      let cell = tableView.dequeueReusableCell(withIdentifier: "castCell", for: indexPath) as! CastCell
      cell.castArray = self.castLocalArray
      cell.collectionView.reloadData()
      self.DetailTvTableView.rowHeight = 111
      return cell
      
      
    case 4:
      let cell = tableView.dequeueReusableCell(withIdentifier: "detailsCell") as! DetailsCell
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
      let cell = tableView.dequeueReusableCell(withIdentifier: "socialCell", for: indexPath) as! SocialCell
      let socialData = socialArray[indexPath.row]
      self.DetailTvTableView.rowHeight = 50
      DetailTvTableView.allowsSelection = false
      
      return cell
      
    case 6:
      let cell = tableView.dequeueReusableCell(withIdentifier: "exploreCell", for: indexPath) as! ExploreCell
      self.DetailTvTableView.rowHeight = 50
      DetailTvTableView.allowsSelection = false
      return cell
      
      
    case 7:
      let cell = tableView.dequeueReusableCell(withIdentifier: "photosCell", for: indexPath) as! PhotosCell
      cell.photosArray = self.photosArray
      cell.collectionView.reloadData()
      self.DetailTvTableView.rowHeight = 331
      return cell
      
    default: ""
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    if self.overViewArray.count == 0 {
      return nil
    } else {
      return indexPath
    }
  }
  
  
  
  //MARK: IBActions
  
  @IBAction func metacriticButton(_ sender: AnyObject) {
    if self.exploreArray[0].metacritic != nil {detailToWebsite = exploreArray[0].metacritic}
    else {detailToWebsite = "http://www.metacritic.com/"}
    performSegue(withIdentifier: "DetailToWebsiteSegue", sender: self)
  }
  
  @IBAction func IMDBButton(_ sender: AnyObject) {
    if self.exploreArray[0].imdbID != "" {detailToWebsite = "https://www.imdb.com/title/\(exploreArray[0].imdbID!)"}
    else {detailToWebsite = "https://www.imdb.com"}
    performSegue(withIdentifier: "DetailToWebsiteSegue", sender: self)
  }
  
  @IBAction func WikiButton(_ sender: AnyObject) {
    if self.exploreArray[0].wiki != nil {detailToWebsite = "https://en.wikipedia.org/wiki?curid=\(exploreArray[0].wiki!)"}
    else {detailToWebsite = "https://en.wikipedia.org/wiki/Television"}
    performSegue(withIdentifier: "DetailToWebsiteSegue", sender: self)
  }
  
  @IBAction func FacebookButton(_ sender: AnyObject) {
    if self.socialArray[0].facebook != nil {
      detailToWebsite = socialArray[0].facebook} else {
      "https://www.facebook.com"}
    performSegue(withIdentifier: "DetailToWebsiteSegue", sender: self)
    
  }
  
  @IBAction func TwitterButton(_ sender: AnyObject) {
    if self.socialArray[0].twitter != nil {
      detailToWebsite = socialArray[0].twitter} else {
      "https://www.facebook.com"}
    performSegue(withIdentifier: "DetailToWebsiteSegue", sender: self)
  }
  
  
  //MARK: Segue
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue .identifier == "DetailToWebsiteSegue" {
      let websiteViewController = segue.destination as! WebsiteViewController
      websiteViewController.website = detailToWebsite
    } else if segue.identifier == "DetailToVideoSegue" {
      let videoViewController = segue.destination as! VideoViewController
      videoViewController.showToVideo = showToDetailSite
    }
  }
  
  //MARK: Network Error Indicator
  
  func errorGoToPreviousScreen () {
    // self.dismissViewControllerAnimated(true, completion: nil)
    self.navigationController?.popViewController(animated: true)
  }
}





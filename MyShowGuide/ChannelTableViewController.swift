//
//  ChannelTableViewController.swift
//  GuideBoxGuide2.0
//
//  Created by Justin Doo on 2/9/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

import UIKit


class ChannelTableViewController: UITableViewController, UISearchResultsUpdating {
  
  //MARK: Constants/ IBOutlets
  
  var channelArray: [ChannelInfo] = []
  var logosShown = [Bool](count: 50, repeatedValue: false)
  var detailUrl: String?
  var apiKey = "rKk09BXyG0kXF1lnde9GOltFq6FfvNQd"
  var channel: String!
  var channelForShow: String!
  var task: NSURLSessionTask?
  var filteredSearchResults = [ChannelInfo]()
  var resultsSearchController = UISearchController(searchResultsController: nil)
  
  @IBOutlet var channelTableView: UITableView!
  
  //MARK: ViewDidLoad
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let baseURL = "http://api-public.guidebox.com/v1.43/us/\(apiKey)/channels/all/0/50"
    getJSON(baseURL)
    tableViewAttributes()
    SearchBarAttributes()
    SwiftSpinner.show("Retrieving your channels..")
    self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
  }
  
  //MARK: TableView
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ChannelCell", forIndexPath: indexPath) as! ChannelCell
    let channel: String
    
    if self.resultsSearchController.active && resultsSearchController.searchBar.text != "" {
      channel = filteredSearchResults[indexPath.row].logo
    } else {
      channel = channelArray[indexPath.row].logo
    }
    cell.channelImageView.sd_setImageWithURL(NSURL(string: channel))
    SwiftSpinner.hide()
    
    return cell
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if self.resultsSearchController.active && resultsSearchController.searchBar.text != ""
    {
      return self.filteredSearchResults.count
    } else {
      return channelArray.count
    }
  }
  
  func tableViewAttributes () {
    self.tableView.allowsSelection = true
    self.tableView.rowHeight = 200
    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    self.tableView.reloadData()
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    var replacedTitle: String?
    
    if resultsSearchController.active && resultsSearchController.searchBar.text != "" {
      
      channelForShow = filteredSearchResults[indexPath.row].channelName
      
      switch channelForShow {
      case "Disney XD":replacedTitle = "disneyxd"; channelForShow = replacedTitle
      case "A&E":replacedTitle = "ae"; channelForShow = replacedTitle
      case "Disney Junior":replacedTitle = "disneyjunior"; channelForShow = replacedTitle
      case "CW Seed":replacedTitle = "cwseed"; channelForShow = replacedTitle
      default : break
      }
    } else {
      channelForShow = channelArray[indexPath.row].channelName
      switch channelForShow {
      case "Disney XD":replacedTitle = "disneyxd"; channelForShow = replacedTitle
      case "A&E":replacedTitle = "ae"; channelForShow = replacedTitle
      case "Disney Junior":replacedTitle = "disneyjunior"; channelForShow = replacedTitle
      case "CW Seed":replacedTitle = "cwseed"; channelForShow = replacedTitle
      default : break
      }
    }
    self.dismissSearchBar()
    performSegueWithIdentifier("channelToShowSegue", sender: self)
  }
  
  //makes channel cell unclickable
  override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    
    switch indexPath.row {
    case 10: return nil
    case 12: return nil
    case 32: return nil
    default: return indexPath
    }
  }
  
  //MARK: JSON Parsing
  
  func getJSON (urlString: String) {
    
    let url = NSURL(string: urlString)!
    let session = NSURLSession.sharedSession()
    task = session.dataTaskWithURL(url) {(data, response, error) in
      dispatch_async(dispatch_get_main_queue()) {
        if (error == nil) {
          self.updateJSON(data)
        }
        else {
        }
      }
    }
    task!.resume()
  }
  
  
  func updateJSON (data: NSData!) {
    do {
      let showData = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as!
      NSDictionary
      
      let results = showData["results"] as! [NSDictionary]?
      if let showDataArray = results {
        for data in showDataArray {
          let logo = data["artwork_608x342"] as? String
          let channelName = data["name"] as? String
          let id = data["id"] as? NSNumber
          
          let info = ChannelInfo(logo: logo!, channelName: channelName!, id: id!)
          channelArray.append(info)
          self.logosShown = [Bool](count: channelArray.count, repeatedValue: false)
        }
      }
    } catch {
      print("It ain't working")
    }
    channelTableView.reloadData()
  }
  
  
  // MARK: Animation
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    if logosShown[indexPath.row] == false {
      cell.alpha = 0
      //cells intitial value transparent
      UIView.animateWithDuration(1.0, animations: { () -> Void in
        cell.alpha = 1
        //cells back from transparency
      })
      logosShown[indexPath.row] = true
      // marks all posters that have already animated in to true to they won't animate again
    }
  }
  
  //MARK: Searchbar
  
  func SearchBarAttributes () {
    self.resultsSearchController = UISearchController(searchResultsController: nil)//required!
    self.resultsSearchController.searchResultsUpdater = self// required!
    self.resultsSearchController.dimsBackgroundDuringPresentation = false
    self.resultsSearchController.hidesNavigationBarDuringPresentation = false
    self.resultsSearchController.searchBar.sizeToFit()//fits tableview properly
    self.resultsSearchController.searchBar.searchBarStyle = UISearchBarStyle.Prominent
    self.resultsSearchController.searchBar.translucent = false
    self.resultsSearchController.searchBar.barTintColor = UIColor.whiteColor()
    self.resultsSearchController.searchBar.placeholder = "Search channels here..."
    self.resultsSearchController.definesPresentationContext = true//removes search controller if move to other vc
    self.tableView.tableHeaderView = self.resultsSearchController.searchBar
    self.tableView.reloadData()
  }
  
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    
    self.filteredSearchResults.removeAll(keepCapacity: false)
    let searchPredicate = NSPredicate(format: "channelName CONTAINS [c] %@", searchController.searchBar.text!)
    let array = (self.channelArray as NSArray).filteredArrayUsingPredicate(searchPredicate)
    self.filteredSearchResults = array as! [ChannelInfo]
    self.tableView.reloadData()
  }
  
  func dismissSearchBar () {
    resultsSearchController.active = false
    //dismisses search bar after transitioning to next vc
  }
  
  
  //MARK: Segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "channelToShowSegue"{
      let showVC = segue.destinationViewController as! ShowTableViewController
      showVC.showType = channelForShow.lowercaseString
      SwiftSpinner.show("Retrieving your shows...")
    }
  }
}

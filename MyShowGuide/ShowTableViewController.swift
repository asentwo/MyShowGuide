//
// This Is A Test
//  ViewController.swift
//  GuideBoxGuideNew1.0
//
//  Created by Justin Doo on 10/14/15.
//  Copyright © 2015 Justin Doo. All rights reserved.
//

import UIKit


class ShowTableViewController: UITableViewController, UISearchResultsUpdating {
  
  //MARK: Constants/ IBOutlets
  
  var showArray:[TvShowInfo] = []
  var postersShown = [Bool](count: 50, repeatedValue: false)
  var detailUrl: String?
  let apiKey = "rKk09BXyG0kXF1lnde9GOltFq6FfvNQd"
  var showType: String!
  var task: NSURLSessionTask?
  var filteredShowSearchResults: [TvShowInfo] = []
  var showResultsSearchController = UISearchController(searchResultsController: nil)
  
  @IBOutlet var TvShowTableView: UITableView!
  
  //MARK: ViewDidLoad
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let showNoSpaces = showType.stringByReplacingOccurrencesOfString(" ", withString: "_")
    let baseURL = "http://api-public.guidebox.com/v1.43/us/\(apiKey)/shows/\(showNoSpaces)/0/25/all/all"
    getJSON(baseURL)
    tableViewAttributes()
    SearchBarAttributes()
    self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
  }
  
  //MARK: TableView
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("TvShowCell", forIndexPath: indexPath) as! TvShowCell
    
    if self.showResultsSearchController.active {
      self.navigationItem.setHidesBackButton(true, animated:true)
      cell.MainTitleLabel.text = filteredShowSearchResults[indexPath.row].title
      cell.MainPosterImage.sd_setImageWithURL(NSURL(string: filteredShowSearchResults[indexPath.row].poster))
    }else {
      cell.MainTitleLabel.text = showArray[indexPath.row].title
      cell.MainPosterImage.sd_setImageWithURL(NSURL(string: showArray[indexPath.row].poster))
    }
    
    SwiftSpinner.hide()
    return cell
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if self.showResultsSearchController.active {
      self.navigationItem.setHidesBackButton(true, animated:true)
      return filteredShowSearchResults.count
    } else {
      return showArray.count
    }
  }
  
  func tableViewAttributes () {
    self.tableView.allowsSelection = true
    self.tableView.rowHeight = 220
    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    self.tableView.reloadData()
  }
  
  override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    
    if self.showResultsSearchController.active {
      return indexPath
    } else {
      if indexPath.row == 0 {
        return nil
      } else {
        return indexPath
      }
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    if showResultsSearchController.active {
      detailUrl = "http://api-public.guidebox.com/v1.43/us/\(apiKey)/show/\(filteredShowSearchResults[indexPath.row].id)"
    } else {
      detailUrl = "http://api-public.guidebox.com/v1.43/us/\(apiKey)/show/\(showArray[indexPath.row].id)"
      
      print("\(detailUrl)")
    }
    dismissSearchBar()
    performSegueWithIdentifier("showToDetailSegue", sender: self)
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
          let title = data["title"] as! String
          let poster = data["artwork_608x342"] as! String
          let id = data["id"] as! NSNumber
          
          let info = TvShowInfo(poster: poster, title: title, id: id)
          showArray.append(info)
          self.postersShown = [Bool](count: showArray.count, repeatedValue: false)
        }
      }
    } catch {
      print("It ain't working")
    }
    TvShowTableView.reloadData()
  }
  
  // MARK: Parallax Effect
  
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    let offsetY = self.tableView.contentOffset.y
    for cell in self.tableView.visibleCells as! [TvShowCell] {
      
      let x = cell.MainPosterImage.frame.origin.x
      let w = cell.MainPosterImage.bounds.width
      let h = cell.MainPosterImage.bounds.height
      let y = ((offsetY - cell.frame.origin.y) / h) * 15
      cell.MainPosterImage.frame = CGRectMake(x, y, w, h)
      cell.contentMode = UIViewContentMode.ScaleAspectFill
    }
  }
  
  // MARK: Animation
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    if postersShown[indexPath.row] == false {
      cell.alpha = 0
      //cells intitial value transparent
      UIView.animateWithDuration(0.5, animations: { () -> Void in
        cell.alpha = 1
        //cells back from transparency
      })
      postersShown[indexPath.row] = true
      // marks all posters that have already animated in to true to they won't animate again
    }
  }
  
  //MARK: Searchbar
  
  func SearchBarAttributes () {
    self.showResultsSearchController = UISearchController(searchResultsController: nil)//required!
    self.showResultsSearchController.searchResultsUpdater = self// required!
    self.showResultsSearchController.dimsBackgroundDuringPresentation = false
    self.showResultsSearchController.hidesNavigationBarDuringPresentation = false
    self.showResultsSearchController.searchBar.sizeToFit()//fits tableview properly
    self.showResultsSearchController.searchBar.searchBarStyle = UISearchBarStyle.Prominent
    self.showResultsSearchController.searchBar.translucent = false
    self.showResultsSearchController.searchBar.barTintColor = UIColor.whiteColor()
    self.showResultsSearchController.searchBar.placeholder = "Search shows here..."
    self.showResultsSearchController.definesPresentationContext = true//removes search controller if move to other vc
    self.tableView.tableHeaderView = self.showResultsSearchController.searchBar
    self.tableView.reloadData()
  }
  
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    
    self.filteredShowSearchResults.removeAll(keepCapacity: false)
    let searchPredicate = NSPredicate(format: "title CONTAINS [c] %@", searchController.searchBar.text!)
    let array = (self.showArray as NSArray).filteredArrayUsingPredicate(searchPredicate)
    self.filteredShowSearchResults = array as! [TvShowInfo]
    self.tableView.reloadData()
  }
  
  func dismissSearchBar () {
    showResultsSearchController.active = false
  }
  
  //MARK: PrepareForSegue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showToDetailSegue"
    {
      let detailViewController = segue.destinationViewController as! DetailTvTableViewController
      detailViewController.newURL = detailUrl
      print("\(detailUrl)")
      SwiftSpinner.show("Retrieving your show info...")
    }
  }
}






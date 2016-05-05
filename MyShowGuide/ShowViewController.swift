//
// This Is A Test
//  ViewController.swift
//  GuideBoxGuideNew1.0
//
//  Created by Justin Doo on 10/14/15.
//  Copyright © 2015 Justin Doo. All rights reserved.
//

import UIKit

class ShowViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
  
  //MARK: Constants/ IBOutlets
  
  var showArray:[TvShowInfo] = []
  var postersShown = [Bool](count: 50, repeatedValue: false)
  var detailUrl: String?
  let apiKey = "rKk09BXyG0kXF1lnde9GOltFq6FfvNQd"
  var showType: String!
  var showForDetail: NSNumber?
  var task: NSURLSessionTask?
  var filteredShowSearchResults: [TvShowInfo] = []
  var searchBarActive: Bool = false
  var spinnerActive = false
  var savedFavorite: TvShowInfo!
  var savedFavoriteArray:[TvShowInfo] = []
  
  @IBOutlet var tvShowTableView: UITableView!
  @IBOutlet weak var showSearchBar: UISearchBar!

  
  
  //MARK: ViewDidLoad
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//   BackendlessUserFunctions.sharedInstance.saveFavoriteToBackendless(TvShowInfo(poster: "asdsa", title: "dsadsa", id: 123))
    
//    BackendlessUserFunctions.sharedInstance.retrieveFavoriteFromBackendless(TvShowInfo(poster: "asdsa", title: "dsadsa", id: 123))
    
    
    BackendlessUserFunctions.sharedInstance.retrieveFavoriteFromBackendless({ ( favoriteShows : BackendlessCollection!) -> () in
      
      print("FavoritesShowInfo have been fetched:")
      
      for favoriteShow in favoriteShows.data {
       
        let currentShow = favoriteShow as! BackendlessUserFunctions.FavoritesShowInfo
        
        print("title = \(currentShow.title)")
      }

      }
      , err: { ( fault : Fault!) -> () in
        print("FavoritesShowInfo were not fetched: \(fault)")
      }
    )
    
    
    
    
    
    let showNoSpaces = showType.stringByReplacingOccurrencesOfString(" ", withString: "_")
    let baseURL = "http://api-public.guidebox.com/v1.43/us/\(apiKey)/shows/\(showNoSpaces)/0/25/all/all"
    getJSON(baseURL)
    tableViewAttributes()
    self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    showSearchBar.delegate = self
    SwiftSpinner.show(NSLocalizedString("Retrieving your shows...", comment: "Loading Message"))
    spinnerActive = true
    }
  
  //reloads so checkmarks dissapear when removed from favorites
  override func viewWillAppear(animated: Bool) {
    self.tvShowTableView.reloadData()
  }
  
  
  //MARK: TableView
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("TvShowCell", forIndexPath: indexPath) as! TvShowCell
    cell.MainTitleLabel.adjustsFontSizeToFitWidth = true
   
    if self.searchBarActive {
      cell.MainTitleLabel.text = filteredShowSearchResults[indexPath.row].title
      cell.MainPosterImage.sd_setImageWithURL(NSURL(string: filteredShowSearchResults[indexPath.row].poster))
      savedFavorite = filteredShowSearchResults[indexPath.row]
    }else {
      cell.MainTitleLabel.text = showArray[indexPath.row].title
      cell.MainPosterImage.sd_setImageWithURL(NSURL(string: showArray[indexPath.row].poster))
      savedFavorite = showArray[indexPath.row]
    }

// KRH - checking to see if show is favorite in UserDefaults
    if UserDefaults.sharedInstance.isFavorite(savedFavorite.id) {
      cell.saveButton.setImage(UIImage(named: "save_icon_greenCheck"), forState: UIControlState.Normal)
    } else {
      cell.saveButton.setImage(UIImage(named: "save_icon_white"), forState: UIControlState.Normal)
    }
    
    SwiftSpinner.hide()
    spinnerActive = false
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if self.searchBarActive {
      self.navigationItem.setHidesBackButton(true, animated:true)
      return filteredShowSearchResults.count
    } else {
      return showArray.count
    }
  }
  
  func tableViewAttributes () {
    tvShowTableView.allowsSelection = true
    tvShowTableView.rowHeight = UITableViewAutomaticDimension
    tvShowTableView.estimatedRowHeight = 220.0
    tvShowTableView.separatorStyle = UITableViewCellSeparatorStyle.None
    tvShowTableView.reloadData()
  }
  
  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if self.searchBarActive {
      return indexPath
    } else {
      if indexPath.row == 0 {
        return nil
      } else {
        return indexPath
      }
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if searchBarActive {
      showForDetail = filteredShowSearchResults[indexPath.row].id
    } else {
      showForDetail = showArray[indexPath.row].id
    }
    performSegueWithIdentifier("showToDetailSegue", sender: self)
  }
  
  
  //MARK: JSON Parsing
  
  func getJSON (urlString: String) {
    
    let url = NSURL(string: urlString)!
    let urlConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
    urlConfig.timeoutIntervalForRequest = 7
    urlConfig.timeoutIntervalForResource = 7
    let session = NSURLSession(configuration: urlConfig)
    task = session.dataTaskWithURL(url) {(data, response, error) in
      dispatch_async(dispatch_get_main_queue()) {
        if (error == nil) {
          self.updateJSON(data)
        }
        else {
          SwiftSpinner.hide()
          self.spinnerActive = false
          self.showNetworkError()
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
      showNetworkError()
    }
    tvShowTableView.reloadData()
  }
  
  // MARK: Parallax Effect
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    let offsetY =  tvShowTableView.contentOffset.y
    for cell in  tvShowTableView.visibleCells as! [TvShowCell] {
      let x = cell.MainPosterImage.frame.origin.x
      let w = cell.MainPosterImage.bounds.width
      let h = cell.MainPosterImage.bounds.height
      let y = ((offsetY - cell.frame.origin.y) / h) * 15
      cell.MainPosterImage.frame = CGRectMake(x, y, w, h)
      cell.contentMode = UIViewContentMode.ScaleAspectFill
    }
  }
  
  // MARK: Animation
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
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
  
  func filterContentForSearchText(searchText: String){
    self.filteredShowSearchResults.removeAll(keepCapacity: false)
    let searchPredicate = NSPredicate(format: "title CONTAINS [c] %@", searchText)
    let array = (self.showArray as NSArray).filteredArrayUsingPredicate(searchPredicate)
    self.filteredShowSearchResults = array as! [TvShowInfo]
    
  }
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.characters.count > 0 {
      
      self.searchBarActive = true
      self.filterContentForSearchText(searchText)
      self.tvShowTableView.reloadData()
    } else {
      self.searchBarActive = false
      self.tvShowTableView.reloadData()
      
    }
  }
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    self.navigationItem.setHidesBackButton(false, animated: true)
    self.cancelSearching()
    self.tvShowTableView.reloadData()
  }
  
  func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    self.showSearchBar!.setShowsCancelButton(true, animated: true)
  }
  
  func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    self.searchBarActive = false
    self.showSearchBar!.setShowsCancelButton(true, animated: true)
  }
  
  func cancelSearching() {
    self.searchBarActive = false
    self.showSearchBar!.resignFirstResponder()
    self.showSearchBar!.text = ""
  }
  
  //MARK: PrepareForSegue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showToDetailSegue"
    {
      let detailViewController = segue.destinationViewController as! DetailTvTableViewController
      detailViewController.showToDetailSite = self.showForDetail!
    }
    
  }
  
  //MARK: Network Error Indicator
  
  func showNetworkError () {
    let alert = UIAlertController(title: NSLocalizedString("Whoops?", comment: ""), message: NSLocalizedString( "There was a connection error. Please try again.", comment: ""), preferredStyle: .Alert)
    
    //goes back to previous view controller
    let action = UIAlertAction(title: "OK", style: .Default, handler: {_ in self.navigationController?.popViewControllerAnimated(true)})
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
    
  }
  
  @IBAction func FavoritesButton(sender: AnyObject) {
    performSegueWithIdentifier("showToFavoritesSegue", sender: self)
  }
  
// KRH
    @IBAction func saveShow(sender: UIButton) {
    
        //accessing current point of tableView Cell
        let location: CGPoint = sender.convertPoint(CGPointZero, toView: self.tvShowTableView)
        let indexPath: NSIndexPath = self.tvShowTableView.indexPathForRowAtPoint(location)!

        if searchBarActive {
            
            savedFavorite = filteredShowSearchResults[indexPath.row]
            
//            if UserDefaults.sharedInstance.isFavorite(savedFavorite.id) {
          if BackendlessUserFunctions.sharedInstance.isShowAlreadyFavorite(savedFavorite.id) {
                sender.setImage(UIImage(named: "save_icon_white"), forState: UIControlState.Normal)
            } else {
//                UserDefaults.sharedInstance.addFavorite(TvShowInfo(poster: savedFavorite.poster, title: savedFavorite.title, id: savedFavorite.id))
            BackendlessUserFunctions.sharedInstance.saveFavoriteToBackendless(TvShowInfo(poster: savedFavorite.poster, title: savedFavorite.title, id: savedFavorite.id))
                sender.setImage(UIImage(named: "save_icon_greenCheck"), forState: UIControlState.Normal)
            }
          
        } else {
            
            savedFavorite = showArray[indexPath.row]

           // if UserDefaults.sharedInstance.isFavorite(savedFavorite.id) {
           if BackendlessUserFunctions.sharedInstance.isShowAlreadyFavorite(savedFavorite.id) {
               // UserDefaults.sharedInstance.removeFavorite(savedFavorite)
                sender.setImage(UIImage(named: "save_icon_white"), forState: UIControlState.Normal)

            } else {

//                UserDefaults.sharedInstance.addFavorite(TvShowInfo(poster: savedFavorite.poster, title: savedFavorite.title, id: savedFavorite.id))
              BackendlessUserFunctions.sharedInstance.saveFavoriteToBackendless(TvShowInfo(poster: savedFavorite.poster, title: savedFavorite.title, id: savedFavorite.id))
                sender.setImage(UIImage(named: "save_icon_greenCheck"), forState: UIControlState.Normal)
            }
        }
    }
}







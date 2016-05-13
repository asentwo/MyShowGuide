//
// This Is A Test
//  ViewController.swift
//  GuideBoxGuideNew1.0
//
//  Created by Justin Doo on 10/14/15.
//  Copyright © 2015 Justin Doo. All rights reserved.
//

import UIKit
import JSSAlertView

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
  
  
  @IBOutlet var tvShowTableView: UITableView!
  @IBOutlet weak var showSearchBar: UISearchBar!
  @IBOutlet weak var favoritesToolBarButton: UIBarButtonItem!
  
  
  //MARK: ViewDidLoad
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let showNoSpaces = showType.stringByReplacingOccurrencesOfString(" ", withString: "_")
    let baseURL = "http://api-public.guidebox.com/v1.43/us/\(apiKey)/shows/\(showNoSpaces)/0/25/all/all"
    getJSON(baseURL)
    tableViewAttributes()
    self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    showSearchBar.delegate = self
    SwiftSpinner.show(NSLocalizedString("Retrieving your shows...", comment: "Loading Message"))
    spinnerActive = true
  }
  
  
  override func viewWillAppear(animated: Bool) {
    
    //reloads so checkmarks dissapear when removed from favorites
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
    
    //checking to see if show is favorite in local savedFavorites array
    if isShowAlreadyFavorite(savedFavorite) == true {
      cell.saveButton.setImage(UIImage(named: "save_icon_greenCheck"), forState: UIControlState.Normal)
      SwiftSpinner.hide()
      spinnerActive = false
    } else {
      cell.saveButton.setImage(UIImage(named: "save_icon_white"), forState: UIControlState.Normal)
      SwiftSpinner.hide()
      spinnerActive = false
    }
    
    
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
          JSSAlertView().show(
            self,
            title: NSLocalizedString("Whoops?", comment: ""),
            text: NSLocalizedString( "There was a connection error. Please try again.", comment: ""),
            buttonText: "Ok",
            iconImage: myShowGuideLogo)
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
      JSSAlertView().show(
        self,
        title: NSLocalizedString("Whoops?", comment: ""),
        text: NSLocalizedString( "There was a connection error. Please try again.", comment: ""),
        buttonText: "Ok",
        iconImage: myShowGuideLogo)
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
  
  //MARK: AlertViews
  
  func alertSignUpAction () {
    self.performSegueWithIdentifier("favToLogin", sender: self)
    
  }
  
  func errorGoToPreviousScreen () {
    self.navigationController?.popViewControllerAnimated(true)
  }


  @IBAction func FavoritesButton(sender: AnyObject) {
    
    if BackendlessUserFunctions.sharedInstance.isValidUser() {
      performSegueWithIdentifier("showToFavoritesSegue", sender: self)
    } else {
      
      let alertView = JSSAlertView().show(
        self,
        title: NSLocalizedString("Whoops?", comment: ""),
        text: NSLocalizedString( "Must sign up for an account to save favorite shows.", comment: ""),
        buttonText: "Ok",
        iconImage: myShowGuideLogo)
      alertView.addAction(self.alertSignUpAction)
    }
  }
  
  
  //MARK: Show Favorite Check
  
  func isShowAlreadyFavorite(favShow: TvShowInfo) -> Bool {
    
    //find the show by id.
    let showsThatMatchIdArray = savedFavoriteArray.filter({$0.id == favShow.id})
    
    //'filter' doesn't return a bool so must use 'isEmpty' to return a bool
    if showsThatMatchIdArray.isEmpty {
      
      return false
    } else {
      return true
    }
  }
  
  
  @IBAction func saveShow(sender: UIButton) {
    
    if BackendlessUserFunctions.sharedInstance.isValidUser() {
      
      print("\(savedFavoriteArray.count)")
      sender.enabled = false
      favoritesToolBarButton.enabled = false
      
      //accessing current point of tableView Cell
      let location: CGPoint = sender.convertPoint(CGPointZero, toView: self.tvShowTableView)
      let indexPath: NSIndexPath = self.tvShowTableView.indexPathForRowAtPoint(location)!
      
      if searchBarActive {
        
        savedFavorite = filteredShowSearchResults[indexPath.row]
        
        //user unchecks favorite circle
        if isShowAlreadyFavorite(savedFavorite) == true {
          
          //remove from backendless
          BackendlessUserFunctions.sharedInstance.removeFavoriteFromBackendless(savedFavorite.objectID!)
          
          //remove from local array (savedFavoriteArray)by syncronizing to itself after the object has been removed
          savedFavoriteArray = savedFavoriteArray.filter({$0.id != savedFavorite.id})
          
          //set the ui- unchecked
          sender.setImage(UIImage(named: "save_icon_white"), forState: UIControlState.Normal)
          sender.enabled = true
          favoritesToolBarButton.enabled = true
          
          print("Show was deleted, show title: \(savedFavorite.title), show ID: \(savedFavorite.id), savedShowArray total: \(savedFavoriteArray.count)")
          
        } else {
          
          if savedFavoriteArray.count < 8 {
            
            //save to backendless
            BackendlessUserFunctions.sharedInstance.saveFavoriteToBackendless(TvShowInfo(poster: savedFavorite.poster, title: savedFavorite.title, id: savedFavorite.id), rep: {( entity : AnyObject!) -> () in
              
              //info originally in original function's 'rep' closure, use it to get 'objectid' so can be used to save to local array
              let favShow = entity as! BackendlessUserFunctions.FavoritesShowInfo
              self.savedFavorite.objectID = favShow.objectId
              savedFavoriteArray.append(self.savedFavorite)
              sender.enabled = true
              self.favoritesToolBarButton.enabled = true
              
              //set the ui - checked
              sender.setImage(UIImage(named: "save_icon_greenCheck"), forState: UIControlState.Normal)
              
              print("Show was saved: \(favShow.objectId!), show title: \(favShow.title), show ID: \(favShow.showID!), savedShowArray total: \(savedFavoriteArray.count)")
              
              }, err: { ( fault : Fault!) -> () in
                print("Comment failed to save: \(fault)")
              }
            )
          } else {
            sender.setImage(UIImage(named: "save_icon_white"), forState: UIControlState.Normal)
            JSSAlertView().show(
              self,
              title: NSLocalizedString("Whoops?", comment: ""),
              text: NSLocalizedString( "You've reached the maximum amount of shows that can be saved.", comment: ""),
              buttonText: "Ok",
              iconImage: myShowGuideLogo)
            favoritesToolBarButton.enabled = true
          }
        }
        
      } else {
        
        savedFavorite = showArray[indexPath.row]
        
        //user unchecks favorite circle
        if isShowAlreadyFavorite(savedFavorite) == true  {
          
          
          //remove from backendless
          BackendlessUserFunctions.sharedInstance.removeByShowID(savedFavorite)
          
          //remove from local array (savedFavoriteArray)by syncronizing to itself after the object has been removed
          savedFavoriteArray = savedFavoriteArray.filter({$0.id != savedFavorite.id})
          
          //set the ui- unchecked
          sender.setImage(UIImage(named: "save_icon_white"), forState: UIControlState.Normal)
          sender.enabled = true
          favoritesToolBarButton.enabled = true
          
          print("Show was deleted, show title: \(savedFavorite.title), show ID: \(savedFavorite.id), savedShowArray total: \(savedFavoriteArray.count)")
          
        } else {
          
          if savedFavoriteArray.count < 8 {
            //save to backendless
            BackendlessUserFunctions.sharedInstance.saveFavoriteToBackendless(TvShowInfo(poster: savedFavorite.poster, title: savedFavorite.title, id: savedFavorite.id), rep: {( entity : AnyObject!) -> () in
              
              //info originally in original function's 'rep' closure, use it to get 'objectid' so can be used to save to local array
              let favShow = entity as! BackendlessUserFunctions.FavoritesShowInfo
              self.savedFavorite.objectID = favShow.objectId
              savedFavoriteArray.append(self.savedFavorite)
              
              //set the ui - checked
              sender.setImage(UIImage(named: "save_icon_greenCheck"), forState: UIControlState.Normal)
              sender.enabled = true
              self.favoritesToolBarButton.enabled = true
              
              print("Show was saved: \(favShow.objectId!), show title: \(favShow.title), show ID: \(favShow.showID!), savedShowArray total: \(savedFavoriteArray.count)")
              
              }, err: { ( fault : Fault!) -> () in
                print("Comment failed to save: \(fault)")
              }
            )
          } else {
            sender.setImage(UIImage(named: "save_icon_white"), forState: UIControlState.Normal)
            JSSAlertView().show(
              self,
              title: NSLocalizedString("Whoops?", comment: ""),
              text: NSLocalizedString( "You've reached the maximum amount of shows that can be saved.", comment: ""),
              buttonText: "Ok",
              iconImage: myShowGuideLogo)
            favoritesToolBarButton.enabled = true
          }
        }
      }
    } else {
      let alertView = JSSAlertView().show(
        self,
        title: NSLocalizedString("Whoops?", comment: ""),
        text: NSLocalizedString( "Must sign up for an account to save favorite shows.", comment: ""),
        buttonText: "Ok",
        iconImage: myShowGuideLogo)
      alertView.addAction(self.alertSignUpAction)
      
      sender.setImage(UIImage(named: "save_icon_white"), forState: UIControlState.Normal)
    }
  }
  
}


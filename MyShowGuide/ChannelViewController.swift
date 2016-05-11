//
//  ChannelViewController.swift
//  GuideBoxGuide3.0
//
//  Created by Justin Doo on 3/5/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

import Foundation
import UIKit


class ChannelViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
  
  var channelArray: [ChannelInfo] = []
  var filteredSearchResults = [ChannelInfo]()
  var logosShown = [Bool](count: 50, repeatedValue: false)
  var detailUrl: String?
  var apiKey = "rKk09BXyG0kXF1lnde9GOltFq6FfvNQd"
  var channel: String!
  var channelForShow: String!
  var task: NSURLSessionTask?
  var searchBarActive:Bool = false
  var spinnerActive = false
  
  
  @IBOutlet var channelCollectionView: UICollectionView!
  @IBOutlet weak var channelSearchBar: UISearchBar!
  
  override func viewDidLoad() {
    
    let baseURL = "http://api-public.guidebox.com/v1.43/us/\(apiKey)/channels/all/0/50"
    getJSON(baseURL)
    channelSearchBar.delegate = self
    self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    SwiftSpinner.show(NSLocalizedString("Retrieving your channels..", comment: ""))
    spinnerActive = true
    
    
    if BackendlessUserFunctions.sharedInstance.isValidUser() {
    
    savedFavoriteArray = []

    //Retrieve already saved favorite shows from Backendless
    BackendlessUserFunctions.sharedInstance.retrieveFavoriteFromBackendless({ ( favoriteShows : BackendlessCollection!) -> () in
      
      print("FavoritesShowInfo have been fetched:")
      
      for favoriteShow in favoriteShows.data {
        
        let currentShow = favoriteShow as! BackendlessUserFunctions.FavoritesShowInfo
        
        print("title = \(currentShow.title), objectID = \(currentShow.objectId!)")
        
        //saves data retrieved from backendless to local array
        savedFavoriteArray.append(TvShowInfo(poster: currentShow.poster!, title: currentShow.title!, id: currentShow.showID!, objectID: currentShow.objectId!))
        
        print("Amount of shows in array = \(savedFavoriteArray.count)")
      }
      
      }
      , err: { ( fault : Fault!) -> () in
        print("FavoritesShowInfo were not fetched: \(fault)")
      }
    )
    } else {
      self.performSegueWithIdentifier("channelToLoginSegue", sender: self)
      SwiftSpinner.hide()
      spinnerActive = false
    }
  }
  
  //MARK: CollectionView
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    if self.searchBarActive
    {
      return filteredSearchResults.count
    } else {
      return channelArray.count
    }
  }
  
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ChannelCell", forIndexPath: indexPath) as! ChannelCell
    let channel: String
    if self.searchBarActive {
      channel = self.filteredSearchResults[indexPath.item].logo
    } else {
      channel = self.channelArray[indexPath.item].logo
    }
    cell.channelImageView.sd_setImageWithURL(NSURL(string: channel))
    SwiftSpinner.hide()
    spinnerActive = false
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    var replacedTitle: String?
    if self.searchBarActive {
      
      channelForShow = filteredSearchResults[indexPath.item].channelName
      switch channelForShow {
      case "Disney XD":replacedTitle = "disneyxd"; channelForShow = replacedTitle
      case "A&E":replacedTitle = "ae"; channelForShow = replacedTitle
      case "Disney Junior":replacedTitle = "disneyjunior"; channelForShow = replacedTitle
      case "CW Seed":replacedTitle = "cwseed"; channelForShow = replacedTitle
      default : break
      }
    } else {
      channelForShow = self.channelArray[indexPath.item].channelName
      switch channelForShow {
      case "Disney XD":replacedTitle = "disneyxd"; channelForShow = replacedTitle
      case "A&E":replacedTitle = "ae"; channelForShow = replacedTitle
      case "Disney Junior":replacedTitle = "disneyjunior"; channelForShow = replacedTitle
      case "CW Seed":replacedTitle = "cwseed"; channelForShow = replacedTitle
      default : break
      }
    }
    performSegueWithIdentifier("channelToShowSegue", sender: self)
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
          let logo = data["artwork_608x342"] as? String
          let channelName = data["name"] as? String
          let id = data["id"] as? NSNumber
          let info = ChannelInfo(logo: logo!, channelName: channelName!, id: id!)
          channelArray.append(info)
          self.logosShown = [Bool](count: channelArray.count, repeatedValue: false)
        }
      }
    } catch {
      showNetworkError()
    }
    channelCollectionView.reloadData()
  }
  
  // MARK: Animation
  
  func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
    if logosShown[indexPath.item] == false {
      cell.alpha = 0
      UIView.animateWithDuration(0.5, animations: { () -> Void in
        cell.alpha = 1
      })
      logosShown[indexPath.item] = true
    }
  }
  
  
  //MARK: Search
  
  func filterContentForSearchText(searchText:String){
    self.filteredSearchResults.removeAll(keepCapacity: false)
    let searchPredicate = NSPredicate(format: "channelName CONTAINS [c] %@", searchText)
    let array = (self.channelArray as NSArray).filteredArrayUsingPredicate(searchPredicate)
    self.filteredSearchResults = array as! [ChannelInfo]
  }
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    // user did type something, check our datasource for text that looks the same
    if searchText.characters.count > 0 {
      // search and reload data source
      self.searchBarActive    = true
      self.filterContentForSearchText(searchText)
      self.channelCollectionView.reloadData()
    }else{
      // if text lenght == 0
      // we will consider the searchbar is not active
      self.searchBarActive = false
      self.channelCollectionView?.reloadData()
    }
  }
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    self .cancelSearching()
    self.channelCollectionView?.reloadData()
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    self.searchBarActive = true
    self.view.endEditing(true)
  }
  
  func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    // we used here to set self.searchBarActive = YES
    // but we'll not do that any more... it made problems
    // it's better to set self.searchBarActive = YES when user typed something
    self.channelSearchBar!.setShowsCancelButton(true, animated: true)
  }
  
  func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    // this method is being called when search btn in the keyboard tapped
    // we set searchBarActive = NO
    // but no need to reloadCollectionView
    self.searchBarActive = false
    self.channelSearchBar!.setShowsCancelButton(false, animated: false)
  }
  func cancelSearching(){
    self.searchBarActive = false
    self.channelSearchBar!.resignFirstResponder()
    self.channelSearchBar!.text = ""
  }
  
  
  //MARK: Segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "channelToShowSegue"{
      let showVC = segue.destinationViewController as! ShowViewController
      showVC.showType = channelForShow.lowercaseString
    }
  }
  
  //MARK: Network Error Indicator
  
  func showNetworkError () {
    let alertController = UIAlertController(title: NSLocalizedString("Whoops?", comment: ""), message: NSLocalizedString("There was a connection error. Please restart app.", comment: ""), preferredStyle: .Alert)
    
    //causes app to exit and return to the home screen
    let action = UIAlertAction(title: "OK", style: .Default, handler: {_ in exit(0)})
    alertController.addAction(action)
    
    if self.presentedViewController == nil {
      self.presentViewController(alertController, animated: true, completion: nil)
    }
  }
  
}


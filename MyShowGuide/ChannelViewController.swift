//
//  ChannelViewController.swift
//  GuideBoxGuide3.0
//
//  Created by Justin Doo on 3/5/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

import Foundation
import UIKit
import JSSAlertView


class ChannelViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
  
  var channelArray: [ChannelInfo] = []
  var filteredSearchResults = [ChannelInfo]()
  var logosShown = [Bool](repeating: false, count: 50)
  var detailUrl: String?
  var apiKey = "rKk09BXyG0kXF1lnde9GOltFq6FfvNQd"
  var channel: String!
  var channelForShow: String!
  var task: URLSessionTask?
  var searchBarActive:Bool = false
  var spinnerActive = false
  
  
  @IBOutlet var channelCollectionView: UICollectionView!
  @IBOutlet weak var channelSearchBar: UISearchBar!
  
  override func viewDidLoad() {
    
    let baseURL = "http://api-public.guidebox.com/v1.43/us/\(apiKey)/channels/all/0/50"
    getJSON(baseURL)
    channelSearchBar.delegate = self
    self.navigationController!.navigationBar.tintColor = UIColor.white
    SwiftSpinner.show(NSLocalizedString("Retrieving your channels..", comment: ""))
    spinnerActive = true
    
    
//    if BackendlessUserFunctions.sharedInstance.isValidUser() {
//    
//    savedFavoriteArray = []

    //Retrieve already saved favorite shows from Backendless
//    BackendlessUserFunctions.sharedInstance.retrieveFavoriteFromBackendless({ ( favoriteShows : BackendlessCollection!) -> () in
//      
//      print("FavoritesShowInfo have been fetched:")
//      
//      for favoriteShow in favoriteShows.data {
//        
//        let currentShow = favoriteShow as! BackendlessUserFunctions.FavoritesShowInfo
//        
//        print("title = \(currentShow.title), objectID = \(currentShow.objectId!)")
//        
//        //saves data retrieved from backendless to local array
//        savedFavoriteArray.append(TvShowInfo(poster: currentShow.poster!, title: currentShow.title!, id: currentShow.showID!, objectID: currentShow.objectId!))
//        
//        print("Amount of shows in array = \(savedFavoriteArray.count)")
//      }
//      
//      }
//      , err: { ( fault : Fault!) -> () in
//        print("FavoritesShowInfo were not fetched: \(fault)")
//      }
//    )
//    } else {
      self.performSegue(withIdentifier: "channelToLoginSegue", sender: self)
      SwiftSpinner.hide()
      spinnerActive = false
   // }
  }
  
  //MARK: CollectionView
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    if self.searchBarActive
    {
      return filteredSearchResults.count
    } else {
      return channelArray.count
    }
  }
  
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChannelCell", for: indexPath) as! ChannelCell
    let channel: String
    if self.searchBarActive {
      channel = self.filteredSearchResults[indexPath.item].logo
    } else {
      channel = self.channelArray[indexPath.item].logo
    }
    cell.channelImageView.sd_setImage(with: URL(string: channel))
    SwiftSpinner.hide()
    spinnerActive = false
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
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
    performSegue(withIdentifier: "channelToShowSegue", sender: self)
  }
  
  
  //MARK: JSON Parsing
  
  func getJSON (_ urlString: String) {
    
    let url = URL(string: urlString)!
    let urlConfig = URLSessionConfiguration.default
    urlConfig.timeoutIntervalForRequest = 7
    urlConfig.timeoutIntervalForResource = 7
    let session = URLSession(configuration: urlConfig)
    task = session.dataTask(with: url, completionHandler: {(data, response, error) in
      DispatchQueue.main.async {
        if (error == nil) {
          self.updateJSON(data)
        }
        else {
          SwiftSpinner.hide()
          self.spinnerActive = false
          let alertAction = JSSAlertView().show(
            self,
            title: NSLocalizedString("Whoops?", comment: ""),
            text: NSLocalizedString("There was a connection error. Please restart app.", comment: ""),
            buttonText: "Ok",
            iconImage: myShowGuideLogo)
          alertAction.addAction(self.exitOutOfApp)
        }
      }
    }) 
    task!.resume()
  }
  
  
  func updateJSON (_ data: Data!) {
    do {
      let showData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as!
      NSDictionary
      
      let results = showData["results"] as! [NSDictionary]?
      if let showDataArray = results {
        for data in showDataArray {
          let logo = data["artwork_608x342"] as? String
          let channelName = data["name"] as? String
          let id = data["id"] as? NSNumber
          let info = ChannelInfo(logo: logo!, channelName: channelName!, id: id!)
          channelArray.append(info)
          self.logosShown = [Bool](repeating: false, count: channelArray.count)
        }
      }
    } catch {
      let alertAction = JSSAlertView().show(
        self,
        title: NSLocalizedString("Whoops?", comment: ""),
        text: NSLocalizedString("There was a connection error. Please restart app.", comment: ""),
        buttonText: "Ok",
        iconImage: myShowGuideLogo)
      alertAction.addAction(self.exitOutOfApp)

    }
    channelCollectionView.reloadData()
  }
  
  // MARK: Animation
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if logosShown[indexPath.item] == false {
      cell.alpha = 0
      UIView.animate(withDuration: 0.5, animations: { () -> Void in
        cell.alpha = 1
      })
      logosShown[indexPath.item] = true
    }
  }
  
  
  //MARK: Search
  
  func filterContentForSearchText(_ searchText:String){
    self.filteredSearchResults.removeAll(keepingCapacity: false)
    let searchPredicate = NSPredicate(format: "channelName CONTAINS [c] %@", searchText)
    let array = (self.channelArray as NSArray).filtered(using: searchPredicate)
    self.filteredSearchResults = array as! [ChannelInfo]
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
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
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    self .cancelSearching()
    self.channelCollectionView?.reloadData()
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    self.searchBarActive = true
    self.view.endEditing(true)
  }
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    // we used here to set self.searchBarActive = YES
    // but we'll not do that any more... it made problems
    // it's better to set self.searchBarActive = YES when user typed something
    self.channelSearchBar!.setShowsCancelButton(true, animated: true)
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
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
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "channelToShowSegue"{
      let showVC = segue.destination as! ShowViewController
      showVC.showType = channelForShow.lowercased()
    }
  }
  
  //MARK: Network Error Indicator
  func exitOutOfApp () {
    exit(0)
  }
}


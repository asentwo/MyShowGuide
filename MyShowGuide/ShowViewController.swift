//
//  ViewController.swift
//  MyShowGuide
//
//  Created by Justin Doo on 10/14/15.
//  Copyright © 2015 Justin Doo. All rights reserved.
//
import UIKit
import JSSAlertView

class ShowViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
  
  //MARK: Constants/ IBOutlets
  
  var showArray:[TvShowInfo] = []
  var postersShown = [Bool](repeating: false, count: 50)
  var detailUrl: String?
  let apiKey = "rKk09BXyG0kXF1lnde9GOltFq6FfvNQd"
  var showType: String!
  var showForDetail: NSNumber?
  var task: URLSessionTask?
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
    
    let showNoSpaces = showType.replacingOccurrences(of: " ", with: "_")
    let baseURL = "http://api-public.guidebox.com/v1.43/us/\(apiKey)/shows/\(showNoSpaces)/0/25/all/all"
    getJSON(baseURL)
    tableViewAttributes()
    self.navigationController!.navigationBar.tintColor = UIColor.white
    showSearchBar.delegate = self
    SwiftSpinner.show(NSLocalizedString("Retrieving your shows...", comment: "Loading Message"))
    spinnerActive = true
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    
    //reloads so checkmarks dissapear when removed from favorites
    self.tvShowTableView.reloadData()
    
  }
  
  
  
  
  //MARK: TableView
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TvShowCell", for: indexPath) as! TvShowCell
    cell.MainTitleLabel.adjustsFontSizeToFitWidth = true
    
    if self.searchBarActive {
      cell.MainTitleLabel.text = filteredShowSearchResults[indexPath.row].title
      cell.MainPosterImage.sd_setImage(with: URL(string: filteredShowSearchResults[indexPath.row].poster))
      savedFavorite = filteredShowSearchResults[indexPath.row]
    }else {
      cell.MainTitleLabel.text = showArray[indexPath.row].title
      cell.MainPosterImage.sd_setImage(with: URL(string: showArray[indexPath.row].poster))
      savedFavorite = showArray[indexPath.row]
    }
    
    //checking to see if show is favorite in local savedFavorites array
    if isShowAlreadyFavorite(savedFavorite) == true {
      cell.saveButton.setImage(UIImage(named: "save_icon_greenCheck"), for: UIControlState())
      SwiftSpinner.hide()
      spinnerActive = false
    } else {
      cell.saveButton.setImage(UIImage(named: "save_icon_white"), for: UIControlState())
      SwiftSpinner.hide()
      spinnerActive = false
    }
    
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
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
    tvShowTableView.separatorStyle = UITableViewCellSeparatorStyle.none
    tvShowTableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
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
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if searchBarActive {
      showForDetail = filteredShowSearchResults[indexPath.row].id
    } else {
      showForDetail = showArray[indexPath.row].id
    }
    performSegue(withIdentifier: "showToDetailSegue", sender: self)
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
          self.showSearchBar.isHidden = true
          self.favoritesToolBarButton.isEnabled = false
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
  
  func updateJSON (_ data: Data!) {
    do {
      let showData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as!
      NSDictionary
      
      let results = showData["results"] as! [NSDictionary]?
      if let showDataArray = results {
        for data in showDataArray {
          let title = data["title"] as! String
          let poster = data["artwork_608x342"] as! String
          let id = data["id"] as! NSNumber
          
          let info = TvShowInfo(poster: poster, title: title, id: id)
          showArray.append(info)
          self.postersShown = [Bool](repeating: false, count: showArray.count)
        }
      }
    } catch {
      self.showSearchBar.isHidden = true
      self.favoritesToolBarButton.isEnabled = false
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
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let offsetY =  tvShowTableView.contentOffset.y
    for cell in  tvShowTableView.visibleCells as! [TvShowCell] {
      let x = cell.MainPosterImage.frame.origin.x
      let w = cell.MainPosterImage.bounds.width
      let h = cell.MainPosterImage.bounds.height
      let y = ((offsetY - cell.frame.origin.y) / h) * 15
      cell.MainPosterImage.frame = CGRect(x: x, y: y, width: w, height: h)
      cell.contentMode = UIViewContentMode.scaleAspectFill
    }
  }
  
  // MARK: Animation
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    if postersShown[indexPath.row] == false {
      cell.alpha = 0
      //cells intitial value transparent
      UIView.animate(withDuration: 0.5, animations: { () -> Void in
        cell.alpha = 1
        //cells back from transparency
      })
      postersShown[indexPath.row] = true
      // marks all posters that have already animated in to true to they won't animate again
    }
  }
  
  //MARK: Searchbar
  
  func filterContentForSearchText(_ searchText: String){
    self.filteredShowSearchResults.removeAll(keepingCapacity: false)
    let searchPredicate = NSPredicate(format: "title CONTAINS [c] %@", searchText)
    let array = (self.showArray as NSArray).filtered(using: searchPredicate)
    self.filteredShowSearchResults = array as! [TvShowInfo]
    
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.characters.count > 0 {
      
      self.searchBarActive = true
      self.filterContentForSearchText(searchText)
      self.tvShowTableView.reloadData()
    } else {
      self.searchBarActive = false
      self.tvShowTableView.reloadData()
      
    }
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    self.navigationItem.setHidesBackButton(false, animated: true)
    self.cancelSearching()
    self.tvShowTableView.reloadData()
  }
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    self.showSearchBar!.setShowsCancelButton(true, animated: true)
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    self.searchBarActive = false
    self.showSearchBar!.setShowsCancelButton(true, animated: true)
  }
  
  func cancelSearching() {
    self.searchBarActive = false
    self.showSearchBar!.resignFirstResponder()
    self.showSearchBar!.text = ""
  }
  
  //MARK: PrepareForSegue
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showToDetailSegue"
    {
      let detailViewController = segue.destination as! DetailTvTableViewController
      detailViewController.showToDetailSite = self.showForDetail!
    }
    
  }
  
  //MARK: AlertViews
  
  func alertSignUpAction () {
    self.performSegue(withIdentifier: "favToLogin", sender: self)
    
  }
  
  func errorGoToPreviousScreen () {
    self.navigationController?.popViewController(animated: true)
  }


  @IBAction func FavoritesButton(_ sender: AnyObject) {
    
//    if BackendlessUserFunctions.sharedInstance.isValidUser() {
//      performSegue(withIdentifier: "showToFavoritesSegue", sender: self)
//    } else {
//      
//      let alertView = JSSAlertView().show(
//        self,
//        title: NSLocalizedString("Whoops?", comment: ""),
//        text: NSLocalizedString( "Must sign up for an account to save favorite shows.", comment: ""),
//        buttonText: "Ok",
//        iconImage: myShowGuideLogo)
//      alertView.addAction(self.alertSignUpAction)
//    }
  }
  
  
  //MARK: Show Favorite Check
  
  func isShowAlreadyFavorite(_ favShow: TvShowInfo) -> Bool {
    
    //find the show by id.
    let showsThatMatchIdArray = savedFavoriteArray.filter({$0.id == favShow.id})
    
    //'filter' doesn't return a bool so must use 'isEmpty' to return a bool
    if showsThatMatchIdArray.isEmpty {
      
      return false
    } else {
      return true
    }
  }
  
  
  @IBAction func saveShow(_ sender: UIButton) {
    
//    if BackendlessUserFunctions.sharedInstance.isValidUser() {
//      
//      print("\(savedFavoriteArray.count)")
//      sender.isEnabled = false
//      favoritesToolBarButton.isEnabled = false
//      
//      //accessing current point of tableView Cell
//      let location: CGPoint = sender.convert(CGPoint.zero, to: self.tvShowTableView)
//      let indexPath: IndexPath = self.tvShowTableView.indexPathForRow(at: location)!
//      
//      if searchBarActive {
//        
//        savedFavorite = filteredShowSearchResults[indexPath.row]
//        
//        //user unchecks favorite circle
//        if isShowAlreadyFavorite(savedFavorite) == true {
//          
//          //remove from backendless
//          BackendlessUserFunctions.sharedInstance.removeFavoriteFromBackendless(savedFavorite.objectID!)
//          
//          //remove from local array (savedFavoriteArray)by syncronizing to itself after the object has been removed
//          savedFavoriteArray = savedFavoriteArray.filter({$0.id != savedFavorite.id})
//          
//          //set the ui- unchecked
//          sender.setImage(UIImage(named: "save_icon_white"), for: UIControlState())
//          sender.isEnabled = true
//          favoritesToolBarButton.isEnabled = true
//          
//          print("Show was deleted, show title: \(savedFavorite.title), show ID: \(savedFavorite.id), savedShowArray total: \(savedFavoriteArray.count)")
//          
//        } else {
//        
//          // Save if search bar is active
//          
//          if savedFavoriteArray.count < 8 {
//            
//            //save to backendless
//            BackendlessUserFunctions.sharedInstance.saveFavoriteToBackendless(TvShowInfo(poster: savedFavorite.poster, title: savedFavorite.title, id: savedFavorite.id), rep: {( entity : AnyObject!) -> () in
//              
//              //info originally in original function's 'rep' closure, use it to get 'objectid' so can be used to save to local array
//              let favShow = entity as! BackendlessUserFunctions.FavoritesShowInfo
//              self.savedFavorite.objectID = favShow.objectId
//              savedFavoriteArray.append(self.savedFavorite)
//              sender.isEnabled = true
//              self.favoritesToolBarButton.isEnabled = true
//              
//              //set the ui - checked
//              sender.setImage(UIImage(named: "save_icon_greenCheck"), for: UIControlState())
//              
//              print("Show was saved: \(favShow.objectId!), show title: \(favShow.title), show ID: \(favShow.showID!), savedShowArray total: \(savedFavoriteArray.count)")
//              
//              }, err: { ( fault : Fault!) -> () in
//                print("Comment failed to save: \(fault)")
//              }
//            )
//          } else {
//            sender.setImage(UIImage(named: "save_icon_white"), for: UIControlState())
//            JSSAlertView().show(
//              self,
//              title: NSLocalizedString("Whoops?", comment: ""),
//              text: NSLocalizedString( "You've reached the maximum amount of shows that can be saved.", comment: ""),
//              buttonText: "Ok",
//              iconImage: myShowGuideLogo)
//            favoritesToolBarButton.isEnabled = true
//          }
//        }
//      
//      } else {
//
//        
//        //Remove from favorites (unchecks cell)
//        
//        savedFavorite = showArray[indexPath.row]
//        
//        //user unchecks favorite circle
//        if isShowAlreadyFavorite(savedFavorite) == true  {
//          
//          
//          //remove from backendless
//          BackendlessUserFunctions.sharedInstance.removeByShowID(savedFavorite)
//          
//          //remove from local array (savedFavoriteArray)by syncronizing to itself after the object has been removed
//          savedFavoriteArray = savedFavoriteArray.filter({$0.id != savedFavorite.id})
//          
//          //set the ui- unchecked
//          sender.setImage(UIImage(named: "save_icon_white"), for: UIControlState())
//          sender.isEnabled = true
//          favoritesToolBarButton.isEnabled = true
//          
//          print("Show was deleted, show title: \(savedFavorite.title), show ID: \(savedFavorite.id), savedShowArray total: \(savedFavoriteArray.count)")
//          
//        } else {
// 
//       //MARK: Save to favorites
//          
//          if savedFavoriteArray.count < 8 {
//            //save to backendless
//            BackendlessUserFunctions.sharedInstance.saveFavoriteToBackendless(TvShowInfo(poster: savedFavorite.poster, title: savedFavorite.title, id: savedFavorite.id), rep: {( entity : AnyObject!) -> () in
//              
//              //info originally in original function's 'rep' closure, use it to get 'objectid' so can be used to save to local array
//              let favShow = entity as! BackendlessUserFunctions.FavoritesShowInfo
//              self.savedFavorite.objectID = favShow.objectId
//              savedFavoriteArray.append(self.savedFavorite)
//              
//              //set the ui - checked
//              sender.setImage(UIImage(named: "save_icon_greenCheck"), for: UIControlState())
//              sender.isEnabled = true
//              self.favoritesToolBarButton.isEnabled = true
//              
//              print("Show was saved: \(favShow.objectId!), show title: \(favShow.title), show ID: \(favShow.showID!), savedShowArray total: \(savedFavoriteArray.count)")
//              
//              }, err: { ( fault : Fault!) -> () in
//                print("Comment failed to save: \(fault)")
//              }
//            )
//          } else {
//            sender.setImage(UIImage(named: "save_icon_white"), for: UIControlState())
//            JSSAlertView().show(
//              self,
//              title: NSLocalizedString("Whoops?", comment: ""),
//              text: NSLocalizedString( "You've reached the maximum amount of shows that can be saved.", comment: ""),
//              buttonText: "Ok",
//              iconImage: myShowGuideLogo)
//            favoritesToolBarButton.isEnabled = true
//          }
//        }
//      }
//    } else {
//      let alertView = JSSAlertView().show(
//        self,
//        title: NSLocalizedString("Whoops?", comment: ""),
//        text: NSLocalizedString( "Must sign up for an account to save favorite shows.", comment: ""),
//        buttonText: "Ok",
//        iconImage: myShowGuideLogo)
//      alertView.addAction(self.alertSignUpAction)
//      
//      sender.setImage(UIImage(named: "save_icon_white"), for: UIControlState())
//    }
    }
}


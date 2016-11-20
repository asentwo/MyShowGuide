//
//  FavoritesViewController.swift
//  GuideBoxGuide3.0
//
//  Created by Justin Doo on 3/31/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

import Foundation
import UIKit
import JSSAlertView

class FavoritesViewController: UITableViewController {
  
  var postersShown = [Bool](repeating: false, count: 50)
  var favoriteShowsArray: [TvShowInfo] = []
  var showForDetail: NSNumber?
  let apiKey = "rKk09BXyG0kXF1lnde9GOltFq6FfvNQd"
  var task: URLSessionTask?
  var spinnerActive = false
  var showToRemove: TvShowInfo?
  let tvViewController = ShowViewController()
  
  @IBOutlet var favoritesTableView: UITableView!
  
  override func viewDidLoad() {
    SwiftSpinner.show(NSLocalizedString("Retrieving your show info...", comment: ""))
    spinnerActive = true
    retrieveSavedShows()
    tableViewAttributes()
    self.navigationController!.navigationBar.tintColor = UIColor.white
  }
  
    //MARK: TableView
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TvShowCell", for: indexPath) as! TvShowCell
    
    cell.MainTitleLabel.text = favoriteShowsArray[indexPath.row].title
    cell.MainPosterImage.sd_setImage(with: URL(string: favoriteShowsArray[indexPath.row].poster))
    
    SwiftSpinner.hide()
    spinnerActive = false
    return cell
  }
  
  
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return favoriteShowsArray.count
    
  }
  
  func tableViewAttributes () {
    favoritesTableView.allowsSelection = true
    favoritesTableView.rowHeight = UITableViewAutomaticDimension
    favoritesTableView.estimatedRowHeight = 220.0
    favoritesTableView.separatorStyle = UITableViewCellSeparatorStyle.none
    favoritesTableView.reloadData()
  }
  
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    showForDetail = favoriteShowsArray[indexPath.row].id
    performSegue(withIdentifier: "favoriteToDetailSegue", sender: self)
  }
  
  
  // MARK: Parallax Effect
  
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let offsetY =  favoritesTableView.contentOffset.y
    for cell in  favoritesTableView.visibleCells as! [TvShowCell] {
      
      let x = cell.MainPosterImage.frame.origin.x
      let w = cell.MainPosterImage.bounds.width
      let h = cell.MainPosterImage.bounds.height
      let y = ((offsetY - cell.frame.origin.y) / h) * 15
      cell.MainPosterImage.frame = CGRect(x: x, y: y, width: w, height: h)
      cell.contentMode = UIViewContentMode.scaleAspectFill
    }
  }
  
  // MARK: Animation
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
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
  
  
  //MARK: Network Error Indicator
  
//  func showNetworkError () {
//    let alert = UIAlertController(title: NSLocalizedString("Whoops?", comment: ""), message: NSLocalizedString("There was a connection error. Please try again.", comment: ""), preferredStyle: .Alert)
//    //goes back to previous view controller
//    let action = UIAlertAction(title: "OK", style: .Default, handler: {_ in self.navigationController?.popViewControllerAnimated(true)})
//    alert.addAction(action)
//    presentViewController(alert, animated: true, completion: nil)
//    
//  }
  
//  func noSavedShowsAlert () {
//    let alert = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("There are no saved shows.", comment: ""), preferredStyle: .Alert)
//    //goes back to previous view controller
//    let action = UIAlertAction(title: "OK", style: .Default, handler: {_ in self.navigationController?.popViewControllerAnimated(true)})
//    alert.addAction(action)
//    presentViewController(alert, animated: true, completion: nil)
//    
//
//    
//  }
  
  //MARK: Retrieve Saved Shows
  
    func retrieveSavedShows() {

     //   let savedShowsArray = UserDefaults.sharedInstance.getSavedShows()
      
      let savedShowsArray = savedFavoriteArray

        if savedShowsArray.count != 0 {
            self.favoriteShowsArray = savedShowsArray
        } else {
            SwiftSpinner.hide()
          JSSAlertView().show(
            self,
            title: NSLocalizedString("Whoops?", comment: ""),
            text: NSLocalizedString("There are no saved shows.", comment: ""),
            buttonText: "Ok",
            iconImage: myShowGuideLogo)

        }
    }
  
  
  //MARK: PrepareForSegue
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "favoriteToDetailSegue"
    {
      let detailViewController = segue.destination as! DetailTvTableViewController
      detailViewController.showToDetailSite = self.showForDetail!
    }
  }
  
  //MARK: IBActions
    
    @IBAction func removeSavedObject(_ sender: AnyObject) {

      //find object based on location of sender(button)
        let location: CGPoint = sender.convert(CGPoint.zero, to: self.favoritesTableView)
        let indexPath: IndexPath = self.favoritesTableView.indexPathForRow(at: location)!
      
      //make local array = universal saved show array
        favoriteShowsArray = savedFavoriteArray
      
      //determine which sho to remove
        showToRemove = favoriteShowsArray[indexPath.row]
      
      // remove show from backendless
    //  BackendlessUserFunctions.sharedInstance.removeFavoriteFromBackendless((showToRemove?.objectID)!)
      
      //filter out show to remove from universal saved show array
        savedFavoriteArray = savedFavoriteArray.filter({$0.id != showToRemove!.id})
      
       print("Show was removed, show title: \(showToRemove!.title), show ID: \(showToRemove!.id)")
      
      // UserDefaults.sharedInstance.removeFavorite(showToRemove!)

        favoriteShowsArray = savedFavoriteArray
      
        favoritesTableView.reloadData()
    }
}


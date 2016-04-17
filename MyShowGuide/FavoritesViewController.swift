//
//  FavoritesViewController.swift
//  GuideBoxGuide3.0
//
//  Created by Justin Doo on 3/31/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

import Foundation
import UIKit

class FavoritesViewController: UITableViewController {
  
  
  let myDefaults = NSUserDefaults.standardUserDefaults()
  let SAVED_SHOWS_KEY = "SAVED_SHOWS_KEY"
  var postersShown = [Bool](count: 50, repeatedValue: false)
  var favoriteShowsArray: [TvShowInfo] = []
  var showForDetail: NSNumber?
  let apiKey = "rKk09BXyG0kXF1lnde9GOltFq6FfvNQd"
  var task: NSURLSessionTask?
  var spinnerActive = false
  var showToRemove: TvShowInfo?
  
  @IBOutlet var favoritesTableView: UITableView!
  
  override func viewDidLoad() {
    SwiftSpinner.show("Retrieving your show info...")
    spinnerActive = true
    retrieveSavedShows()
    tableViewAttributes()
    self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
  }
  
    //MARK: TableView
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("TvShowCell", forIndexPath: indexPath) as! TvShowCell
    
    cell.MainTitleLabel.text = favoriteShowsArray[indexPath.row].title
    cell.MainPosterImage.sd_setImageWithURL(NSURL(string: favoriteShowsArray[indexPath.row].poster))
    
    SwiftSpinner.hide()
    spinnerActive = false
    return cell
  }
  
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return favoriteShowsArray.count
    
  }
  
  func tableViewAttributes () {
    favoritesTableView.allowsSelection = true
    favoritesTableView.rowHeight = UITableViewAutomaticDimension
    favoritesTableView.estimatedRowHeight = 220.0
    favoritesTableView.separatorStyle = UITableViewCellSeparatorStyle.None
    favoritesTableView.reloadData()
  }
  
  
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    showForDetail = favoriteShowsArray[indexPath.row].id
    performSegueWithIdentifier("favoriteToDetailSegue", sender: self)
  }
  
  
  // MARK: Parallax Effect
  
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    let offsetY =  favoritesTableView.contentOffset.y
    for cell in  favoritesTableView.visibleCells as! [TvShowCell] {
      
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
  
  
  //MARK: Network Error Indicator
  
  func showNetworkError () {
    let alert = UIAlertController(title: "Whoops?", message: "There was a connection error. Please try again.", preferredStyle: .Alert)
    //goes back to previous view controller
    let action = UIAlertAction(title: "OK", style: .Default, handler: {_ in self.navigationController?.popViewControllerAnimated(true)})
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
    
  }
  
  func noSavedShowsAlert () {
    let alert = UIAlertController(title: "Sorry", message: "There are no saved shows.", preferredStyle: .Alert)
    //goes back to previous view controller
    let action = UIAlertAction(title: "OK", style: .Default, handler: {_ in self.navigationController?.popViewControllerAnimated(true)})
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
    

    
  }
  
  //MARK: NSUserDefaults
  
  func retrieveSavedShows() {
    
    let searchTermsData = myDefaults.objectForKey(SAVED_SHOWS_KEY) as? NSData
    if searchTermsData != nil {
      let searchTermsArray = NSKeyedUnarchiver.unarchiveObjectWithData(searchTermsData!) as? [TvShowInfo]
      if searchTermsArray!.count != 0 {
        self.favoriteShowsArray = searchTermsArray!
      } else {
        SwiftSpinner.hide()
        self.noSavedShowsAlert()
      }
    }
  }
  
  
    @IBAction func removeSavedObject(sender: AnyObject) {
    let searchTermsData = myDefaults.objectForKey(SAVED_SHOWS_KEY) as? NSData
    let searchTermsArray = NSKeyedUnarchiver.unarchiveObjectWithData(searchTermsData!) as? [TvShowInfo]
     favoriteShowsArray = searchTermsArray!
      let location: CGPoint = sender.convertPoint(CGPointZero, toView: self.favoritesTableView)
      let indexPath: NSIndexPath = self.favoritesTableView.indexPathForRowAtPoint(location)!
      showToRemove = favoriteShowsArray[indexPath.row]
      
      //filter item based on id and remove item from array
      let removedShowArray = favoriteShowsArray.filter({$0.id == showToRemove!.id})
      if removedShowArray.isEmpty {
        print("Show doesn't exist")
      } else {
        favoriteShowsArray = favoriteShowsArray.filter({$0.id != showToRemove!.id})
      }
      let savedData = NSKeyedArchiver.archivedDataWithRootObject(favoriteShowsArray)
      myDefaults.setObject(savedData, forKey: SAVED_SHOWS_KEY)
      myDefaults.synchronize()
      favoritesTableView.reloadData()
    }
  
}


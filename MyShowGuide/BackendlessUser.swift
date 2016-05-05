//
//  BackendlessUser.swift
//  Test
//
//  Created by Justin Doo on 4/21/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

import Foundation

class BackendlessUserFunctions {
  
  static let sharedInstance = BackendlessUserFunctions()
  
  let VERSION_NUM = "v1"
  let APP_ID = "CCD3BDBD-CDC7-C3A6-FF8A-01EAFE4F0A00"
  let SECRET_KEY = "2095409A-25BB-053C-FF6E-6CD3BA068000"
  let backendless = Backendless.sharedInstance()
  
  // A private init prevents others from using the default '()' initializer for this class.
  private init() {
    
    let backendless = Backendless.sharedInstance()
    backendless.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
    // This asks that the user should stay logged in by storing or caching the user's login
    // information so future logins can be skipped next time the user launches the app.
    backendless.userService.setStayLoggedIn(true)
  }
  
  func isValidUser() -> Bool {
    
    let isValidUser = backendless.userService.isValidUserToken()
    
    if(isValidUser != nil && isValidUser != 0) {
      return true
    } else {
      return false
    }
  }
  
  // register user
  func backendlessUserRegister(email:String, password:String, rep: ((user : BackendlessUser!) -> Void), err: (( fault : Fault!) -> Void)) {
    
    if(isValidUser()) {
      print("A user is already logged on, but we're trying to register a new one!");
      return
    }
    
    let user: BackendlessUser = BackendlessUser()
    user.email = email
    user.password = password
    
    
    backendless.userService.registering(user, response: rep, error: err)
  }
  
  
  //user login
  func backendlessUserLogin(email:String, password:String, rep: ((user : BackendlessUser!) -> Void), err: (( fault : Fault!) -> Void)) {
    
    // First, check if the user is already logged in. If they are, we don't need to
    // ask them to login again.
    if(isValidUser()) {
      print("User is already logged!");
      return;
    }
    
    // If we were unable to find a valid user token, the user is not logged and they'll
    // need to login. In a real app, this where we would send the user to a login screen to
    // collect their user name and password for the login attempt.
    
    backendless.userService.login(email, password:password, response: rep, error: err)
    
  }
  
  class FavoritesShowInfo: NSObject {
    
    var objectId: String?
    var showID: NSNumber?
    var poster: String?
    var title: String?
  }
  
  
  func isShowAlreadyFavorite (favID: NSNumber)-> Bool {
    
    if backendless.data.findByObject(favID) != nil{
      print("\(favID), has already been saved in system")
      return true
    } else {
      return false
    }
  }
  
  
  func saveFavoriteToBackendless(showToSave: TvShowInfo) {
    
    let fav = FavoritesShowInfo()
    fav.showID = showToSave.id
    fav.poster = showToSave.poster
    fav.title = showToSave.title
    backendless.data.save(fav,response: { ( entity : AnyObject!) -> () in
      
      let favShow = entity as! FavoritesShowInfo
      
      print("Show was saved: \(favShow.objectId!), show title: \(favShow.title), show ID: \(favShow.showID!)")
      },
                          
      error: { ( fault : Fault!) -> () in
        print("Comment failed to save: \(fault)")
      }
    )
  }
  
  
  func removeFavoriteFromBackendless(showToRemove: TvShowInfo) {
   
    let fav = FavoritesShowInfo()
    fav.showID = showToRemove.id
    fav.poster = showToRemove.poster
    fav.title = showToRemove.title
   
    backendless.data.remove(fav, response: { ( entity : AnyObject!) -> () in
      
      let fav = entity as! FavoritesShowInfo
      
      print("Show was removed: \(fav.objectId!), show title, \(fav.title), show ID: \(fav.showID!)")
      },
                            
      error: { ( fault : Fault!) -> () in
        print("Comment failed to save: \(fault)")
      }
    )
    
  }
  
  func retrieveFavoriteFromBackendless(rep: ((BackendlessCollection!) -> Void), err: ((Fault!) -> Void) ) {
 
    let currentUser = backendless.userService.currentUser
    
    let dataQuery = BackendlessDataQuery()
    
    print("currentUser.objectId = \(currentUser.objectId)")
    
    dataQuery.whereClause = "ownerId = '\(currentUser.objectId)'"
    
    let dataStore = backendless.data.of(FavoritesShowInfo.ofClass())
    
    dataStore.find( dataQuery, response: rep, error: err)
    
  }
  
//  func retrieveFavoriteFromBackendless() -> [TVShowInfo] {
//    
//    let dataStore = self.backendless.persistenceService.of(FavoritesShowInfo.ofClass())
//    
//    dataStore.find(
//      
//      { ( favorites : BackendlessCollection!) -> () in
//        print("Favorites have been fetched:")
//        
//        for favorite in favorites.data {
//          
//          let fav = favorite as! FavoritesShowInfo
//          
//          print("Favorite: \(fav.objectId!), show title, \(fav.title), show ID: \(fav.showID!)")
//        }
//      },
//      
//      error: { ( fault : Fault!) -> () in
//        print("Comments were not fetched: \(fault)")
//      }
//    )
//  }

  }


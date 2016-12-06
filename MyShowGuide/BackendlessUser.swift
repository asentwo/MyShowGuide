//
//  BackendlessUser.swift
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
  fileprivate init() {
    
    let backendless = Backendless.sharedInstance()
    backendless?.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
    
    // This asks that the user should stay logged in by storing or caching the user's login
    // information so future logins can be skipped next time the user launches the app.
    backendless?.userService.setStayLoggedIn(true)
  }
  
  //checks to see if user is logged in to Backendless
  func isValidUser() -> Bool {
    
    let isValidUser = backendless?.userService.isValidUserToken()
    
    if(isValidUser != nil && isValidUser != 0) {
      return true
    } else {
      return false
    }
  }
  
  // register user
  func backendlessUserRegister(_ email:String, password:String, rep: @escaping ((_ user : BackendlessUser?) -> Void), err: @escaping (( _ fault : Fault?) -> Void)) {
    
    if(isValidUser()) {
      print("A user is already logged on, but we're trying to register a new one!");
      return
    }
    
    let user: BackendlessUser = BackendlessUser()
    user.email = email as NSString!
    user.password = password as NSString!
    
    
    backendless?.userService.registering(user, response: rep, error: err)
  }
  
  
  //user login
  func backendlessUserLogin(_ email:String, password:String, rep: @escaping ((_ user : BackendlessUser?) -> Void), err: @escaping (( _ fault : Fault?) -> Void)) {
    
    // First, check if the user is already logged in. If they are, we don't need to
    // ask them to login again.
    if(isValidUser()) {
      print("User is already logged!");
      return;
    }
    
    // If we were unable to find a valid user token, the user is not logged and they'll
    // need to login.
    backendless?.userService.login(email, password:password, response: rep, error: err)
    
  }
  
  class FavoritesShowInfo: NSObject {
    
    var objectId: String?
    var showID: NSNumber?
    var poster: String?
    var title: String?
  }
  
  //save- works
  func saveFavoriteToBackendless(_ showToSave: TvShowInfo, rep: @escaping (_ entity : Any?) -> (Void), err:@escaping ((Fault?) -> Void)) {
    
    let fav = FavoritesShowInfo()
    fav.poster = showToSave.poster
    fav.showID = showToSave.id
    fav.title = showToSave.title
    
    
    if let dataStore = backendless?.data.of(FavoritesShowInfo.ofClass()){
      
      dataStore.save(fav,response: rep, error:  err)
    }
  }
  
  //search backendless by specific column and delete
  func removeByShowID (_ showToRemove: TvShowInfo) {
    
    
    if let dataStore = self.backendless?.data.of(FavoritesShowInfo.ofClass()) {
      
      let dataQuery = BackendlessDataQuery()
      dataQuery.whereClause = "showID = \(showToRemove.id)"
      
      dataStore.find( dataQuery,
                      
                      response: { ( favorites : BackendlessCollection?) -> () in
                        
                        if let backendFavorites = favorites?.data {
                          
                          for favorite in backendFavorites {
                            
                            let favorite = favorite as! FavoritesShowInfo
                            
                            print("FavoritesShowInfo: \(favorite.objectId!)")
                            
                            var error: Fault?
                            let result = dataStore.remove(favorite, fault: &error)
                            if error == nil {
                              print("One FavoritesShowInfo has been removed: \(result)")
                            } else {
                              print("Server reported an error on attempted removal: \(error)")
                            }
                          }
                        }
                        
      },
                      
                      error: { ( fault : Fault?) -> () in
                        print("FavoritesShowInfo were not fetched: \(fault)")
      }
      )
      
    }
  }
  
  
  func removeFavoriteFromBackendless(_ objectID: String) {
    
    if let dataStore = self.backendless?.data.of(FavoritesShowInfo.ofClass()) {
      
      dataStore.removeID(objectID, response: {(num : NSNumber?) -> () in
        
        print("Show was removed: \(objectID)")
        
      },
                         
                         error: { (fault : Fault?) -> () in
                          print("Show failed to be removed: \(fault)")
      }
      )
    }
  }
  
  
  func retrieveFavoriteFromBackendless(_ rep: @escaping ((BackendlessCollection?) -> Void), err: @escaping ((Fault?) -> Void) ) {
    
    let currentUser = backendless?.userService.currentUser
    
    let dataQuery = BackendlessDataQuery()
    
    print("currentUser.objectId = \(currentUser?.objectId)")
    
    dataQuery.whereClause = "ownerId = '\(currentUser?.objectId)'"
    
    if let dataStore = backendless?.data.of(FavoritesShowInfo.ofClass()) {
      
      dataStore.find( dataQuery, response: rep, error: err)
      
    }
  }
}


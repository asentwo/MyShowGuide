//
//  BackendlessUser.swift
//  Test
//
//  Created by Justin Doo on 4/21/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

import Foundation

class BackendlessUserFunctions {
  
  let VERSION_NUM = "v1"
  let APP_ID = "CCD3BDBD-CDC7-C3A6-FF8A-01EAFE4F0A00"
  let SECRET_KEY = "2095409A-25BB-053C-FF6E-6CD3BA068000"
  let backendless = Backendless.sharedInstance()
  
  static let sharedInstance = BackendlessUserFunctions()
  
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
}

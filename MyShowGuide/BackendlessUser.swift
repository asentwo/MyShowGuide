////
////  BackendlessUser.swift
////  Test
////
////  Created by Justin Doo on 4/21/16.
////  Copyright © 2016 Justin Doo. All rights reserved.
////
//
//import Foundation
//
////Must Customize Based on Project!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//class BackendlessUserFunctions {
//  
//  static let sharedInstance = BackendlessUserFunctions()
//  
//  private init() {
//  
//    let backendless = Backendless.sharedInstance()
//    backendless.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
//    // This asks that the user should stay logged in by storing or caching the user's login
//    // information so future logins can be skipped next time the user launches the app.
//    backendless.userService.setStayLoggedIn(true)
//  
//  } //This prevents others from using the default '()' initializer for this class.
//  
//  let VERSION_NUM = "v1"
//  let APP_ID = "8D2FD354-3D1D-CE63-FF2C-2188F2712800"
//  let SECRET_KEY = "FECE275E-BC7E-9618-FFC0-21A4EDC16F00"
//  var USER_NAME: String?
//  var PASSWORD: String?
//  let backendless = Backendless.sharedInstance()
//  
//  // register user
//  func backendlessUserRegister() {
//  let user: BackendlessUser = BackendlessUser()
//  user.email = USER_NAME
//  user.password = PASSWORD
//  
//  backendless.userService.registering( user,
//
//  response: { ( registeredUser : BackendlessUser!) -> () in
//  print("User was registered: \(registeredUser.objectId)")
//    },
//
//  error: { ( fault : Fault!) -> () in
//  print("User failed to register: \(fault)")
//    }
//    )
//  }
//  
//  //user login
//  func backendlessUserLogin() {
//    // First, check if the user is already logged in. If they are, we don't need to
//    // ask them to login again.
//    let isValidUser = backendless.userService.isValidUserToken()
//    
//    if(isValidUser != nil && isValidUser != 0) {
//      
//      // The user has a valid user token so we know for sure the user is already logged!
//      print("User is already logged: \(isValidUser.boolValue)");
//      
//    } else {
//      
//      // If we were unable to find a valid user token, the user is not logged and they'll
//      // need to login. In a real app, this where we would send the user to a login screen to
//      // collect their user name and password for the login attempt.
//      backendless.userService.login( USER_NAME, password:PASSWORD,
//                                     
//        response: { ( user : BackendlessUser!) -> () in
//        print("User logged in: \(user.objectId)")
//        },
//                                     
//        error: { ( fault : Fault!) -> () in
//        print("User failed to login: \(fault)")
//        }
//      )
//    }
//  }
//
//  //example custom class
//  class  custom: NSObject {
//    
//    
//    
//    
//  }
//  
//  //save data
//  func saveDataToBackendless(sender: UIButton, custom: NSObject) {
//    
//    print( "onTouchUpInsideCreateCommentBtn called!" )
//    
//    let comment = custom()// custom class from above
//    comment.message = "Hello, from iOS user!"// custom class instances
//    comment.authorEmail = USER_NAME// custom class instances
//
//    backendless.data.save( comment,
//                           
//     response: { ( entity : AnyObject!) -> () in
//      
//      let comment = entity as! custom
//      
//      print("Data was saved: \(comment.objectId!), message: \(comment.message!)")
//  },
//     
//     error: { ( fault : Fault!) -> () in
//      print("Data failed to save: \(fault)")
//      
//      }
//    )
//  }
//
//  //retrieve data
//  func FetchDataFromBackendless(sender: UIButton, custom: NSObject//custom class from above
//    ) {
//    
//    print( "Data is being fetched!" )
//    
//    let dataStore = self.backendless.persistenceService.of(enitity.ofClass())
//    
//    dataStore.find(
//      
//      { ( comments : BackendlessCollection!) -> () in
//        print("Data has been fetched:")
//        
//        for comment in comments.data {
//          
//          let comment = comment as! custom //custom class from above
//          
//         // print("Comment: \(comment.objectId!), message: \(comment.message!)")
//        }
//      },
//      
//      error: { ( fault : Fault!) -> () in
//        print("Data was not fetched: \(fault)")
//      }
//    )
//  }
//  
//  //retrieve data based on a specific parameter(column) - example age used
//  func findDataByParameter(column: String, parameter:String) {
//    
//    let whereClause = "\(column) = \(parameter)"
//    let dataQuery = BackendlessDataQuery()
//    dataQuery.whereClause = whereClause
//    
//    var error: Fault?                               //Contact is custom class
//    let bc = Backendless.sharedInstance().data.of(Contact.ofClass()).find(dataQuery, fault: &error)
//    if error == nil {
//      print("Contacts have been found: \(bc.data)")
//    }
//    else {
//      print("Server reported an error: \(error)")
//    }
//  }
//  
//}

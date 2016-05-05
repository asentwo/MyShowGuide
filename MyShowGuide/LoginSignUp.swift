//
//  LoginSignUp.swift
//  MyShowGuide
//
//  Created by Justin Doo on 5/2/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

import Foundation
import UIKit

class LoginSignUp: UIViewController {
  
  
  //MARK: IBOutlets
  
  @IBOutlet weak var welcomeLabel: UILabel!
  @IBOutlet weak var signInLabel: UILabel!
  
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var passwordLabel: UILabel!
  
  @IBOutlet weak var userNameSignIn: UITextField!
  @IBOutlet weak var passwordSignIn: UITextField!
  
  @IBOutlet weak var orLabel: UILabel!
  
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var signUpButton: UIButton!
  @IBOutlet weak var cancelButton: UIButton!
  
  @IBOutlet weak var tvLogo: UIImageView!
  
  //MARK: ViewDidLoad
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    adjustFontSize()
  }
  
  override func viewWillAppear(animated: Bool) {
      }
  
  
  func adjustFontSize () {
    
    welcomeLabel.adjustsFontSizeToFitWidth = true
    signInLabel.adjustsFontSizeToFitWidth = true
    userNameLabel.adjustsFontSizeToFitWidth = true
    passwordLabel.adjustsFontSizeToFitWidth = true
    orLabel.adjustsFontSizeToFitWidth = true
    loginButton.titleLabel?.adjustsFontSizeToFitWidth = true
    signUpButton.titleLabel?.adjustsFontSizeToFitWidth = true
    cancelButton.titleLabel?.adjustsFontSizeToFitWidth = true
  }
  
  
  func showNetworkError (message: String) {
    let alert = UIAlertController(title: "Whoops?", message: message, preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Default, handler: {_ in self.navigationController?.popViewControllerAnimated(true)})
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
    
  }

  
  //MARK: IBActions
  
  @IBAction func loginInButtonPressed(sender: AnyObject) {
                                                          //userNameSignIn = user's email
    BackendlessUserFunctions.sharedInstance.backendlessUserLogin(userNameSignIn.text!, password: passwordSignIn.text!, rep: { ( user : BackendlessUser!) -> () in
      
      self.performSegueWithIdentifier("loginToChannelSegue", sender: self)
      print("User logged in: \(user.objectId)")
      
      }, err: { ( fault : Fault!) -> () in
        var errorStatement: String!
        
        switch fault.faultCode {
         
        case "3003": errorStatement = "Account not found, please register"//User Failed to login
        case "3040": errorStatement = "The email address is in the wrong format"
        case "3002": errorStatement = "User is already logged in from another device"
        case "3000": errorStatement = "User cannot be logged in"
        case "3006": errorStatement = "Login or password is missing"
        case "3011": errorStatement = "Password is required"
        case "3028": errorStatement = "User is already logged in"
        case "3033": errorStatement = "Unable to register user, user already exists"
        case "3036": errorStatement = "Unable to login, user is locked out due to too many failed login attempts"
        case "3045": errorStatement = "Unable to update user, required fields are empty"
        case "3055": errorStatement = "Unable to login, incorrect password"
        case "3090": errorStatement = "User account is disabled"
        case "3104": errorStatement = "Unable to send email confirmation - user account with the email cannot be found"
        default: errorStatement = "Error, please email us at myshowguide@gmail.com"
        }
      
        self.showNetworkError(errorStatement)
        
        print("User failed to login: \(fault)")
    })
  }
  
  
  
  @IBAction func signUpButtonPressed(sender: AnyObject) {
    performSegueWithIdentifier("loginToSignUpSegue", sender: self)
  }
  @IBAction func cancelButtonPressed(sender: AnyObject) {
    performSegueWithIdentifier("loginToChannelSegue", sender: self)
  }
  
}
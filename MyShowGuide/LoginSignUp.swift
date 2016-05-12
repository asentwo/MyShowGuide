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
    let alert = UIAlertController(title:NSLocalizedString("Whoops?", comment: ""), message: message, preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Default, handler: {_ in self.navigationController?.popViewControllerAnimated(true)})
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
    
  }

//  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    if segue is CustomSegue {
//      (segue as! CustomSegue).animationType = .GrowScale
//    }
//  }
//
//  override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
//    let segue = CustomUnwindSegue(identifier: identifier, source: fromViewController, destination: toViewController)
//    segue.animationType = .GrowScale
//    return segue
//  }
  

  //MARK: IBActions
  
  @IBAction func loginInButtonPressed(sender: AnyObject) {
    SwiftSpinner.show(NSLocalizedString("Logging you in..", comment: ""))
  
    //userNameSignIn = user's email
    BackendlessUserFunctions.sharedInstance.backendlessUserLogin(userNameSignIn.text!, password: passwordSignIn.text!, rep: { ( user : BackendlessUser!) -> () in
    
      self.performSegueWithIdentifier("loginToNavController", sender: self)
      print("User logged in: \(user.objectId)")
      SwiftSpinner.hide()
      
      }, err: { ( fault : Fault!) -> () in
        var errorStatement: String!
        
        switch fault.faultCode {
         
        case "3003": errorStatement = (NSLocalizedString("Account not found, please register", comment: ""))//User Failed to login
        case "3040": errorStatement = (NSLocalizedString("The email address is in the wrong format", comment: ""))
        case "3002": errorStatement = (NSLocalizedString("User is already logged in from another device", comment: ""))
        case "3000": errorStatement = (NSLocalizedString("User cannot be logged in", comment: ""))
        case "3006": errorStatement = (NSLocalizedString("Login or password is missing", comment: ""))        case "3011": errorStatement = (NSLocalizedString("Password is required", comment: ""))
        case "3028": errorStatement = (NSLocalizedString("User is already logged in", comment: ""))
        case "3033": errorStatement = (NSLocalizedString("Unable to register user, user already exists", comment: ""))
        case "3036": errorStatement = (NSLocalizedString("Unable to login, user is locked out due to too many failed login attempts", comment: ""))
        case "3045": errorStatement = (NSLocalizedString("Unable to update user, required fields are empty", comment: ""))
        case "3055": errorStatement = (NSLocalizedString("Unable to login, incorrect password", comment: ""))
        case "3090": errorStatement = (NSLocalizedString("User account is disabled", comment: ""))
        case "3104": errorStatement = (NSLocalizedString("Unable to send email confirmation - user account with the email cannot be found", comment: ""))
        default: errorStatement = (NSLocalizedString("Error, please email us at myshowguide@gmail.com"
           , comment: ""))
        }
        SwiftSpinner.hide()
        self.showNetworkError(errorStatement)
        
        print("User failed to login: \(fault)")
    })
  }
  
  
  @IBAction func dismissLoginScreen(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: {})
  }
  
  @IBAction func signUpButtonPressed(sender: AnyObject) {
    performSegueWithIdentifier("loginToSignUpSegue", sender: self)
  }
   
}
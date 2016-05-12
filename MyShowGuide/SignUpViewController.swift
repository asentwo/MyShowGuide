//
//  SignUpViewController.swift
//  MyShowGuide
//
//  Created by Justin Doo on 5/4/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

import Foundation
import UIKit


class SignUpViewController: UIViewController {
  
  //MARK: IBOutlets
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var confirmPasswordTextField: UITextField!

  
  //MARK: ViewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  //MARK: Alert
  func showNetworkError (title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Default, handler: {_ in self.navigationController?.popViewControllerAnimated(true)})
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
    
  }
  
  func successfulLogin (title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Default, handler: {(action:UIAlertAction!)-> Void in
      self.performSegueWithIdentifier("signUpToNavSegue", sender: self)
    })
    
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
    
  }

  
  
  //MARK: IBActions
  @IBAction func createAccountButtonPressed(sender: AnyObject) {
    SwiftSpinner.show(NSLocalizedString("Creating account..", comment: ""))
    
    if passwordTextField.text != confirmPasswordTextField.text {
      SwiftSpinner.hide()
      showNetworkError(NSLocalizedString("Whoops!", comment: ""), message: (NSLocalizedString("Passwords don't match!", comment: "")))
    }
    
    BackendlessUserFunctions.sharedInstance.backendlessUserRegister(emailTextField.text!,password: passwordTextField.text!,  rep: { ( user : BackendlessUser!) -> () in
      
      BackendlessUserFunctions.sharedInstance.backendless.userService.login( self.emailTextField.text!, password:self.passwordTextField.text,
        
        response: { ( user : BackendlessUser!) -> () in
          
          if BackendlessUserFunctions.sharedInstance.isValidUser() {
          print("User logged in: \(user.objectId)")
            
            SwiftSpinner.hide()
            self.successfulLogin(NSLocalizedString("Success!", comment: ""), message: (NSLocalizedString("Account created!", comment: "")))
          }
          
        },
        
        error: { ( fault : Fault!) -> () in
          print("User failed to login: \(fault)")
        }
      )
      
      }, err: { ( fault : Fault!) -> () in
        
        var errorStatement: String!
        
        switch fault.faultCode {
          
        case "3003": errorStatement = (NSLocalizedString("Account not found, please register", comment: ""))//User Failed to login
        case "3040": errorStatement = (NSLocalizedString("The email address is in the wrong format", comment: ""))
        case "3002": errorStatement = (NSLocalizedString("User is already logged in from another device", comment: ""))
        case "3000": errorStatement = (NSLocalizedString("User cannot be logged in", comment: ""))
        case "3006": errorStatement = (NSLocalizedString("Login or password is missing", comment: ""))
        case "3011": errorStatement = (NSLocalizedString("Password is required", comment: ""))
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
        self.showNetworkError(NSLocalizedString("Whoops!", comment: ""), message: errorStatement)
        print("User failed to login: \(fault)")
    })
  }
  
  @IBAction func dismissCurrentViewController(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: {})}
  
  
}
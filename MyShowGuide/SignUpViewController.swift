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
      showNetworkError("Whoops!", message: "Passwords don't match!")
    }
    
    BackendlessUserFunctions.sharedInstance.backendlessUserRegister(emailTextField.text!,password: passwordTextField.text!,  rep: { ( user : BackendlessUser!) -> () in
      
      BackendlessUserFunctions.sharedInstance.backendless.userService.login( self.emailTextField.text!, password:self.passwordTextField.text,
        
        response: { ( user : BackendlessUser!) -> () in
          
          if BackendlessUserFunctions.sharedInstance.isValidUser() {
          print("User logged in: \(user.objectId)")
            
            SwiftSpinner.hide()
            self.successfulLogin("Success!", message: "Account created!")
          }
          
        },
        
        error: { ( fault : Fault!) -> () in
          print("User failed to login: \(fault)")
        }
      )
      
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
        
        
        self.showNetworkError("Whoops!", message: errorStatement)
        
        print("User failed to login: \(fault)")
    })
  }
  
  @IBAction func dismissCurrentViewController(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: {})}
  
  
}
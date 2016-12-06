//
//  SignUpViewController.swift
//  MyShowGuide
//
//  Created by Justin Doo on 5/4/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

import Foundation
import UIKit
import JSSAlertView

class SignUpViewController: UIViewController, UIViewControllerTransitioningDelegate {
  
  //MARK: IBOutlets
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var confirmPasswordTextField: UITextField!
  
  @IBOutlet weak var createAccountButton: UIButton!
  
  //MARK: ViewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  //MARK: Alert
  func alertViewSuccessAction () {
 self.performSegue(withIdentifier: "signUpToNavSegue", sender: self)

  }
  
  
  //MARK: Bubble Transition
  let transition = BubbleTransition()
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let controller = segue.destination
    controller.transitioningDelegate = self
    controller.modalPresentationStyle = .custom
  }
  
  // MARK: UIViewControllerTransitioningDelegate
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    transition.transitionMode = .present
    transition.startingPoint = createAccountButton.center
    transition.bubbleColor = createAccountButton.backgroundColor!
    return transition
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    transition.transitionMode = .dismiss
    transition.startingPoint = createAccountButton.center
    transition.bubbleColor = createAccountButton.backgroundColor!
    return transition
  }
  
  //MARK: IBActions
  @IBAction func createAccountButtonPressed(_ sender: AnyObject) {
    _ = SwiftSpinner.show(NSLocalizedString("Creating account..", comment: ""))
    
    if passwordTextField.text != confirmPasswordTextField.text {
      SwiftSpinner.hide()
      
      JSSAlertView().show(
        self,
        title: NSLocalizedString("Whoops?", comment: ""),
        text: NSLocalizedString("Passwords don't match!", comment: ""),
        buttonText: "Ok",
        iconImage: myShowGuideLogo)
    } else {
    
    BackendlessUserFunctions.sharedInstance.backendlessUserRegister(emailTextField.text!,password: passwordTextField.text!,  rep: { ( user : BackendlessUser?) -> () in
      
      BackendlessUserFunctions.sharedInstance.backendless?.userService.login( self.emailTextField.text!, password:self.passwordTextField.text,
        
        response: { ( user : BackendlessUser?) -> Void in
          
          if BackendlessUserFunctions.sharedInstance.isValidUser() {
            print("User logged in: \(user?.objectId)")
            
            SwiftSpinner.hide()
            let alertView = JSSAlertView().show(
              self,
              title: NSLocalizedString("Success!", comment: ""),
              text: NSLocalizedString("Account created!", comment: ""),
              buttonText: "Ok",
              iconImage: myShowGuideLogo)
              alertView.addAction(self.alertViewSuccessAction)
          }
        },
        
        error: { ( fault : Fault?) -> () in
          print("User failed to login: \(fault)")
        }
      )
      
      }, err: { ( fault : Fault?) -> () in
        
        var errorStatement: String!
        
        if let faultCodes = fault?.faultCode {
        
        switch faultCodes {
          
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
        }
        
        SwiftSpinner.hide()
          JSSAlertView().show(
          self,
          title: NSLocalizedString("Whoops?", comment: ""),
          text: errorStatement,
          buttonText: "Ok",
          iconImage: myShowGuideLogo)
       
    })
  }
  }
  
  @IBAction func dismissCurrentViewController(_ sender: AnyObject) {
    self.dismiss(animated: true, completion: {})}
  
  
}

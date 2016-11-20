//
//  LoginSignUp.swift
//  MyShowGuide
//
//  Created by Justin Doo on 5/2/16.
//  Copyright © 2016 Justin Doo. All rights reserved.
//

import Foundation
import UIKit
import JSSAlertView

class LoginSignUp: UIViewController, UITextFieldDelegate, UIViewControllerTransitioningDelegate {
  
  
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
  
  //MARK: Bubble Transition
  let transition = BubbleTransition()
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let controller = segue.destination
    controller.transitioningDelegate = self
    controller.modalPresentationStyle = .custom
  }
  
  // MARK: UIViewControllerTransitioningDelegate
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    transition.startingPoint = loginButton.center
    transition.transitionMode = .present
    transition.bubbleColor = loginButton.backgroundColor!
    return transition
  }
  
  
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    transition.transitionMode = .dismiss
    transition.startingPoint = loginButton.center
    transition.bubbleColor = loginButton.backgroundColor!
    return transition
  }
  
  
  //MARK: IBActions
  
  @IBAction func loginInButtonPressed(_ sender: AnyObject) {
    SwiftSpinner.show(NSLocalizedString("Logging you in..", comment: ""))
    
    //userNameSignIn = user's email
    BackendlessUserFunctions.sharedInstance.backendlessUserLogin(userNameSignIn.text!, password: passwordSignIn.text!, rep: { ( user : BackendlessUser?) -> () in
      
      self.performSegue(withIdentifier: "loginToNavController", sender: self)
      print("User logged in: \(user?.objectId)")
      SwiftSpinner.hide()
      
      }, err: { ( fault : Fault?) -> () in
        var errorStatement: String!
        
        if let faultCodes = fault?.faultCode {
        
        switch faultCodes {
          
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
        }
        SwiftSpinner.hide()
        JSSAlertView().show(
          self,
          title: NSLocalizedString("Whoops?", comment: ""),
          text: errorStatement,
          buttonText: "Ok",
          iconImage: myShowGuideLogo)
        
        
        print("User failed to login: \(fault)")
    })
  }
  
  @IBAction func dismissLoginScreen(_ sender: AnyObject) {
    self.dismiss(animated: true, completion: {})
  }
  
  @IBAction func signUpButtonPressed(_ sender: AnyObject) {
    performSegue(withIdentifier: "loginToSignUpSegue", sender: self)
  }
  
}

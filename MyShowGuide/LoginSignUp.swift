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
  
  
  //MARK: IBActions
  
  @IBAction func userNameSignedIn(sender: AnyObject) {
  }
  
  @IBAction func passwordSignedIn(sender: AnyObject) {
  }
  
  @IBAction func loginInButtonPressed(sender: AnyObject) {
  }
  @IBAction func signUpButtonPressed(sender: AnyObject) {
    performSegueWithIdentifier("loginToSignUpSegue", sender: self)
  }
  @IBAction func cancelButtonPressed(sender: AnyObject) {
    performSegueWithIdentifier("loginToChannelSegue", sender: self)
  }

}
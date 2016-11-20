//
//  WebsiteViewController.swift
//  GuideBoxGuideNew1.0
//
//  Created by Justin Doo on 10/28/15.
//  Copyright © 2015 Justin Doo. All rights reserved.
//
import JSSAlertView

class WebsiteViewController: UIViewController, UIWebViewDelegate {
  
  //MARK: Constants - IBOutlets
  
  @IBOutlet var webView: UIWebView!
  var website: String?
  var connected = false
  var spinnerActive = false
  //MARK: ViewDidLoad
  
  override func viewDidLoad() {
    super.viewDidLoad()
    startRequest()
      SwiftSpinner.show(NSLocalizedString("Connecting to website...", comment: ""))
    spinnerActive = true
    self.navigationController!.navigationBar.tintColor = UIColor.white
  }
  
  //MARK: WebView
  
  func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
   // self.showNetworkError()
     JSSAlertView().show(
      self,
      title: NSLocalizedString("Whoops?", comment: ""),
      text: NSLocalizedString( "There was a connection error. Please try again.", comment: ""),
      buttonText: "Ok",
      iconImage: myShowGuideLogo)

  }
  
  
   func webViewDidFinishLoad(_ webView: UIWebView){
    SwiftSpinner.hide()
    spinnerActive = false
    delay(1.5, closure: { self.navigationItem.setHidesBackButton(false, animated:true)
    })
  }
  
  //MARK: Request - Error
  
  func startRequest() {
    let myWeb = webView
    let url = URL(string: website!)!
    let urlConfig = URLSessionConfiguration.default
    urlConfig.timeoutIntervalForRequest = 10
    urlConfig.timeoutIntervalForResource = 10
    let myReq = URLRequest(url: url)
    let session = URLSession(configuration: urlConfig)
    let task = session.dataTask(with: url, completionHandler: {(data, response, error) in
      DispatchQueue.main.async {
        if (error == nil) {
          myWeb?.loadRequest(myReq)
          self.connected = true
        }
        else {
          SwiftSpinner.hide()
          self.spinnerActive = false
        //  self.showNetworkError()
          JSSAlertView().show(
            self,
            title: NSLocalizedString("Whoops?", comment: ""),
            text: NSLocalizedString( "There was a connection error. Please try again.", comment: ""),
            buttonText: "Ok",
            iconImage: myShowGuideLogo)
        }
      }
    }) 
    task.resume()
  }
  
  //MARK: Network Error Indicator
  
//  func showNetworkError () {
//    let alert = UIAlertController(title: NSLocalizedString("Whoops?", comment: ""), message: NSLocalizedString("There was a connection error. Please try again.", comment: ""), preferredStyle: .Alert)
//    let action = UIAlertAction(title: "OK", style: .Default, handler: {_ in self.navigationController?.popViewControllerAnimated(true)})
//    alert.addAction(action)
//    presentViewController(alert, animated: true, completion: nil)
//    
//  }
}

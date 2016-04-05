//
//  WebsiteViewController.swift
//  GuideBoxGuideNew1.0
//
//  Created by Justin Doo on 10/28/15.
//  Copyright © 2015 Justin Doo. All rights reserved.
//

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
      SwiftSpinner.show("Connecting to website...")
    spinnerActive = true
    delay(8, closure: {
      if self.spinnerActive == true {
        SwiftSpinner.hide()
        self.showNetworkError()
      }
    })

    
    self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
  }
  
  //MARK: WebView
  
  func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
    self.showNetworkError()
  }
  
  
   func webViewDidFinishLoad(webView: UIWebView){
    SwiftSpinner.hide()
    spinnerActive = false
    delay(1.5, closure: { self.navigationItem.setHidesBackButton(false, animated:true)
    })
  }
  
  
  //MARK: Request - Error
  
  func startRequest() {
    let myWeb = webView
    let url = NSURL(string: website!)!
    let myReq = NSURLRequest(URL: url)
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithURL(url) {(data, response, error) in
      dispatch_async(dispatch_get_main_queue()) {
        if (error == nil) {
          myWeb.loadRequest(myReq)
          self.connected = true
        }
        else {
          SwiftSpinner.hide()
          self.spinnerActive = false
          self.showNetworkError()
        }
      }
    }
    task.resume()
  }
  
  //MARK: Network Error Indicator
  
  func showNetworkError () {
    let alert = UIAlertController(title: "Whoops?", message: "There was a connection error. Please try again.", preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Default, handler: {_ in self.navigationController?.popViewControllerAnimated(true)})
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
    
  }
}
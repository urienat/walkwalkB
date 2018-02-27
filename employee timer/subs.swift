//
//  subs.swift
//  employee timer
//
//  Created by אורי עינת on 22.3.2017.
//  Copyright © 2017 אורי עינת. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth


class subs: UIViewController {
    
   var lbl = ""

    let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
    var window: UIWindow?


    @IBOutlet weak var thinking: UIActivityIndicatorView!
    


    
    @IBAction func logout(_ sender: Any) {

        
        LoginFile.logoutchosen = true
        try! FIRAuth.auth()?.signOut()
        self.present((storyboard?.instantiateViewController(withIdentifier: "loginScreen"))!, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var woofNew: UIButton!
    
    @IBAction func woofNew(_ sender: Any) {
        woofNew.isEnabled = false
        woofNew.alpha = 0.5
        RebeloperStore.shared.purchaseRenewable(.autoRenewableSubscription1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            
            self.woofNew.isEnabled = true
            self.woofNew.alpha = 1
            
        }

        
        
    }
    
    @IBOutlet weak var woofNewLbl: UILabel!
    @IBAction func privacy(_ sender: Any) {
        UIApplication.shared.open(NSURL(string:"https://www.persessionapp.com/privacy-statement")! as URL, options: [:], completionHandler: nil)
    }
    
    
    
    
    @IBAction func terms(_ sender: Any) {
         UIApplication.shared.open(NSURL(string:"https://www.persessionapp.com/terms-of-use")! as URL, options: [:], completionHandler: nil)
    }
    
    ///////////////////////////////////////////////////////
    override func viewDidLoad() {
        thinking.isHidden = false
       lbl = "Subscription"
    self.title = lbl

        
        self.thinking.startAnimating()
     //   self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Grass12")!)
        //self.view.insertSubview(backgroundImage, at: 0)
        
         updateUI()
    
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name(iAPStatusChanged), object: nil, queue:OperationQueue.main) { (Notification) in
   self.backToMain()        }
        
    
}//end of viewdid ////////////////////////////////////////
    
    
    
    func backToMain() {
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController  =  storyboard.instantiateViewController(withIdentifier: "homeScreen")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            self.window?.rootViewController = homeViewController
            self.present((storyboard.instantiateViewController(withIdentifier: "homeScreen")), animated: true, completion: nil)
            
        }
    }//end of view did appear

    func updateUI() {
        
        RebeloperStore.shared.verifyRenewablePurchase(.autoRenewableSubscription1) { (result, resultString) in
            
            self.woofNewLbl.text = "\(resultString)"
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                self.thinking.stopAnimating()
                self.thinking.isHidden = true
            }
            }
        
      
    }//end of update ui

    
    
        
    }


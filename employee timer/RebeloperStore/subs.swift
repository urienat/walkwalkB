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
        import StoreKit


        class subs: UIViewController {
        var backArrow = UIImage(named: "backArrow")?.withRenderingMode(.alwaysTemplate)
        var lbl = ""
        var blueColor = UIColor(red :22/255.0, green: 131/255.0, blue: 248/255.0, alpha: 1.0)
        var options: [Subscription]?

        //let backgroundImage = UIImageView(frame: UIScreen.main.bounds)

        @IBOutlet weak var thinking: UIActivityIndicatorView!
        @IBOutlet weak var woofNew: UIButton!
        @IBAction func woofNew(_ sender: Any) {
        RebeloperStore.shared.purchaseRenewable(0)
        //RebeloperStore.shared.purchaseRenewable(.autoRenewableSubscription1)
        thinking.startAnimating()
        woofNew.isEnabled = false
        self.woofNewLbl.text = "I am on it..."
        woofNew.alpha = 0.5
       

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
            
         options = subs.shared.options
      
        let yourBackImage = UIImage(named: "backArrow")
        self.navigationController?.navigationBar.backIndicatorImage =  yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
            
        woofNew.isEnabled = false
        woofNew.alpha = 0.5
        woofNew.clipsToBounds = true
        woofNew.layer.borderWidth = 0.5
        woofNew.layer.borderColor = blueColor.cgColor
        woofNew.layer.cornerRadius =  10//CGFloat(25)
        woofNew.layoutIfNeeded()
            
        thinking.isHidden = false
        lbl = "Subscription"
        self.title = lbl
        self.thinking.startAnimating()
        self.woofNewLbl.text = "Checking..."

        
        updateUI()


        NotificationCenter.default.addObserver(forName: NSNotification.Name(iAPStatusChanged), object: nil, queue:OperationQueue.main) { (Notification) in
            
            print ("notificationUI")
            
           self.updateUI()        }

            thinking.hidesWhenStopped = true
        }//end of viewdid ////////////////////////////////////////

        func backToMain() {
        self.navigationController!.popViewController(animated: true) }//

        func updateUI() {
        RebeloperStore.shared.verifyRenewablePurchase(0) { (result, resultString) in
        self.woofNewLbl.text = "\(resultString)"
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0)) {
            if result == true {self.woofNew.isEnabled = false;self.woofNew.alpha = 0.5} else {self.woofNew.isEnabled = true;self.woofNew.alpha = 1}
        self.thinking.stopAnimating()
       
        }
        }
        }//end of update ui
            
            
            ////////////////////////
            func loadSubscriptionOptions() {
                
                let productID = Set(["HomePloyer.perSession.mainSub"]) 
                
                let request = SKProductsRequest(productIdentifiers: productID)
                request.delegate = self
                request.start()
            }

        }
        
        
        //////
        extension subs: SKProductsRequestDelegate {
            func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
                options = response.products.map { (product: $0) }
            }
            
            func request(_ request: SKRequest, didFailWithError error: Error) {
                if request is SKProductsRequest {
                    print("Subscription Options Failed Loading: \(error.localizedDescription)")
                }
            }
        }
        

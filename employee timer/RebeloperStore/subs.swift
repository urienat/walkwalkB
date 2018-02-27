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
        var backArrow = UIImage(named: "backArrow")?.withRenderingMode(.alwaysTemplate)
        var lbl = ""

        //let backgroundImage = UIImageView(frame: UIScreen.main.bounds)

        @IBOutlet weak var thinking: UIActivityIndicatorView!
        @IBOutlet weak var woofNew: UIButton!
        @IBAction func woofNew(_ sender: Any) {
        woofNew.isEnabled = false
        woofNew.alpha = 0.5
        RebeloperStore.shared.purchaseRenewable(.autoRenewableSubscription1)

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
        woofNew.isEnabled = false
        woofNew.alpha = 0.5
        thinking.isHidden = false
        lbl = "Subscription"
        self.title = lbl
        self.thinking.startAnimating()
        self.woofNewLbl.text = "Checking..."

        let yourBackImage = UIImage(named: "backArrow")
        self.navigationController?.navigationBar.backIndicatorImage =  yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage

        updateUI()


        NotificationCenter.default.addObserver(forName: NSNotification.Name(iAPStatusChanged), object: nil, queue:OperationQueue.main) { (Notification) in
        self.backToMain()        }


        }//end of viewdid ////////////////////////////////////////

        func backToMain() {
        self.navigationController!.popViewController(animated: true) }//

        func updateUI() {
        RebeloperStore.shared.verifyRenewablePurchase(.autoRenewableSubscription1) { (result, resultString) in
        self.woofNewLbl.text = "\(resultString)"
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0)) {
            if result == true {self.woofNew.isEnabled = false;self.woofNew.alpha = 0.5} else {self.woofNew.isEnabled = true;self.woofNew.alpha = 1}
        self.thinking.stopAnimating()
        self.thinking.isHidden = true
        }
        }
        }//end of update ui


        }


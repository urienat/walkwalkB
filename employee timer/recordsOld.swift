//
//  recordsOld.swift
//  perSession
//
//  Created by uri enat on 29/11/2017.
//  Copyright © 2017 אורי עינת. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import MessageUI
import Intents

extension(newVCTable){
/*switch checkBoxGeneral {
 //pre
 case 0: generalApproval.setImage(billedImage, for: .normal); checkBoxGeneral = 1 //
 
 
 
 //Approved
 case 1:segmentedPressed = 1
 StatusChosen.selectedSegmentIndex = segmentedPressed!
 //generalApproval.setImage(billIcon, for: .normal);checkBoxGeneral = 2//in the end of due
 //Paid
 case 2:  generalApproval.setImage(billedImage, for: .normal);checkBoxGeneral = 0// in the  end of billing
 //default
 default: break
 ////
 } //end of switch
 DispatchQueue.main.asyncAfter(deadline: .now()+1){
 self.alert11()}
 */

    
    
    func alert6 () {
        print("export")
        let alertController6 = UIAlertController(title: "Mail to \(employerFromMain!) their due records", message: "Are You Sure?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            //nothing
            self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )
            self.segmentedPressed = 0
            self.StatusChosen.selectedSegmentIndex = self.segmentedPressed!
            self.StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
        }//end of cancel action
        
        let exportAction = UIAlertAction(title: "Yes, prepare mail.", style: .default) { (UIAlertAction) in
            print ("Send it")
            self.htmlReport = self.csv2 as String!
            let mailComposeViewController2 = self.configuredMailComposeViewController2()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController2, animated: true, completion: nil)
                self.thinking.stopAnimating()
            } //end of if
            else{ self.thinking.stopAnimating()
                ;self.showSendmailErrorAlert() }
            self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )
        }//end of export action
        
        alertController6.addAction(cancelAction)
        alertController6.addAction(exportAction)
        present(alertController6, animated: true, completion: nil)
    } //end of func alert (mail export)

}

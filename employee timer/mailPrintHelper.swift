//
//  mailPrintHelper.swift
//  perSession
//
//  Created by uri enat on 01/02/2018.
//  Copyright © 2018 אורי עינת. All rights reserved.
//

import Foundation
import UIKit

import Firebase
import MessageUI
import WebKit
//import CoreGraphics

public class mailPrintHelper: UIViewController, MFMailComposeViewControllerDelegate,WKUIDelegate{

    //func for mail
    func  configuredMailComposeViewController2() -> MFMailComposeViewController {
        let mailComposerVC2 = MFMailComposeViewController()
        mailComposerVC2.mailComposeDelegate = self
        mailComposerVC2.setSubject("\(document!)")
        mailComposerVC2.setMessageBody("Dear \(contactForMail!)\r\n\r\nThe invoice is attached for your records. Please don't hesitate to contact me with any questions.\(self.payPalBlock)\r\n\r\nRegards\r\n \(ViewController.fixedName!) \(ViewController.fixedLastName!)", isHTML: false)
        mailComposerVC2.setToRecipients([ViewController.fixedemail])
        mailComposerVC2.addAttachmentData( pdfData as Data, mimeType: "application/pdf", fileName: "Invoice")
        return mailComposerVC2
    }//end of MFMailcomposer
    
    //func for mail4
    func  configuredMailComposeViewController4() -> MFMailComposeViewController {
        let mailComposerVC4 = MFMailComposeViewController()
        mailComposerVC4.mailComposeDelegate = self
        mailComposerVC4.setSubject("\(document!)")
        mailComposerVC4.setMessageBody("Dear \(contactForMail!)\r\n\r\nThe reciept for your payment is attached for your records. Please don't hesitate to contact me with any questions.\r\n\r\nRegards\r\n \(ViewController.fixedName!) \(ViewController.fixedLastName!) ", isHTML: false)
        mailComposerVC4.setToRecipients([ViewController.fixedemail])
        mailComposerVC4.addAttachmentData( pdfData as Data, mimeType: "application/pdf", fileName: "Reciept")
        return mailComposerVC4
    }//end of MFMailcomposer
    
    func showSendmailErrorAlert() {
        let sendMailErorrAlert = UIAlertController(title:"Could Not Send Email", message: "Your device could not send e-mail. Please check e-mail configuration and try again.",preferredStyle: .alert)
        sendMailErorrAlert.message = "error occured"
        //seems that it does not work check!!!!
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Mail cancelled")
            
            controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.saved.rawValue:
            print("Mail saved3")
            self.navigationController!.popToRootViewController(animated: true)
            
            self.navigationController!.popViewController(animated: true)
            
        case MFMailComposeResult.sent.rawValue:
            print("Mail sent3")
            controller.dismiss(animated: true, completion: nil)
            self.navigationController!.popToRootViewController(animated: true)
            
        case MFMailComposeResult.failed.rawValue:
            print("Mail sent failure: %@", [error!.localizedDescription])
            controller.dismiss(animated: true, completion: nil)
            self.navigationController!.popToRootViewController(animated: true)
        default:
            break
        }
        //self.navigationController!.popViewController(animated: true) //check to go one more level
    }


}//end of class

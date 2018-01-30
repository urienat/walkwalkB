//
//  sharedMail.swift
//  perSession
//
//  Created by uri enat on 30/01/2018.
//  Copyright © 2018 אורי עינת. All rights reserved.
//

import Foundation
import MessageUI

extension(MFMailComposeViewControllerDelegate){
    
    //mail support
    //func for mail
    func  configuredMailComposeViewController1() -> MFMailComposeViewController {
        let mailComposerVC1 = MFMailComposeViewController()
        mailComposerVC1.mailComposeDelegate = self
        mailComposerVC1.setSubject("Report")
        mailComposerVC1.setMessageBody("Attached is a report.Regards \(ViewController.fixedName!) \(ViewController.fixedLastName!)", isHTML: false)
        mailComposerVC1.setToRecipients([ViewController.fixedemail])
        mailComposerVC1.addAttachmentData( pdfData as Data, mimeType: "application/pdf", fileName: "Invoice")
        return mailComposerVC1
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
            controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.sent.rawValue:
            print("Mail sent3")
            controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.failed.rawValue:
            print("Mail sent failure: %@", [error!.localizedDescription])
            controller.dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
}

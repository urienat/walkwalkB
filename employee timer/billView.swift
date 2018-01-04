//
//  billView.swift
//  employee timer
//
//  Created by אורי עינת on 26.2.2017.
//  Copyright © 2017 אורי עינת. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import MessageUI

class billView: UIViewController, MFMailComposeViewControllerDelegate {

    let dbRef = FIRDatabase.database().reference().child("fRecords")
    let dbRefEmployer = FIRDatabase.database().reference().child("fEmployers")
    let dbRefEmployee = FIRDatabase.database().reference().child("fEmployees")
    
    let Vimage = UIImage(named: "due")
    let nonVimage = UIImage(named: "emptyV")
    let paidImage = UIImage(named: "paid")
    let billedImage = UIImage(named: "locked")
    let billIcon = UIImage(named: "bill")
    let canceledImage = UIImage(named: "cancelled")
    
    var titleLbl = ""
    var billToHandle = String()
    var employerID = ""
    var employeeID = ""
    var recieptDate: String?
    var paymentDate: String?
    var document :String?
    var documentCounter :String?
    var rebillprocess:Bool?
    
    
    var deleteBill : UIBarButtonItem?
    
    var recoveredBill = ""
    var recoveredReciept = ""
    var recoveredStatus = ""
    var billStatusForRecovery = ""
    var cancelledDocument: String?
    
    var recieptChosen:Bool = false

    @IBOutlet weak var mailView: UITextView!
    @IBOutlet weak var billReciept: UISegmentedControl!
    @IBAction func billReciept(_ sender: Any) {
        switch billReciept.selectedSegmentIndex {
        case 0:recieptChosen = false
        self.mailText.text = self.recoveredBill
        self.titleLbl = "\(document!) \(documentCounter!)"
        self.title = self.titleLbl
        case 1:recieptChosen = true
        self.mailText.text = self.recoveredReciept
        self.titleLbl = "Reciept \(documentCounter!)"
        self.title = self.titleLbl
        default:
          print ("switch is not working") //do nothing
        } //end of switch
    }
    
   
    let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
  
    @IBOutlet weak var mailText: UITextView!
 

    @IBOutlet weak var deleteBtn: UIBarButtonItem!
    
    @IBAction func deleteBtn(_ sender: Any) {
        deleteAlert()
        
    }
    
    
    @IBOutlet weak var statusImage: UIImageView!
    
    
    @IBOutlet weak var reSend: UIBarButtonItem!
    
    @IBAction func reSend(_ sender: Any) {
        if recieptChosen {alert6()} else {  alert5()}
    }
    
    /////////////////////////////////////////////////////////////////  view did load starts///////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print ("fff")
        //connectivity
        if Reachability.isConnectedToNetwork() == true
        {print("Internet Connection Available!")
        }else{
        print("Internet Connection not Available!")
        alert50()
        }
        
        navigationItem.leftBarButtonItem = deleteBill
        deleteBill?.isEnabled = false
        
        self.view.insertSubview(backgroundImage, at: 0)
      
        billReciept.isHidden = false

        print (recoveredReciept)

        
        
        if rebillprocess == true {
        reBill() }
        
        else {
            
            print (recoveredReciept)

        if recoveredReciept != "" {
        print ("in reciept")
        presentReciept()
        } else {
        print ("in bill")
        presentBill()} }

        
        
    } ///end of did load/////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func presentReciept(){
        billReciept.isHidden = true
        print (recoveredReciept)
        recieptChosen = true

        self.mailText.text = self.recoveredReciept
        alert55()
        
    }
    
        func presentBill(){
        billReciept.isHidden = true
        self.recieptChosen = false
        self.mailText.text = self.recoveredBill
        alert55()
        }
    
        func  reBill() {

        self.dbRefEmployee.child(employeeID).child("myBills").child(billToHandle).observeSingleEvent(of: .value,with: { (snapshot) in

        self.recoveredBill = (snapshot.childSnapshot(forPath: "fBillMailSaver").value! as? String)!
        self.recoveredReciept = (snapshot.childSnapshot(forPath: "fBillRecieptMailSaver").value! as? String)!

        print("recovered234  56")
        print(self.recoveredBill)
        self.mailText.text = self.recoveredBill

        self.recoveredStatus = (snapshot.childSnapshot(forPath: "fBillStatus").value! as? String)!
        self.recieptDate = (snapshot.childSnapshot(forPath: "fRecieptDate").value! as? String)!
        self.paymentDate = (snapshot.childSnapshot(forPath: "fBillDate").value! as? String)!
        self.document = (snapshot.childSnapshot(forPath: "fDocumentName").value! as? String)!
        self.documentCounter = (snapshot.childSnapshot(forPath: "fBill").value! as? String)!
            
        //check what is rebilled
        if self.recoveredReciept == "" {self.billReciept.isHidden = true ;print ("biil & Pay or just bill")} else {self.billReciept.isHidden = false;print(" bill and then reciept")}

        self.titleLbl = "\(self.document!) \(self.documentCounter!)"
        self.title = self.titleLbl

        if self.recoveredStatus == "Billed" { self.deleteBtn.isEnabled = true;self.billStatusForRecovery = ""}
        if  self.recoveredStatus  == "Paid" { self.statusImage.image = self.paidImage;self.deleteBtn.isEnabled = true;self.billStatusForRecovery = ""}
        if self.recoveredStatus ==  "Cancelled" { self.statusImage.image = self.canceledImage; self.deleteBtn.isEnabled = false;self.billStatusForRecovery = "This bill was cancelled"}


        })


        }//end rebill clicked

    
        ////mail section

        //func for mail
        func  configuredMailComposeViewController2() -> MFMailComposeViewController {
        let mailComposerVC2 = MFMailComposeViewController()
        mailComposerVC2.mailComposeDelegate = self
        mailComposerVC2.setSubject("Bill recovery \(billToHandle)")
        mailComposerVC2.setMessageBody("\(recoveredBill)\r\n\r\n\r\n \(billStatusForRecovery)", isHTML: false)
        mailComposerVC2.setToRecipients([ViewController.fixedemail])
        //mailComposerVC2.setCcRecipients([ViewController.fixedemail])
        return mailComposerVC2
        }//end of MFMailcomposer
    
        //func for mail4
        func  configuredMailComposeViewController4() -> MFMailComposeViewController {
        let mailComposerVC4 = MFMailComposeViewController()
        mailComposerVC4.mailComposeDelegate = self
        mailComposerVC4.setSubject("Bill recovery \(billToHandle)")
        mailComposerVC4.setMessageBody("\(recoveredReciept)\r\n\r\n \r\n \(billStatusForRecovery)", isHTML: false)
        mailComposerVC4.setToRecipients([ViewController.fixedemail])
        //mailComposerVC4.setCcRecipients([ViewController.fixedemail])
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
        // Dismiss the mail compose view controller.
        
        //controller.dismiss(animated: true, completion: nil)
        self.navigationController!.popViewController(animated: true)
        }

    
 //alerts////////////////////////////////////////////
        func alert5(){
        let alertController5 = UIAlertController(title: ("Share") , message: "", preferredStyle: .alert)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        //do nothing
        }
        let OKAction = UIAlertAction(title: "Mail", style: .default) { (UIAlertAction) in
        let mailComposeViewController2 = self.configuredMailComposeViewController2()
        if MFMailComposeViewController.canSendMail() {

        self.present(mailComposeViewController2, animated: true, completion: nil)
        } //end of if
        else{ self.showSendmailErrorAlert() }
        // navigationController!.popViewController(animated: true)

        }

        let printAction = UIAlertAction(title: "Print", style: .default) { (UIAlertAction) in
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = "My Print Job"

        // Set up print controller
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo

        // Assign a UIImage version of my UIView as a printing iten
        printController.printingItem =   self.mailView.toImage()

        // Do it
        printController.present(from: self.view.frame, in: self.view, animated: true, completionHandler: nil)


        }

        alertController5.addAction(OKAction)
        alertController5.addAction(printAction)
        alertController5.addAction(CancelAction)
        self.present(alertController5, animated: true, completion: nil)
        }

    
        func alert6(){
        let alertController5 = UIAlertController(title: ("Share") , message: "", preferredStyle: .alert)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        //do nothing
        }
        let OKAction = UIAlertAction(title: "Mail", style: .default) { (UIAlertAction) in
        let mailComposeViewController2 = self.configuredMailComposeViewController4()
        if MFMailComposeViewController.canSendMail() {

        self.present(mailComposeViewController2, animated: true, completion: nil)
        } //end of if
        else{ self.showSendmailErrorAlert() }
        // navigationController!.popViewController(animated: true)

        }
        let printAction = UIAlertAction(title: "Print", style: .default) { (UIAlertAction) in
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = "My Print Job"

        // Set up print controller
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo

        // Assign a UIImage version of my UIView as a printing iten
        printController.printingItem =   self.mailView.toImage()

        // Do it
        printController.present(from: self.view.frame, in: self.view, animated: true, completionHandler: nil)


        }
        alertController5.addAction(OKAction)
        alertController5.addAction(printAction)
        alertController5.addAction(CancelAction)
        self.present(alertController5, animated: true, completion: nil)
        }

        //save alert
        func deleteAlert () {
        print("delete")
        if billReciept.isHidden != true { self.cancelledDocument = "Bill & Recipet ref# \(self.documentCounter!)"} else {self.cancelledDocument = "\(self.document!) ref# \(self.documentCounter!)"}

        let alertController = UIAlertController(title: "Delete \(cancelledDocument!)", message: "You are about to delete \(cancelledDocument!) ,though visibilty would remain. Are You Sure?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        //nothing
        }
        let deleteAction = UIAlertAction(title: "Delete it.", style: .default) { (UIAlertAction) in
        self.dbRefEmployee.child(self.employeeID).child("myBills").child(String(self.billToHandle)).updateChildValues([ "fBillStatus":"Cancelled"])

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){

        self.navigationController!.popViewController(animated: true)
        }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
        }
    
    func alert55() {
        let alertController55 = UIAlertController(title: "Bill (counter)", message: "Register the bill", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Undo", style: .cancel) { (UIAlertAction) in
        //undo - delete bill or reciept data
        // if bill undo records to 'due'
        }
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        // do nothing
        }
        
        alertController55.addAction(cancelAction)
        alertController55.addAction(OKAction)
        self.present(alertController55, animated: true, completion: nil)
        }
    
        func alert50(){
        let alertController50 = UIAlertController(title: ("Internet Connection") , message: " There is no internet - Check communication avilability.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        }

        alertController50.addAction(OKAction)
        self.present(alertController50, animated: true, completion: nil)
        }

        }//end of class

        extension UIView {
        func toImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)

        drawHierarchy(in: self.bounds, afterScreenUpdates: true)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
        }
        }

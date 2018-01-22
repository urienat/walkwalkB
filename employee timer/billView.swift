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
    
   // var window: UIWindow?


    let dbRef = FIRDatabase.database().reference().child("fRecords")
    let dbRefEmployer = FIRDatabase.database().reference().child("fEmployers")
    let dbRefEmployee = FIRDatabase.database().reference().child("fEmployees")
    var blueColor = UIColor(red :22/255.0, green: 131/255.0, blue: 248/255.0, alpha: 1.0)

    let Vimage = UIImage(named: "due")
    let nonVimage = UIImage(named: "emptyV")
    let paidImage = UIImage(named: "paid")
    let billedImage = UIImage(named: "locked")
    let billIcon = UIImage(named: "bill")
    let canceledImage = UIImage(named: "cancelled")
    let trashImage = UIImage(named: "trash")
    let billDocument = UIImage(named: "billDocument")
    var textString = ""
    var largeTextRange:NSRange?
    var smallTextRange:NSRange?
    let largeFont = UIFont(name: "PingFang TC", size: 16.0)!
    let smallFont = UIFont(name: "PingFang TC", size: 8.0)!
    let paragraph = NSMutableParagraphStyle()
    
    
    var titleLbl = ""
    var billToHandle = String()
    var employerID = ""
    var employeeID = ""
    var recieptDate: String?
    var paymentDate: String?
    var document :String?
    var documentCounter :String?
    var rebillprocess:Bool?
    
    var undoArray: [String] = []
    
    let undoBtn = UIButton(type: .custom)
    let trashBtn = UIButton(type: .custom)
    let doneBtn = UIButton(type: .custom)

    
    let mydateFormat5 = DateFormatter()
    let mydateFormat8 = DateFormatter()

    
    //var deleteBill : UIBarButtonItem?
    
    var recoveredBill = ""
    var recoveredReciept = ""
    var recoveredStatus = ""
    var billStatusForRecovery = ""
    var cancelledDocument: String?
    var statusCanclledDate: String?
    
    var lastPrevious = ""
    
    var registerTitle : String?
    
    var recieptChosen:Bool = false

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mailView: UITextView!
    @IBOutlet weak var billReciept: UISegmentedControl!
    @IBAction func billReciept(_ sender: Any) {
        switch billReciept.selectedSegmentIndex {
        case 0:recieptChosen = false
        
        //self.mailText.text = "\(self.billStatusForRecovery)\r\n\r\n\(self.recoveredBill)"
        self.titleLbl = "\(document!) \(documentCounter!)"
        self.title = self.titleLbl
        self.attributedText(attributed: self.recoveredBill)

        case 1:recieptChosen = true
        //self.mailText.text = "\(self.billStatusForRecovery)\r\n\r\n\(self.recoveredReciept)"
        self.titleLbl = "Reciept \(documentCounter!)"
        self.title = self.titleLbl
        self.attributedText(attributed: self.recoveredReciept)

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
        if recieptChosen == true {alert6()} else {  alert5()}
    }
    
    /////////////////////////////////////////////////////////////////  view did load starts///////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectivityCheck()
        
        mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)",options: 0, locale: nil)!
        mydateFormat8.dateFormat = DateFormatter.dateFormat(fromTemplate: " MMM d, yyyy", options: 0, locale: Locale.autoupdatingCurrent)!

        let doneProcess = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(returnToList))
        
      
        trashBtn.setImage(trashImage , for: .normal)
        trashBtn.setTitle("Bill", for: .normal)
        //btn4.setTitleColor(blueColor, for: .normal)
        //btn4.frame = CGRect(x: 0, y: 0, width: 20, height: 40)
        trashBtn.addTarget(self, action:#selector(deleteAlert), for: UIControlEvents.touchDown)
        
        //undoBtn.setImage(sendBillIcon , for: .normal)
        undoBtn.setTitle("Undo", for: .normal)
        undoBtn.setTitleColor(blueColor, for: .normal)
        //btn4.frame = CGRect(x: 0, y: 0, width: 20, height: 40)
        undoBtn.addTarget(self, action:#selector(undo), for: UIControlEvents.touchDown)
        
        self.view.insertSubview(backgroundImage, at: 0)
        if rebillprocess == true {
        deleteBtn.customView = trashBtn
        reBill()
        }else {
        //deleteBtn.isEnabled = false
        deleteBtn.customView = undoBtn
        navigationItem.rightBarButtonItem = doneProcess
        navigationItem.hidesBackButton = true
        if recoveredReciept != "" {
        print ("in reciept")
        presentReciept()
        } else {
        print ("in bill")
        presentBill()} }
        
        deleteBtn.isEnabled = true
        
        
    } ///end of did load/////////////////////////////////////////////////////////////////////////////////////////////////////
    
        func presentReciept(){
        billReciept.isHidden = true
        print (recoveredReciept)
        recieptChosen = true
       // self.mailText.text = self.recoveredReciept
            self.attributedText(attributed: self.recoveredReciept)

        }

        func presentBill(){
        billReciept.isHidden = true
        self.recieptChosen = false
       // self.mailText.text = self.recoveredBill
        self.attributedText(attributed: self.recoveredBill)

        }
    
    func returnToList(){
        print ("return")
        self.present((storyboard?.instantiateViewController(withIdentifier: "homeScreen"))!, animated: true, completion: nil)
    }
    
    func undo(){
            print (self.recieptChosen)

            if self.recieptChosen == true {
            print(self.employeeID)
            print ((String("-\(self.documentCounter!)"))!)

            self.dbRefEmployee.child(self.employeeID).child("myBills").child(String("-\(self.documentCounter!)")!).updateChildValues(["fBillStatus": "Billed", "fBillStatusDate":
            "","fPaymentReference":"" ,"fRecieptDate":"","fBillRecieptMailSaver":""
            ], withCompletionBlock: { (error) in}) //end of update.



            } else {

            print (String(Int(self.documentCounter!)!-1))

            self.dbRefEmployee.child(self.employeeID).child("myBills").child(String("-\(self.documentCounter!)")!).removeValue()
            self.dbRefEmployee.child(self.employeeID).updateChildValues(["fCounter":String(Int(self.documentCounter!)!)])

            //undo - undo records
            self.moveSessionToBilled()


            }
            print (lastPrevious)

            self.dbRefEmployer.child(self.employerID).updateChildValues(["fLast":lastPrevious], withCompletionBlock: { (error) in})

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0){

            if self.recieptChosen == true {

            self.navigationController!.popViewController(animated: true)
            } else {
            self.navigationController!.popToRootViewController(animated: true)


            }
            }
            }

        func  reBill() {
        self.dbRefEmployee.child(employeeID).child("myBills").child(billToHandle).observeSingleEvent(of: .value,with: { (snapshot) in
        self.recoveredBill = (snapshot.childSnapshot(forPath: "fBillMailSaver").value! as? String)!
        self.recoveredReciept = (snapshot.childSnapshot(forPath: "fBillRecieptMailSaver").value! as? String)!
        if (snapshot.childSnapshot(forPath: "fBillStatusDate").value! as? String) != nil {self.statusCanclledDate = (snapshot.childSnapshot(forPath: "fBillStatusDate").value! as? String)!}
        self.recoveredStatus = (snapshot.childSnapshot(forPath: "fBillStatus").value! as? String)!
        self.recieptDate = (snapshot.childSnapshot(forPath: "fRecieptDate").value! as? String)!
        self.paymentDate = (snapshot.childSnapshot(forPath: "fBillDate").value! as? String)!
        self.document = (snapshot.childSnapshot(forPath: "fDocumentName").value! as? String)!
        self.documentCounter = (snapshot.childSnapshot(forPath: "fBill").value! as? String)!
            
        //check what is rebilled
        if self.recoveredReciept == "" {self.billReciept.isHidden = true ;print ("biil & Pay or just bill")} else {self.billReciept.isHidden = false;print(" bill and then reciept")}

        self.titleLbl = "\(self.document!) \(self.documentCounter!)"
        self.title = self.titleLbl
            
        
            print (self.recoveredStatus)

        if self.recoveredStatus == "Billed" { self.deleteBtn.isEnabled = true;self.billStatusForRecovery = "";self.statusImage.image = self.billDocument;}
        if  self.recoveredStatus  == "Paid" { self.statusImage.image = self.paidImage;self.deleteBtn.isEnabled = true;self.billStatusForRecovery = ""}
        if self.recoveredStatus ==  "Cancelled" {
            
            self.statusImage.image = self.canceledImage;
            
            self.deleteBtn.isEnabled = false;self.billStatusForRecovery = "!!!!!!!!!!This document was cancelled: \(self.mydateFormat8.string(from: self.mydateFormat5.date(from: self.statusCanclledDate!)! ))!!!!!!!!!!"}
            
            self.attributedText(attributed: self.recoveredBill)
            
        })

        }//end rebill clicked
    
    func attributedText(attributed:String) {
        //self.mailText.text = "\(self.billStatusForRecovery)\r\n\r\n\(self.recoveredBill)"
        
        if recieptChosen == false { self.textString = "\(self.document!)-\(self.documentCounter!) \r\n\(self.billStatusForRecovery)\r\n\r\n\(attributed)"} else {  self.textString = "Reciept for \(self.document!)-\(self.documentCounter!) \r\n\(self.billStatusForRecovery)\r\n\r\n\(attributed)\r\n\r\n\r\n\r\n\\r\n\r\n\\r\n\r\n\\r\n\r\n\\r\n\r\n\\r\n\r\n\\r\n\r\n"}
        var attrText = NSMutableAttributedString(string: textString)
        
        //  Convert textString to NSString because attrText.addAttribute takes an NSRange.
        if recieptChosen == false { self.largeTextRange = (textString as NSString).range(of: "\(self.document!)-\(self.documentCounter!)"); self.smallTextRange = (textString as NSString).range(of: "\r\n\(self.billStatusForRecovery)\r\n\r\n\(attributed)")} else {self.largeTextRange = (textString as NSString).range(of: "Reciept for \(self.document!)-\(self.documentCounter!)");self.smallTextRange = (textString as NSString).range(of: "\r\n\(self.billStatusForRecovery)\r\n\r\n\(attributed)")}
        
        paragraph.alignment = .center
        let attributes: [String : Any] = [NSParagraphStyleAttributeName: paragraph, NSFontAttributeName:largeFont]
        
        attrText.addAttribute(NSFontAttributeName, value: self.smallFont, range: smallTextRange!)
        attrText.addAttribute(NSFontAttributeName, value: self.largeFont, range: largeTextRange!)
        attrText.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: largeTextRange!)

        
        
       
       // attrText = NSMutableAttributedString(string:"\(self.document!)-\(self.documentCounter!)" , attributes: attributes)
        
        self.mailText.attributedText = attrText

        
        //saveBase64StringToPDF(textString)
        imageFromTextView(textView: mailText)
        
    }

        //func for mail
        func  configuredMailComposeViewController2() -> MFMailComposeViewController {
        let mailComposerVC2 = MFMailComposeViewController()
        mailComposerVC2.mailComposeDelegate = self
        mailComposerVC2.setSubject("\(document!) \(documentCounter!)")
        mailComposerVC2.setMessageBody("\(recoveredBill)\r\n\r\n\r\n", isHTML: false)
        mailComposerVC2.setToRecipients([ViewController.fixedemail])
        //mailComposerVC2.addAttachmentData(<#T##attachment: Data##Data#>, mimeType: <#T##String#>, fileName: <#T##String#>)
            
        //mailComposerVC2.setCcRecipients([ViewController.fixedemail])
        return mailComposerVC2
        }//end of MFMailcomposer
    
        //func for mail4
        func  configuredMailComposeViewController4() -> MFMailComposeViewController {
        let mailComposerVC4 = MFMailComposeViewController()
        mailComposerVC4.mailComposeDelegate = self
        mailComposerVC4.setSubject("Reciept \(documentCounter!)")
        mailComposerVC4.setMessageBody("\(recoveredReciept)\r\n\r\n \r\n ", isHTML: false)
        mailComposerVC4.setToRecipients([ViewController.fixedemail])
        //mailComposerVC2.addAttachmentData(<#T##attachment: Data##Data#>, mimeType: <#T##String#>, fileName: <#T##String#>)

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
        deleteBtn.isEnabled = false

        controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.sent.rawValue:
        print("Mail sent3")
        deleteBtn.isEnabled = false

        controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.failed.rawValue:
        print("Mail sent failure: %@", [error!.localizedDescription])
        controller.dismiss(animated: true, completion: nil)
        default:
        break
        }
        
        self.navigationController!.popViewController(animated: true) //check to go one more level
        }

        func  moveSessionToBilled() {
        print ("moveSessionToBilled")
        for h in 0...(undoArray.count-1){
            self.dbRef.child(String(undoArray[h])).updateChildValues(["fStatus": "Approved"], withCompletionBlock: { (error) in}) //end of update.
        }//end of loop
        }//end movesession
    
    func imageFromTextView(textView: UITextView) -> UIImage {
        
        // Make a copy of the textView first so that it can be resized
        // without affecting the original.
        let textViewCopy = UITextView(frame: textView.frame)
        textViewCopy.attributedText = textView.attributedText
        
        // resize if the contentView is larger than the frame
        if textViewCopy.contentSize.height > textViewCopy.frame.height {
            textViewCopy.frame = CGRect(origin:CGPoint(), size: textViewCopy.contentSize)
        }
        
        // draw the text view to an image
        UIGraphicsBeginImageContextWithOptions(textViewCopy.bounds.size, false, UIScreen.main.scale)
        textViewCopy.drawHierarchy(in: textViewCopy.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        print ("image:\(image!)")
        return image!
    }

    
    func saveBase64StringToPDF(_ base64String: String) {
        guard
            var documentsURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last,
            let convertedData = Data(base64Encoded: base64String)
            else {
                //handle error when getting documents URL
                return
        }
        
        //name your file however you prefer
        documentsURL.appendPathComponent("yourFileName.pdf")
        do {
            try convertedData.write(to: documentsURL)
        } catch {
            //handle write error here
        }
        //if you want to get a quick output of where your
        //file was saved from the simulator on your machine
        //just print the documentsURL and go there in Finder
        print("url\(documentsURL)")
    }
    
 //alerts////////////////////////////////////////////
        func alert5(){
        let alertController5 = UIAlertController(title: ("Share") , message: "", preferredStyle: .alert)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        //do nothing
        }
        let mailAction = UIAlertAction(title: "Mail", style: .default) { (UIAlertAction) in
        let mailComposeViewController2 = self.configuredMailComposeViewController2()
        if MFMailComposeViewController.canSendMail() {
        self.present(mailComposeViewController2, animated: true, completion: nil)
        } //end of if
        else{ self.showSendmailErrorAlert() }
        // navigationController!.popViewController(animated: true)
        }

        let printAction = UIAlertAction(title: "Print", style: .default) { (UIAlertAction) in
            self.printText()
        /*
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = "My Print Job"

        // Set up print controller
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo

        // Assign a UIImage version of my UIView as a printing iten
        //printController.printingItem =   self.mailView.toImage()
        printController.printingItem =   self.scrollView.toImage()

        // Do it
            self.deleteBtn.isEnabled = false

        printController.present(from: self.view.frame, in: self.view, animated: true, completionHandler: nil)
        */
        }

        alertController5.addAction(mailAction)
        alertController5.addAction(printAction)
        alertController5.addAction(CancelAction)
        self.present(alertController5, animated: true, completion: nil)
        }

    
        func alert6(){
        let alertController5 = UIAlertController(title: ("Share") , message: "", preferredStyle: .alert)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        //do nothing
        }
        let mailAction = UIAlertAction(title: "Mail", style: .default) { (UIAlertAction) in
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
        //printController.printingItem =   self.mailView.toImage()
        printController.printingItem =   self.scrollView.toImage()

        // Do it
        printController.present(from: self.view.frame, in: self.view, animated: true, completionHandler: nil)
            self.deleteBtn.isEnabled = false


        }
        alertController5.addAction(mailAction)
        alertController5.addAction(printAction)
        alertController5.addAction(CancelAction)
        self.present(alertController5, animated: true, completion: nil)
        }

        //save alert
        func deleteAlert () {
        print("delete")
        if billReciept.isHidden != true { self.cancelledDocument = "Bill & Recipet ref# \(self.documentCounter!)"} else {self.cancelledDocument = "\(self.document!) ref# \(self.documentCounter!)"}

        let alertController = UIAlertController(title: "Delete Alert", message: "You are about to delete \(cancelledDocument!). Are You Sure?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        //nothing
        }
        let deleteAction = UIAlertAction(title: "Delete it.", style: .default) { (UIAlertAction) in
            self.dbRefEmployee.child(self.employeeID).child("myBills").child(String(self.billToHandle)).updateChildValues([ "fBillStatus":"Cancelled","fBillStatusDate": self.mydateFormat5.string(from: Date())])

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){

        self.navigationController!.popViewController(animated: true)
        }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
        }
    
    
    func printText(){
        
        var pic:UIPrintInteractionController = .shared
        var viewpf:UIViewPrintFormatter = mailText.viewPrintFormatter()
        //var viewpf2:UIViewPrintFormatter = scrollView.viewPrintFormatter()

        //pic.delegate = self
        pic.printFormatter = viewpf
        //pic.printFormatter = viewpf2
        pic.present(animated: true, completionHandler: nil)
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
            
            
    
        }//end of extension

        extension UIViewController{
    

            
        func connectivityCheck(){
        if Reachability.isConnectedToNetwork() == true
        {print("Internet Connection Available!");
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                self.firebaseConnectivity()
            }
        }else{
            print("Internet Connection not Available!")
            alert50()
        }
            }
            func firebaseConnectivity() {
            let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
            connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
            print("Connected")
            }else {
            print("Not connected")
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0){
            connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
            print("Connected after all")} else  {print("not connected after all");self.noFB()}
            })
            }}
            })
            }
        
            func noFB() {
            self.alert30()
            }

        
            
        func alert30(){
        let alertController30 = UIAlertController(title: ("No connection") , message: "Currently there is no connection with database. Please try again in few minutes.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        
        }
        alertController30.addAction(OKAction)
        self.present(alertController30, animated: true, completion: nil)
        }
        func alert50(){
        let alertController50 = UIAlertController(title: ("Internet Connection") , message: " There is no internet - Check communication avilability.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        }
        
        alertController50.addAction(OKAction)
        self.present(alertController50, animated: true, completion: nil)
    }
    }//end of extension

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
import WebKit
//import CoreGraphics

class billView: UIViewController, MFMailComposeViewControllerDelegate,WKUIDelegate{
    
    let dbRef = FIRDatabase.database().reference().child("fRecords")
    let dbRefEmployer = FIRDatabase.database().reference().child("fEmployers")
    let dbRefEmployee = FIRDatabase.database().reference().child("fEmployees")
    var blueColor = UIColor(red :22/255.0, green: 131/255.0, blue: 248/255.0, alpha: 0.7)
    var grayColor = UIColor(red :235/255.0, green: 235/255.0, blue: 235/255.0, alpha: 1)

    let yourBackImage = UIImage(named: "backArrow")
    let nonVimage = UIImage(named: "emptyV")
    let paidImage = UIImage(named: "paid")
    let billedImage = UIImage(named: "locked")
    let billIcon = UIImage(named: "bill")
    let canceledImage = UIImage(named: "cancelled")
    let trashImage = UIImage(named: "trash")
    let billDocument = UIImage(named: "billDocument")
    let partially = UIImage(named: "partially")
    let logoImage = UIImage(named: "logo")
    
    var taxBillsToHandle: Bool?
    var payPalBlock=""

    var textString = ""
    var largeTextRange:NSRange?
    var smallTextRange:NSRange?
    var centerTextRange:NSRange?
    let largeFont = UIFont(name: "PingFang TC", size: 20.0)!
    let smallFont = UIFont(name: "PingFang TC", size: 10.0)!
    let colorFont = UIColor.red
    let paragraph = NSMutableParagraphStyle()
    var alertExtension: String?
    
    var recieptsArray2 = [String]()
    var contactForMail: String?
    var titleLbl = ""
    var billToHandle: String?
    var employerID = ""
    var employeeID = ""
    var recieptDate: String?
    var paymentDate: String?
    var document :String?
    var documentCounter :String?
    var rebillprocess:Bool?
    var undoTotal: String?
    var undoRecieptCounter: String?
    var undoBalance: String?
    var statusForUndo: String?
    var balance: String?
    var recieptPayment: String?
    var documentsFileName: String?
    var pdfData = NSMutableData()
    var documentPdfData: NSMutableData?
    var documentsURL: String?
    var undoArray: [String] = []
    let undoBtn = UIButton(type: .custom)
    let trashBtn = UIButton(type: .custom)
    let doneBtn = UIButton(type: .custom)
    let mydateFormat5 = DateFormatter()
    let mydateFormat8 = DateFormatter()
    var recoveredBill = ""
    var recoveredReciept = ""
    var recoveredStatus = ""
    var billStatusForRecovery = ""
    var cancelledDocument: String?
    var statusCanclledDate: String?
    var lastPrevious = ""
    var registerTitle : String?
    var recieptChosen:Bool = false
    var recieptStatus :String?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mailView: UITextView!
    @IBOutlet weak var billReciept: UISegmentedControl!
    @IBAction func billReciept(_ sender: Any) {
    switch billReciept.selectedSegmentIndex {
    case 0:
    recieptChosen = false
    reBill()
    case billReciept.selectedSegmentIndex:
    recieptChosen = true
    self.titleLbl = "Reciept-\(documentCounter!)-\(billReciept.selectedSegmentIndex)"
    self.title = self.titleLbl
    reReciept()
    default:
    print ("switch is not working") //do nothing
    } //end of switch
    }
    
    //let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
    @IBOutlet weak var mailText: UITextView!
    @IBOutlet weak var webView2: UIWebView!
    @IBOutlet weak var deleteBtn: UIBarButtonItem!
    @IBAction func deleteBtn(_ sender: Any) {deleteAlert()}
    @IBOutlet weak var statusImage: UIImageView!
    
    func share(){if recieptChosen == true {alert6()} else {  alert5()}}
    /////////////////////////////////////////////////////////////////  view did load starts///////////////////////
    override func viewDidLoad() {
    super.viewDidLoad()
        
        let yourBackImage = UIImage(named: "backArrow")
        self.navigationController?.navigationBar.backIndicatorImage =  yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        
        mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)",options: 0, locale: nil)!
        mydateFormat8.dateFormat = DateFormatter.dateFormat(fromTemplate: " MMM d, yyyy", options: 0, locale: Locale.autoupdatingCurrent)!

        let doneProcess = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(returnToList))
        let shareProcess = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(share))

        trashBtn.setImage(trashImage , for: .normal)
        
        //trashBtn.setTitle("Bill", for: .normal)
        //btn4.setTitleColor(blueColor, for: .normal)
        //btn4.frame = CGRect(x: 0, y: 0, width: 20, height: 40)
        trashBtn.addTarget(self, action:#selector(deleteAlert), for: UIControlEvents.touchDown)
        
        //undoBtn.setImage(sendBillIcon , for: .normal)
        undoBtn.setTitle("Undo", for: .normal)
        undoBtn.setTitleColor(blueColor, for: .normal)
        undoBtn.setTitleColor(UIColor.gray, for: .disabled)
        //btn4.frame = CGRect(x: 0, y: 0, width: 20, height: 40)
        undoBtn.addTarget(self, action:#selector(undo), for: UIControlEvents.touchDown)
        
        //self.view.insertSubview(backgroundImage, at: 0)
        if rebillprocess == true {
        deleteBtn.customView = trashBtn
        navigationItem.rightBarButtonItem = shareProcess
        reBill()
        }else {
        deleteBtn.customView = undoBtn
        self.titleLbl = "\(self.document!)"
        self.title = self.titleLbl
        navigationItem.rightBarButtonItems = [doneProcess,shareProcess]
        
        navigationItem.hidesBackButton = true
        if recoveredReciept != "" {
        print ("in reciept") ;presentReciept()
        } else {
        print ("in bill"); presentBill()} }
        
        deleteBtn.isEnabled = true
        
    } ///end of did load/////////////////////////////////////////////////////////////////////////////////////////////////////
    
            func presentReciept(){
            billReciept.isHidden = true
            print (recoveredReciept)
            recieptChosen = true
            self.attributedText(attributed: self.recoveredReciept)
            }

            func presentBill(){
            billReciept.isHidden = true
            self.recieptChosen = false
            self.attributedText(attributed: self.recoveredBill)
            }
   
            func returnToList(){
            print ("return")
            if recieptChosen == false {
            ViewController.billsPusher = true
            self.navigationController!.popToRootViewController(animated: false)
                } else {
                
                self.navigationController!.popViewController(animated: true)}
            //self.present((storyboard?.instantiateViewController(withIdentifier: "homeScreen"))!, animated: true, completion: nil)
            }
    
            func undo(){
            print (self.recieptChosen)
            if self.recieptChosen == true {
            if Int(undoBalance!) != Int(self.undoTotal!) {self.statusForUndo = "Partially"} else {self.statusForUndo  = "Billed"}
            self.dbRefEmployee.child(self.employeeID).child("myBills").child(String("-\(self.documentCounter!)")!).updateChildValues(["fBillStatus": self.statusForUndo!, "fBillStatusDate": self.mydateFormat5.string(from: Date()) ,"fRecieptCounter":String(Int(undoRecieptCounter!)!), "fBalance": undoBalance!
            ], withCompletionBlock: { (error) in}) //end of update.
            // delete reciept
            self.dbRefEmployee.child(self.employeeID).child("myReciepts").child(String("-\(self.documentCounter!)")!).child(self.undoRecieptCounter!).removeValue()
            self.dbRefEmployer.child(self.employerID).updateChildValues(["fLast":lastPrevious], withCompletionBlock: { (error) in})
            
            self.navigationController!.popViewController(animated: true)
            }// end reciept
            else {//begininng invoice
            self.dbRefEmployee.child(self.employeeID).child("myBills").child(String("-\(self.documentCounter!)")!).removeValue()
            self.dbRefEmployee.child(self.employeeID).updateChildValues(["fCounter":String(Int(self.documentCounter!)!)])
            self.moveSessionToBilled()
            self.dbRefEmployer.child(self.employerID).updateChildValues(["fLast":lastPrevious], withCompletionBlock: { (error) in})
            ViewController.sessionPusher = true
            self.navigationController!.popToRootViewController(animated: false)
            }//end of else
            }//end of undo
    
            func reReciept(){
            self.dbRefEmployee.child(employeeID).child("myReciepts").child(billToHandle!).child(self.recieptsArray2[self.billReciept.selectedSegmentIndex-1]).observeSingleEvent(of: .value,with: { (snapshot) in
            self.recoveredReciept = (snapshot.childSnapshot(forPath: "fBillRecieptMailSaver").value! as? String)!
            self.recieptStatus = (snapshot.childSnapshot(forPath: "fActive").value! as? String)!
            self.document = (snapshot.childSnapshot(forPath: "fDocument").value! as? String)!
            self.recieptPayment = (snapshot.childSnapshot(forPath: "fRecieptAmount").value! as? String)!
            // self.documentCounter = (snapshot.childSnapshot(forPath: "fBill").value! as? String)!
            if self.recieptStatus !=  "Yes" {
            self.statusImage.image = self.canceledImage;
            self.deleteBtn.isEnabled = false;self.billStatusForRecovery = "!!!!!!!!!!This document was cancelled: \(self.mydateFormat8.string(from: self.mydateFormat5.date(from: self.recieptStatus!)! ))!!!!!!!!!!"} else {self.deleteBtn.isEnabled = true;
                
                self.billStatusForRecovery = ""}
                

            if self.taxBillsToHandle == true {
                self.deleteBtn.isEnabled = false
                }
            self.attributedText(attributed: self.recoveredReciept)
            } , withCancel: { (Error) in
                self.alert30()
                print("error from FB")})
            }//end of rerreciept

            func  reBill() {
            self.billStatusForRecovery = ""
            recieptsArray2.removeAll()
            self.dbRefEmployee.child(employeeID).child("myBills").child(billToHandle!).observeSingleEvent(of: .value,with: { (snapshot) in
            self.recoveredBill = (snapshot.childSnapshot(forPath: "fBillMailSaver").value! as? String)!
            if (snapshot.childSnapshot(forPath: "fBillStatusDate").value! as? String) != nil {self.statusCanclledDate = (snapshot.childSnapshot(forPath: "fBillStatusDate").value! as? String)!}
            self.recoveredStatus = (snapshot.childSnapshot(forPath: "fBillStatus").value! as? String)!
            self.document = (snapshot.childSnapshot(forPath: "fDocumentName").value! as? String)!
            self.documentCounter = (snapshot.childSnapshot(forPath: "fBill").value! as? String)!
            self.balance = (snapshot.childSnapshot(forPath: "fBalance").value! as? String)!
            self.titleLbl = "\(self.document!)"
            self.title = self.titleLbl

            if self.recoveredStatus == "Billed"  { self.deleteBtn.isEnabled = true;self.billStatusForRecovery = ""}
            if self.recoveredStatus == "Partially"  { self.deleteBtn.isEnabled = true;self.billStatusForRecovery = ""}
            if  self.recoveredStatus  == "Paid" { self.deleteBtn.isEnabled = true;self.billStatusForRecovery = ""}
            if self.recoveredStatus ==  "Cancelled" {
            self.statusImage.image = self.canceledImage;
            self.deleteBtn.isEnabled = false;self.billStatusForRecovery = "!!!!!!!!!!This document was cancelled: \(self.mydateFormat8.string(from: self.mydateFormat5.date(from: self.statusCanclledDate!)! ))!!!!!!!!!!"}
            if self.taxBillsToHandle == true {self.deleteBtn.isEnabled = false}
            self.attributedText(attributed: self.recoveredBill)

            //build reciepts
            self.dbRefEmployee.child(self.employeeID).child("myReciepts").child(self.billToHandle!).observe(.childAdded ,with: { (snapshot) in
           
            self.recieptsArray2.append((snapshot.key))
            
            // remove all current segments to make sure it is empty:
            self.billReciept.removeAllSegments()
            if self.recieptsArray2.isEmpty{
            print (" (self.recieptsArray)is empty")
            self.billReciept.isHidden = true
            }else{
            self.billReciept.isHidden = false
            print ("create reciepts segments")
            // adding your segments, using the "for" loop is just for demonstration:
            for index in 0...self.recieptsArray2.count-1 {
            self.billReciept.insertSegment(withTitle: "Rec-\(index + 1)", at: index, animated: false)
            }
            self.billReciept.insertSegment(withTitle: "Invoice", at: 0, animated: true)
            }
            } , withCancel: { (Error) in
                self.alert30()
                print("error from FB")})
            if self.recieptsArray2.isEmpty{
            print (" (self.recieptsArray)is empty")
            self.billReciept.isHidden = true}
            } , withCancel: { (Error) in
                self.alert30()
                print("error from FB")})
            }//end rebill clicked

            func attributedText(attributed:String) {
            if recieptChosen == false { self.textString = "\(self.document!)\r\n\(self.billStatusForRecovery)\r\n\r\n\(attributed)"
            } else {
            self.textString = "\(self.document!)\r\n\(self.billStatusForRecovery)\r\n\r\n\(attributed)"}
                let attrText = NSMutableAttributedString(string: textString)
            if recieptChosen == false { self.largeTextRange = (textString as NSString).range(of: "\(self.document!)");self.centerTextRange = (textString as NSString).range(of: "\(self.billStatusForRecovery)"); self.smallTextRange = (textString as NSString).range(of: "\r\n\r\n\(attributed)")
            } else {
            self.largeTextRange = (textString as NSString).range(of: "\(self.document!)");self.centerTextRange = (textString as NSString).range(of: "\(self.billStatusForRecovery)");self.smallTextRange = (textString as NSString).range(of: ")\r\n\r\n\(attributed)")}
            paragraph.alignment = .center
            attrText.addAttribute(NSFontAttributeName, value: self.smallFont, range: smallTextRange!)
            attrText.addAttribute(NSFontAttributeName, value: self.largeFont, range: largeTextRange!)
            attrText.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: largeTextRange!)
            attrText.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: centerTextRange!)
            
            self.pdfData =  createPDFFilea(atext: attrText)
            }//end of attributed

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
            if self.rebillprocess != true {
                print ("delete btn not enables")
                self.deleteBtn.isEnabled = false}
            controller.dismiss(animated: true, completion: nil)
                
            case MFMailComposeResult.sent.rawValue:
            print("Mail sent3")
            if self.rebillprocess != true {
                print ("delete btn not enables")
                self.deleteBtn.isEnabled = false}
            controller.dismiss(animated: true, completion: nil)
            

            case MFMailComposeResult.failed.rawValue:
            print("Mail sent failure: %@", [error!.localizedDescription])
            controller.dismiss(animated: true, completion: nil)
            
            default:
            break
            }
            }

            func  moveSessionToBilled() {
            print ("moveSessionToBilled")
            for h in 0...(undoArray.count-1){
            self.dbRef.child(String(undoArray[h])).updateChildValues(["fStatus": "Approved"], withCompletionBlock: { (error) in}) //end of update.
            }//end of loop
            }//end movesession

            func createURL() {
            guard
            var documentsURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last
            else {//handle error when getting documents URL
            return
            }
            documentsURL.appendPathComponent("BillToWebView.pdf")
            do {
            try pdfData.write(to: documentsURL)
            let myURL = documentsURL //URL(string:document"BillToWebView.pdf" )
            let myRequest = URLRequest(url: myURL)
                
            webView2.scalesPageToFit = true
            webView2.loadRequest(myRequest)
            } catch {
            //handle write error here
            }
            print("url\(documentsURL)")
            }

            func createPDFFilea(atext: NSAttributedString) -> NSMutableData {
            createPDFwithAttributedString(atext)
            createURL()
            return pdfData
            }// end of create pdf

    func createPDFwithAttributedString(_ currentText: NSAttributedString){//} -> NSMutableData {
            // Create the PDF context using the default page size of 612 x 792.
            UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)

            let framesetter = CTFramesetterCreateWithAttributedString(currentText)
            var currentRange = CFRangeMake(0, 0);
            var currentPage = 0;
            var done = false;

            repeat {
            // Mark the beginning of a new page.
            UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: 612, height: 792), nil);

            // Draw a page number at the bottom of each page.
            currentPage += 1;

            // Render the current page and update the current range to
            // point to the beginning of the next page.

            renderPagewithTextRange(currentRange: &currentRange, framesetter: framesetter)

            // If we're at the end of the text, exit the loop.
            if (currentRange.location == CFAttributedStringGetLength(currentText)){
            done = true;
            }
            } while (!done);

            // Close the PDF context and write the contents out.
            UIGraphicsEndPDFContext();
            //return pdfData
            }

            func renderPagewithTextRange (currentRange: inout CFRange,  framesetter: CTFramesetter) {
            // Get the graphics context.
            if let currentContext = UIGraphicsGetCurrentContext(){

            // Put the text matrix into a known state. This ensures
            // that no old scaling factors are left in place.
            currentContext.textMatrix = CGAffineTransform.identity;

            // Create a path object to enclose the text. Use 72 point
            // margins all around the text.
            let frameRect = CGRect(x: 72, y: 72, width: 468, height: 648);
            let imageRect = CGRect(x: 500, y: 690, width: 100, height: 100);
            let paperA4 = CGRect(x: 0, y: 0, width: 712, height: 992);
            //let pageWithMargin = CGRect(x: 0, y: -50, width: paperA4.width-50, height: (paperA4.height-50));
            //let paperRect = CGRect(x: 30, y: 30, width: 512, height:(781.8))
            let framePath = CGMutablePath();
            framePath.addRect(frameRect)


            // Get the frame that will do the rendering.
            // The currentRange variable specifies only the starting point. The framesetter
            // lays out as much text as will fit into the frame.
            let frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, nil);

            // Core Text draws from the bottom-left corner up, so flip
            // the current transform prior to drawing.
            currentContext.translateBy(x: 0, y: 792);
            currentContext.scaleBy(x: 1.0, y: -1.0);

            // Draw the frame.

            currentContext.setFillColor(grayColor.cgColor)
            currentContext.fill(paperA4)
            //currentContext.makeImage
            CTFrameDraw(frameRef, currentContext);
            currentContext.draw((logoImage?.cgImage)!, in: imageRect)

            // Update the current range based on what was drawn.
            currentRange = CTFrameGetVisibleStringRange(frameRef);
            currentRange.location += currentRange.length;
            currentRange.length = 0;
            }
            }

    //alerts//////////////////////////////////////////////////
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
        }

        let printAction = UIAlertAction(title: "Print", style: .default) { (UIAlertAction) in
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = "My Print Job"

       let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.printingItem =  self.pdfData
        
            
        //var viewpf:UIViewPrintFormatter = self.documentsFileName.viewPrintFormatter()
        //  var viewpf:UIViewPrintFormatter = self.mailView.viewPrintFormatter()
        //printController.printFormatter = viewpf
        printController.present(animated: true) { (controller, success, error) -> Void in
            if success {
                // Printed successfully
                if      self.rebillprocess != true {
                    print ("delete btn not enables")
                    
                    self.deleteBtn.isEnabled = false
                    
                    //ViewController.billsPusher = true
                    // self.navigationController!.popToRootViewController(animated: false)
                    
                } else {
                    print ("old reciept")
                    
                }
            } else {
                print ("printing not occured")
                //   if deleteBtn.isEnabled == true{ self.deleteBtn.isEnabled = true}
                
                // Printing failed, report error ...
            }
            }//end of present
            
            }
        alertController5.addAction(mailAction)
        alertController5.addAction(printAction)
        alertController5.addAction(CancelAction)
        self.present(alertController5, animated: true, completion: nil)
        }

    
        func alert6(){
        let alertController6 = UIAlertController(title: ("Share") , message: "", preferredStyle: .alert)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        //do nothing
        }
        let mailAction = UIAlertAction(title: "Mail", style: .default) { (UIAlertAction) in
        let mailComposeViewController2 = self.configuredMailComposeViewController4()
        if MFMailComposeViewController.canSendMail() {
        self.present(mailComposeViewController2, animated: true, completion: nil)
        } //end of if
        else{ self.showSendmailErrorAlert() }
        }
        let printAction = UIAlertAction(title: "Print", style: .default) { (UIAlertAction) in
            let printInfo = UIPrintInfo(dictionary:nil)
            printInfo.outputType = UIPrintInfoOutputType.general
            printInfo.jobName = "My Print Job"
            
            let printController = UIPrintInteractionController.shared
            printController.printInfo = printInfo
            printController.printingItem =  self.pdfData
            
           // self.deleteBtn.isEnabled = false
            
            //var viewpf:UIViewPrintFormatter = self.documentsFileName.viewPrintFormatter()
            //  var viewpf:UIViewPrintFormatter = self.mailView.viewPrintFormatter()
            //printController.printFormatter = viewpf
            printController.present(animated: true) { (controller, success, error) -> Void in
                if success {
                    // Printed successfully
                    if      self.rebillprocess != true {
                    print ("delete btn not enables")
                    
                    self.deleteBtn.isEnabled = false
                    
                    //ViewController.billsPusher = true
                    // self.navigationController!.popToRootViewController(animated: false)
                    
                } else {
                 print ("old reciept")
                        
                    }
            } else {
                     print ("printing not occured")
                 //   if deleteBtn.isEnabled == true{ self.deleteBtn.isEnabled = true}
                    
                // Printing failed, report error ...
            }
            }//end of present
            
            }
        alertController6.addAction(mailAction)
        alertController6.addAction(printAction)
        alertController6.addAction(CancelAction)
        self.present(alertController6, animated: true, completion: nil)
        }

        func deleteAlert () {
        if recieptChosen == false && recieptsArray2.isEmpty == false {self.alertExtension = " Deleting invoice would delete also all related reciepts."} else { self.alertExtension = ""}
        let alertController = UIAlertController(title: "Delete Alert", message: "You are about to delete \(self.document!).\(self.alertExtension!) Are You Sure?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        //nothing
        }
        let deleteAction = UIAlertAction(title: "Delete it.", style: .default) { (UIAlertAction) in
            print (self.recieptChosen)
            
        if self.recieptChosen == false {
        self.dbRefEmployee.child(self.employeeID).child("myBills").child(String(self.billToHandle!)).updateChildValues([ "fBillStatus":"Cancelled","fBillStatusDate": self.mydateFormat5.string(from: Date())])

        //add effect on the reciepts
        if self.recieptsArray2.isEmpty  == false {
        for rec in 1...self.recieptsArray2.count
        {self.dbRefEmployee.child(self.employeeID).child("myReciepts").child(String("-\(self.documentCounter!)")!).child(String(rec)).updateChildValues(["fActive" : self.mydateFormat5.string(from: Date())])
        }}//end of reciept is empty
            ViewController.billsPusher = true
            
            if biller.statusMemory != nil {
                if biller.statusMemory! == 1 {self.navigationController!.popViewController(animated: true)} else  {self.navigationController!.popToRootViewController(animated: false);ViewController.billsPusher = false} }else {
                ViewController.billsPusher = false; self.navigationController!.popViewController(animated: true)
            }
        }//end of reciept = false
        else {self.deleteReciept()}
        }//end of deleteaction

        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
        }
    
        func deleteReciept(){
        self.dbRefEmployee.child(self.employeeID).child("myBills").child(String("-\(self.documentCounter!)")!).updateChildValues(["fBillStatus": "Partially", "fBalance":String (Double(balance!)! + Double(recieptPayment!)!)], withCompletionBlock: { (error) in}) //end of update.
        self.dbRefEmployee.child(self.employeeID).child("myReciepts").child(String("-\(self.documentCounter!)")!).child(String(billReciept.selectedSegmentIndex)).updateChildValues(["fActive" : self.mydateFormat5.string(from: Date())])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0){
            
        self.navigationController!.popViewController(animated: true)
        }//end of dispatch
        }
    
        }//end of class///////////////////////////////////////////////////////////////////////////////////////

        extension UIView {
        func toImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)

        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
            
        }
          
        }//end of extension////////////////////////////////////////////

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
                print("Connected after all")} else  {print("not connected after all");self.alert30()}
            })
            }}
            })
            }
        
            

        func alert30(){
        let alertController30 = UIAlertController(title: ("No connection") , message: "Currently there is no connection with database. Please try again in few minutes.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        self.navigationController!.popToRootViewController(animated: false)
        }
        alertController30.addAction(OKAction)
        self.present(alertController30, animated: true, completion: nil)
        }
        func alert50(){
        let alertController50 = UIAlertController(title: ("Internet Connection") , message: " There is no internet - Check communication avilability.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        self.navigationController!.popToRootViewController(animated: false)
        }
        
        alertController50.addAction(OKAction)
        self.present(alertController50, animated: true, completion: nil)
    }
    }//end of extension


    


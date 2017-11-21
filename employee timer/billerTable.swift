//
//  billerTable.swift
//  employee timer
//
//  Created by אורי עינת on 19.2.2017.
//  Copyright © 2017 אורי עינת. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import MessageUI


class biller: UIViewController, UITableViewDelegate,UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    
    @IBOutlet weak var billerConnect: UITableView!
    
    var billItems = [billStruct]()
    static var checkBoxBiller:Int = 0
    var BillArrayStatus = [String]()
    var BillArray = [String]()
    var statusTemp = "Billed"

    var billCounter = 0
    var taxCounter = 0.0
    var AmountCounter = 0.0

    var titleLbl = ""
    
    let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
    let Vimage = UIImage(named: "due")
    let nonVimage = UIImage(named: "emptyV")
    let paidImage = UIImage(named: "paid")
    let billedImage = UIImage(named: "locked")
    let billIcon = UIImage(named: "bill")
    let canceledImage = UIImage(named: "cancelled")
    
    var StatusChoice = "Not Paid"
      var buttonRow = 0
    
    var recoveredBill:String?
    
    var cellId = "billerId"
    @IBOutlet weak var thinking: UIActivityIndicatorView!
    @IBOutlet weak var PeriodChosen: UISegmentedControl!
    @IBOutlet weak var StatusChosen: UISegmentedControl!
    
    @IBOutlet weak var totalBills: UITextField!
    @IBOutlet weak var totalTax: UITextField!
    @IBOutlet weak var totalAmount: UITextField!
    
    

    var whiteColor = UIColor(red :255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    var greenColor = UIColor(red :32.0/255.0, green: 150.0/255.0, blue: 24.0/255.0, alpha: 1.0)
    var blueColor = UIColor(red :22/255.0, green: 131/255.0, blue: 248/255.0, alpha: 1.0)

    //variablesfrom main
    var employerID = ""
    var employerFromMain = ""
    var employeeID = ""

    //variabled for date filtering
    let mydateFormat = DateFormatter()
    let mydateFormat2 = DateFormatter()
    let mydateFormat3 = DateFormatter()
    let mydateFormat5 = DateFormatter()
    let mydateFormat6 = DateFormatter()
    let mydateFormat10 = DateFormatter()

    
    let dbRef = FIRDatabase.database().reference().child("fRecords")
    let dbRefEmployers = FIRDatabase.database().reference().child("fEmployers")
    let dbRefEmployees = FIRDatabase.database().reference().child("fEmployees")
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        billerConnect.backgroundColor = UIColor.clear
        if employerID != "" {  titleLbl = "\(employerFromMain)'s bills" } else {titleLbl = "Bills"}
        
        self.title = titleLbl
        
        self.view.insertSubview(backgroundImage, at: 0)
        
     
        
        //connectivity
        if Reachability.isConnectedToNetwork() == true
        {
            print("Internet Connection Available!")
        }
        else
        {
            print("Internet Connection not Available!")
        }
        
        let formatter = NumberFormatter()

        
        //formatting decimal
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.roundingMode = .up
        
        
        //formating the date
        mydateFormat.dateFormat = DateFormatter.dateFormat(fromTemplate:  " EEE-dd-MMM-yyyy, (HH:mm)"
            ,options: 0, locale: nil)!
        mydateFormat2.dateFormat = DateFormatter.dateFormat(fromTemplate:  " HH:mm"
            , options: 0, locale: nil)!
        mydateFormat3.dateFormat = DateFormatter.dateFormat(fromTemplate:  " MM/dd/yyyy"
            , options: 0, locale: nil)!
        mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)"
            ,options: 0, locale: nil)!
        mydateFormat6.dateFormat = DateFormatter.dateFormat(fromTemplate: " EEE-dd-MMM-yyyy, (HH:mm)", options: 0, locale: nil)!
        mydateFormat10.dateFormat = DateFormatter.dateFormat(fromTemplate: " MMM d, yyyy", options: 0, locale: Locale.autoupdatingCurrent)!

        self.StatusChoice = "All"
        
        self.billerConnect.separatorColor = blueColor



        
    billerConnect.delegate = self
    billerConnect.dataSource = self
    }//end of view did load//////////////////////////////////////////////////////////////////////////
    
    override func viewDidAppear(_ animated: Bool) {
        let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                print("Connected")
                
                
            }
                
                
            else {
                
                print("Not connected")
                
                
                // Delay 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0){
                    connectedRef.observe(.value, with: { snapshot in
                        if let connected = snapshot.value as? Bool, connected {
                            print("Connected after all")} else  {print("not connected after all");self.noFB()}
                    })
                }}
            
        })
        
       
        fetchBills()
        print (billItems.count)
        billerConnect.reloadData()
        
    }//view did appear end
    
    func tableView(_ billerConnect: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    

    
    func tableView(_ billerConnect: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print (billItems.count)
        return billItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = billerConnect.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! billerCell
        
        
        let billItem = billItems[indexPath.row]
        
        cell.backgroundColor = UIColor.clear
        


        cell.l1.text = ("\(billItem.fBill!) - \(mydateFormat10.string(from: mydateFormat5.date(from: billItem.fBillDate!)!)) ")
        print ("fuf\(billItem.fBillTotalTotal!)" )
        print ("fuf2\(billItem.fBillTotalTotal!)" )
        
        if billItem.fBillTotalTotal != "" {cell.l3.text = billItem.fBillTotalTotal} else {cell.l3.text = billItem.fBillSum}
        cell.l4.text  = billItem.fBillCurrency!
        cell.l6.text = "\(billItem.fBillEmployerName!)"
        
        print("fbillstatus\(billItem.fBillStatus!)")
        
        if billItem.fBillStatus! == "Billed" { cell.approval.setImage(nonVimage, for: .normal);cell.l1.alpha = 1;cell.l3.alpha = 1;cell.l4.alpha = 1;cell.l6.alpha = 1;cell.approval.alpha = 1}
        if  billItem.fBillStatus!  == "Paid" { cell.approval.setImage(paidImage, for: .normal);cell.l1.alpha = 1;cell.l3.alpha = 1;cell.l4.alpha = 1;cell.l6.alpha = 1;cell.approval.alpha = 1}
        if billItem.fBillStatus! ==  "Cancelled" { cell.approval.setImage(canceledImage,for: .normal);cell.l1.alpha = 0.5;cell.l3.alpha = 0.5;cell.l4.alpha = 0.5;cell.l6.alpha = 0.5}


        cell.approval.tag = indexPath.row
        print ("gggggg\(cell.approval.tag)")
        
        cell.approval.removeTarget(self, action:#selector(self.approvalClicked), for: UIControlEvents.touchDown)
        cell.approval.addTarget(self, action:#selector(self.approvalClicked), for: UIControlEvents.touchDown)
        
        
       // cell.billResender.removeTarget(self, action:#selector(self.reSend), for: UIControlEvents.touchDown)
       // cell.billResender.addTarget(self, action:#selector(self.reSend), for: UIControlEvents.touchDown)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var billRow : IndexPath = self.billerConnect.indexPathForSelectedRow!
        print (billRow)
        if (segue.identifier == "billHandler")
        { let billManager = segue.destination as? billView
            print ("presparesegue")
            billManager?.billToHandle = "-"+String(BillArray[billRow.row])
            billManager?.employeeID = employeeID
           
        }//end of if (segue...
        
        
    }//end of prepare
    
    func fetchBills(){
        //dbRefEmployees.removeAllObservers()
        billItems.removeAll()
        BillArray.removeAll()
        BillArrayStatus.removeAll()
        self.billCounter = 0
        self.taxCounter = 0
        self.AmountCounter = 0

        
        print ("fetch bills")
        print(employeeID)
        print(employerID)
        self.dbRefEmployees.child(employeeID).child("myBills").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary =  snapshot.value as? [String: AnyObject] {
                print ("snappp\(snapshot.value!)")

                print("!!!!!")
                let billItem = billStruct()
                billItem.setValuesForKeys(dictionary)
                print ("dic :\(dictionary)")
                
                
                if self .employerID != ""{
                if self.StatusChoice == "Not Paid" && billItem.fBillStatus == "Billed" && billItem.fBillEmployer == self.employerID {
                    self.billItems.append(billItem); self.billCounter+=1 ;self.AmountCounter += Double(billItem.fBillTotalTotal!)!;self.taxCounter += Double(billItem.fBillTax!)!
                    ; self.BillArray.append(billItem.fBill!); self.BillArrayStatus.append(billItem.fBillStatus!)} else  if self.StatusChoice == "All" && billItem.fBillEmployer == self.employerID  {self.billItems.append(billItem);self.billCounter+=1; self.AmountCounter += Double(billItem.fBillTotalTotal!)!;self.taxCounter += Double(billItem.fBillTax!)!;self.BillArray.append(billItem.fBill!);self.BillArrayStatus.append(billItem.fBillStatus!)}
                }
                if self .employerID == "" {
                    if self.StatusChoice == "All"  {self.billItems.append(billItem);self.billCounter+=1; self.AmountCounter += (Double(billItem.fBillTotalTotal!)!);  self.taxCounter += Double(billItem.fBillTax!)!;            self.BillArray.append(billItem.fBill!);self.BillArrayStatus.append(billItem.fBillStatus!)}

                    else if self.StatusChoice == "Not Paid" &&  billItem.fBillStatus == "Billed"  {self.billItems.append(billItem);self.billCounter+=1; self.AmountCounter += Double(billItem.fBillTotalTotal!)!;self.taxCounter += Double(billItem.fBillTax!)!;self.BillArray.append(billItem.fBill!);self.BillArrayStatus.append(billItem.fBillStatus!)}
                }
              
                self.totalBills.text = "\(String(describing: self.billItems.count)) Bills"
                self.totalAmount.text = "Total \(ViewController.fixedCurrency!)\(String(describing: self.AmountCounter))"
                self.totalTax.text = "Tax \(ViewController.fixedCurrency!)\(String (describing: self.taxCounter))"

                self.billerConnect.reloadData()
                print (self.billItems.count)

            }
        })
      //  if billItems.count = 0 {noSign.isHidden = false} else {noSign.isHidden = true}
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            if self.billItems.count != self.BillArray.count {
                
                print ("Stop")
            }
        self.thinking.isHidden = true
        
        self.thinking.stopAnimating()
        
        self.StatusChosen.isEnabled = true
        }

    }//end of fetch
    
    @IBAction func StatusChosen(_ sender: Any) {
        print("pressed")
        //noSign.isHidden = true
        //saveToFB() //check why is it here?
        self.thinking.isHidden = false
        self.thinking.startAnimating()
        StatusChosen.isEnabled = false
        PeriodChosen.isEnabled = false
        switch StatusChosen.selectedSegmentIndex {
        case 0: StatusChoice = "Not Paid"
        case 1: StatusChoice = "All"
        default: break
        } //end of switch
        
        fetchBills()
    }
    
    // button on table clicked
    func  approvalClicked(sender:UIButton!) {
        self.StatusChosen.isEnabled = false

        print("clicked")
        buttonRow = sender.tag
        print (buttonRow)
        print (billItems)
        print(BillArray[buttonRow])

        print( BillArrayStatus)

        print( BillArrayStatus[buttonRow])
        
        
         if BillArrayStatus[buttonRow] != "Cancelled" { if BillArrayStatus[buttonRow] == "Billed" {  statusTemp = "Paid"
            self.dbRefEmployees.child(employeeID).child("myBills").child(String("-"+BillArray[buttonRow])).updateChildValues(["fBillStatus": statusTemp, "fBillStatusDate":
                mydateFormat5.string(from: Date())//was 3
                
                
                ], withCompletionBlock: { (error) in}) //end of update.
            BillArrayStatus[buttonRow] = statusTemp
         
         }
        else if BillArrayStatus[buttonRow] == "Paid" {  if StatusChoice == "Not Paid" { statusTemp = "Billed"
            self.dbRefEmployees.child(employeeID).child("myBills").child(String("-"+BillArray[buttonRow])).updateChildValues(["fBillStatus": statusTemp, "fBillStatusDate":
                mydateFormat5.string(from: Date())//was 3
                
                
                ], withCompletionBlock: { (error) in}) //end of update.
            BillArrayStatus[buttonRow] = statusTemp
         
         } else {alert3()}}
            
            

        }
        else {alert9()}
        
    //refresh
        
        if StatusChoice == "Not Paid"{
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){

        self.StatusChosen.isMomentary = true
        self.StatusChosen.selectedSegmentIndex = 0
        self.StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
        self.StatusChosen.isMomentary = false
            self.StatusChosen.isEnabled = true


            }} else {   DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                self.StatusChosen.isEnabled = true

                }

        }
    
    
    }//end button clicked

    func  reSend(sender:UIButton!) {
        
        print("resend")
        buttonRow = sender.tag
        print (buttonRow)
        print( BillArrayStatus[buttonRow])
        print(BillArray[buttonRow])
        
        alert5()
        
        
        self.dbRefEmployees.child(employeeID).child("myBills").child(String(BillArray[buttonRow])).observeSingleEvent(of: .value,with: { (snapshot) in
        
             self.recoveredBill = snapshot.childSnapshot(forPath: "fBillMailSaver").value! as? String
                print("recovered")
                
                
            
        
        })
        
    }//end resend clicked
    
    func noFB() {
        
        self.thinking.stopAnimating()
        self.alert30()
        
    }
    
    ////mail section
    
    //func for mail
    func  configuredMailComposeViewController2() -> MFMailComposeViewController {
        let mailComposerVC2 = MFMailComposeViewController()
        mailComposerVC2.mailComposeDelegate = self
        mailComposerVC2.setSubject("Bill recovery")
        mailComposerVC2.setMessageBody(recoveredBill!, isHTML: false)
        mailComposerVC2.setToRecipients([ViewController.fixedemail])
        //mailComposerVC2.setCcRecipients([ViewController.fixedemail])
       
        
        return mailComposerVC2
    }//end of MFMailcomposer
    
    func showSendmailErrorAlert() {
        let sendMailErorrAlert = UIAlertController(title:"Could Not Send Email", message: "Your device could not send e-mail. Please check e-mail configuration and try again.",preferredStyle: .alert)
        sendMailErorrAlert.message = "error occured"
        //seems that it does not work check!!!!
    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
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
        
        
    }
    
    // alerts/////////////////////////////////////////////////////////////////////////////////////
    func alert30(){
        let alertController30 = UIAlertController(title: ("No connection") , message: "Currently there is no connection with database. Please try again.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        }
        
        alertController30.addAction(OKAction)
        self.present(alertController30, animated: true, completion: nil)
    }
    
    func alert5(){
        let alertController5 = UIAlertController(title: ("Bill Recovery") , message: "Do you want to recover the original bill generated by  PerSession and send it to you?", preferredStyle: .alert)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            //do nothing
        }
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            let mailComposeViewController2 = self.configuredMailComposeViewController2()
            if MFMailComposeViewController.canSendMail() {
                
                self.present(mailComposeViewController2, animated: true, completion: nil)
            } //end of if
            else{ self.showSendmailErrorAlert() }
            // navigationController!.popViewController(animated: true)
            
        }
        
        alertController5.addAction(CancelAction)
        alertController5.addAction(OKAction)
        self.present(alertController5, animated: true, completion: nil)
    }
    
    func alert9(){
        let alertController9 = UIAlertController(title: ("Bill Alert") , message: "You can't change status of a cancelled Bill.", preferredStyle: .alert)
        let OkAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            //do nothing
        }
        
        alertController9.addAction(OkAction)
        self.present(alertController9, animated: true, completion: nil)
    }
    
    
        
    func alert3(){
        let alertController3 = UIAlertController(title: ("Bill Alert") , message: "You are about to cancel payment for a bill that was already marked as paid. Are you Sure?", preferredStyle: .alert)
        
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            biller.checkBoxBiller = 1
            //do nothing
            self.StatusChosen.isMomentary = true
            self.StatusChosen.selectedSegmentIndex = 1
            
            self.StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
            
            self.StatusChosen.isMomentary = false

        }
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
             self.statusTemp = "Billed"
        
        self.BillArrayStatus[self.buttonRow] = self.statusTemp
        
            self.dbRefEmployees.child(self.employeeID).child("myBills").child(String("-"+self.BillArray[self.buttonRow])).updateChildValues(["fBillStatus": self.statusTemp ,"fBillStatusDate":self.mydateFormat5.string(from: Date())], withCompletionBlock: { (error) in}) //end of update.//was 3
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){

            self.StatusChosen.isMomentary = true
            self.StatusChosen.selectedSegmentIndex = 1
            
            self.StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
            
            self.StatusChosen.isMomentary = false
            }

        }
        
        alertController3.addAction(OKAction)
        alertController3.addAction(CancelAction)

        self.present(alertController3, animated: true, completion: nil)
    }
}//end of class

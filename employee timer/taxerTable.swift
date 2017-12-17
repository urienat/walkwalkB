//
//  taxerTable.swift
//  perSession
//
//  Created by Uri Enat on 12/17/17.
//  Copyright © 2017 אורי עינת. All rights reserved.
//

import Foundation
import Foundation
import UIKit
import Firebase
import MessageUI


class taxer: UIViewController, UITableViewDelegate,UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    //let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
    let Vimage = UIImage(named: "due")
    let nonVimage = UIImage(named: "emptyV")
    let paidImage = UIImage(named: "paid")
    let canceledImage = UIImage(named: "cancelled")
    //let greenFilter = UIImage(named: "sandWatchGreen")
    let greenFilter = UIImage(named: "sandWatchBig")
    let redFilter = UIImage(named: "sandWatchRed")
    var blueColor = UIColor(red :22/255.0, green: 131/255.0, blue: 248/255.0, alpha: 1.0)
    
    
    var byMonthTax = [String:Double]()
    var byMonthTotalTax = [String]()
    var uniqueTaxMonths = [String]()
    var billItems = [billStruct]()
    static var checkBoxBiller:Int = 0
    var BillArrayStatus = [String]()
    var BillArray = [String]()
    var statusTemp = "Billed"
    var StatusChoice = "Not Paid"
    var buttonRow = 0
    var recoveredBill:String?
    var titleLbl = ""
    var cellId = "billerId"
    var billCounter = 0
    var taxCounter = 0.0
    var AmountCounter = 0.0
    var isFilterHidden = true
    var filterDecided :Int = 0
    
    var calendar = Calendar.current
    var recordMonth : Int = 0
    var recordYear : Int = 0
    var currentMonth : Int = 0
    var currentYear : Int = 0
    
    @IBOutlet weak var billerConnect: UITableView!
    @IBOutlet weak var thinking: UIActivityIndicatorView!
    @IBOutlet weak var StatusChosen: UISegmentedControl!
    @IBOutlet weak var totalBills: UITextField!
    @IBOutlet weak var totalTax: UITextField!
    @IBOutlet weak var totalAmount: UITextField!
    @IBOutlet weak var noSign: UIImageView!
    
    //filter
    @IBOutlet weak var filterChoiceImage: UIImageView!
    @IBOutlet weak var filterImageConstrain: NSLayoutConstraint!
    @IBOutlet weak var filterConstrain: NSLayoutConstraint!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var filterBG: UIView!
    @IBOutlet weak var filter: UIButton!
    @IBAction func filter(_ sender: Any) {
        filterMovement(delay: 0)
    }
    @IBAction func noneBtn(_ sender: Any) {
        filterDecided = 0
        taxCalc()
        filterImageConstrain.constant = 20
        filter.setImage(greenFilter, for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.filterMovement(delay: 1.3)
        }
    }
    
    @IBAction func currentMonthBtn(_ sender: Any) {
        filterDecided = 1
        taxCalc()
        filterImageConstrain.constant = 60
        filterChoiceImage.reloadInputViews()
        
        filter.setImage(redFilter, for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.filterMovement(delay: 1.3)
        }
    }
    
    @IBAction func lastMonthBtn(_ sender: Any) {
        filterImageConstrain.constant = 100
        filterDecided = 2
        taxCalc()
        filter.setImage(redFilter, for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.filterMovement(delay: 1.3)
        }
    }
    
    @IBAction func currentYearBtn(_ sender: Any) {
        filterImageConstrain.constant = 140
        filterDecided = 3
        taxCalc()
        filter.setImage(redFilter, for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.filterMovement(delay: 1.3)
        }
    }
    
    @IBAction func lastYearBtn(_ sender: Any) {
        filterImageConstrain.constant = 180
        filterDecided = 4
        taxCalc()
        filter.setImage(redFilter, for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.filterMovement(delay: 1.3)
        }
    }
    
    //variablesfrom main
    var employerID = ""
    var employerFromMain = ""
    var employeeID = ""
    
    let mydateFormat5 = DateFormatter()
    let mydateFormat10 = DateFormatter()
    let mydateFormat20 = DateFormatter()

    
    let dbRef = FIRDatabase.database().reference().child("fRecords")
    let dbRefEmployers = FIRDatabase.database().reference().child("fEmployers")
    let dbRefEmployees = FIRDatabase.database().reference().child("fEmployees")
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        noSign.isHidden = true
        filterConstrain.constant = -240
        blackView.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        blackView.addGestureRecognizer(tap)
        blackView.isUserInteractionEnabled = true
        filterDecided = 0
        filter.setImage(greenFilter, for: .normal)
        
        billerConnect.backgroundColor = UIColor.clear
        if employerID != "" {  titleLbl = "\(employerFromMain)'s bills" } else {titleLbl = "Bills"}
        
        self.title = titleLbl
        //self.view.insertSubview(backgroundImage, at: 0)
        
        //connectivity
        if Reachability.isConnectedToNetwork() == true
        {print("Internet Connection Available!")
        }else{
            print("Internet Connection not Available!")
        }
        
        //formatting decimal
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.roundingMode = .up
        
        //Date
        mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)",options: 0, locale: nil)!
        mydateFormat10.dateFormat = DateFormatter.dateFormat(fromTemplate: " MMM d, yyyy", options: 0, locale: Locale.autoupdatingCurrent)!
        mydateFormat20.dateFormat = DateFormatter.dateFormat(fromTemplate: " MMM , yyyy", options: 0, locale: Locale.autoupdatingCurrent)!
        let today = calendar.dateComponents([.year, .month, .day, .weekOfYear, .yearForWeekOfYear], from: Date())
        currentMonth = today.month!
        currentYear = today.year!
        
        self.StatusChoice = "All"
        self.billerConnect.separatorColor = blueColor
        
        billerConnect.delegate = self
        billerConnect.dataSource = self
    }//end of view did load////////////////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidAppear(_ animated: Bool) {
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
        
        taxCalc()
        print (billItems.count)
        billerConnect.reloadData()
    }//view did appear end
    
    func tableView(_ billerConnect: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ billerConnect: UITableView, numberOfRowsInSection section: Int) -> Int {
        print (byMonthTax.count)
        return byMonthTax.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = billerConnect.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! taxerCell
        let billItem = uniqueTaxMonths[indexPath.row]
        let billItem2 =  byMonthTax[billItem]!
        cell.backgroundColor = UIColor.clear
        cell.l1.text = uniqueTaxMonths[indexPath.row]
        cell.l4.text  = ViewController.fixedCurrency
        cell.l3.text = String(billItem2) as String
        
        
        /*
        
        if billItem.fBillTotalTotal != "" {cell.l3.text = billItem.fBillTotalTotal} else {cell.l3.text = billItem.fBillSum}
        cell.l4.text  = billItem.fBillCurrency!
        
        
        
        cell.approval.tag = indexPath.row
        print ("gggggg\(cell.approval.tag)")
        
        cell.approval.removeTarget(self, action:#selector(self.approvalClicked), for: UIControlEvents.touchDown)
        cell.approval.addTarget(self, action:#selector(self.approvalClicked), for: UIControlEvents.touchDown)
        */
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
        billItems.removeAll()
        BillArray.removeAll()
        BillArrayStatus.removeAll()
        self.billCounter = 0
        self.taxCounter = 0
        self.AmountCounter = 0
        
        self.dbRefEmployees.child(employeeID).child("myBills").observe(.childAdded, with: { (snapshot) in
            if let dictionary =  snapshot.value as? [String: AnyObject] {
                print ("snappp\(snapshot.value!)")
                let billItem = billStruct()
                billItem.setValuesForKeys(dictionary)
                
                let components = self.calendar.dateComponents([.year, .month, .day, .weekOfYear,.yearForWeekOfYear], from: self.mydateFormat5.date(from: billItem.fBillDate!)!)
                self.recordMonth = components.month!
                self.recordYear = components.year!
                print (self.recordMonth-1,self.recordYear-1)
                
                func inFilter() {
                    
                    if self .employerID != ""{
                        if self.StatusChoice == "Not Paid" && billItem.fBillStatus == "Billed" && billItem.fBillEmployer == self.employerID {
                            self.billItems.append(billItem); self.billCounter+=1 ;self.AmountCounter += Double(billItem.fBillTotalTotal!)!;self.taxCounter += Double(billItem.fBillTax!)!
                            ; self.BillArray.append(billItem.fBill!); self.BillArrayStatus.append(billItem.fBillStatus!)
                        }
                        else  if self.StatusChoice == "All" && billItem.fBillEmployer == self.employerID  {self.billItems.append(billItem);if billItem.fBillStatus != "Cancelled" {self.billCounter+=1; self.AmountCounter += Double(billItem.fBillTotalTotal!)!;
                            self.taxCounter += Double(billItem.fBillTax!)!}
                            ;self.BillArray.append(billItem.fBill!);self.BillArrayStatus.append(billItem.fBillStatus!)}
                    }//end of spesic employer
                    
                    if self .employerID == "" {
                        if self.StatusChoice == "All"  {self.billItems.append(billItem);if billItem.fBillStatus != "Cancelled" {self.billCounter+=1; self.AmountCounter += (Double(billItem.fBillTotalTotal!)!);  self.taxCounter += Double(billItem.fBillTax!)!};    self.BillArray.append(billItem.fBill!);self.BillArrayStatus.append(billItem.fBillStatus!)}
                        else if self.StatusChoice == "Not Paid" &&  billItem.fBillStatus == "Billed"  {self.billItems.append(billItem);self.billCounter+=1; self.AmountCounter += Double(billItem.fBillTotalTotal!)!;self.taxCounter += Double(billItem.fBillTax!)!;self.BillArray.append(billItem.fBill!);self.BillArrayStatus.append(billItem.fBillStatus!)}
                    }//end of  if self .employerID != ""
                    
                }//end of in filter
                
                switch self.filterDecided {
                case 0:inFilter()
                case 1:if self.currentMonth == self.recordMonth && self.currentYear == self.recordYear{inFilter()}
                case 2:if self.currentMonth-1 == self.recordMonth && self.currentYear == self.recordYear{inFilter()} else if self.currentMonth == 1 && self.recordMonth == 12 && self.currentYear-1 == self.recordYear{inFilter()}
                case 3:if self.currentYear == self.recordYear{inFilter()}
                case 4:if self.currentYear-1 == self.recordYear {inFilter()}
                default: inFilter()
                } //end of switch
                
                
                
                if self.billItems.count == 0 {self.noSign.isHidden = false} else {self.noSign.isHidden = true}
                self.totalBills.text = "\(String(describing: self.billCounter)) Bills"
                self.totalAmount.text = "\(ViewController.fixedCurrency!)\(String(describing: self.AmountCounter))"
                self.totalTax.text = "Tax \(ViewController.fixedCurrency!)\(String (describing: self.taxCounter))"
                self.billerConnect.reloadData()
            }//end of if let dic
        })//end of dbref
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            if self.billItems.count != self.BillArray.count {
                print ("Stop")
            }
            
            self.thinking.isHidden = true
            self.thinking.stopAnimating()
            self.StatusChosen.isEnabled = true
        }
        
    }//end of fetch
    func taxCalc(){
        print ("intaccalc")
        
        billItems.removeAll()
        BillArray.removeAll()
        BillArrayStatus.removeAll()
        byMonthTax.removeAll()
        
        self.billCounter = 0
        self.taxCounter = 0
        self.AmountCounter = 0
        
        self.dbRefEmployees.child(employeeID).child("myBills").observe(.childAdded, with: { (snapshot) in
            if let dictionary =  snapshot.value as? [String: AnyObject] {
                print ("snappp\(snapshot.value!)")
                let billItem = billStruct()
                billItem.setValuesForKeys(dictionary)
                
                let components = self.calendar.dateComponents([.year, .month, .day, .weekOfYear,.yearForWeekOfYear], from: self.mydateFormat5.date(from: billItem.fBillDate!)!)
                self.recordMonth = components.month!
                self.recordYear = components.year!
                print (self.recordMonth-1,self.recordYear-1)
                
                func inFilter() {
                    if self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)] == nil {
                                        self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)] = Double(billItem.fBillTax!)!
                    }else{
                        self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)] = self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)]! + Double(billItem.fBillTax!)!
                    }
                    self.byMonthTotalTax.append(self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!))
                    self.uniqueTaxMonths = Array(Set(self.byMonthTotalTax))

                    

                    print ("hhh\(self.byMonthTotalTax)")

                    
                        self.billItems.append(billItem);if billItem.fBillStatus != "Cancelled" {self.billCounter+=1; self.AmountCounter += Double(billItem.fBillTotalTotal!)!;
                            self.taxCounter += Double(billItem.fBillTax!)!}
                            ;self.BillArray.append(billItem.fBill!);self.BillArrayStatus.append(billItem.fBillStatus!)
                    
                    
                }//end of in filter
                
                switch self.filterDecided {
                case 0:inFilter()
                case 1:if self.currentMonth == self.recordMonth && self.currentYear == self.recordYear{inFilter()}
                case 2:if self.currentMonth-1 == self.recordMonth && self.currentYear == self.recordYear{inFilter()} else if self.currentMonth == 1 && self.recordMonth == 12 && self.currentYear-1 == self.recordYear{inFilter()}
                case 3:if self.currentYear == self.recordYear{inFilter()}
                case 4:if self.currentYear-1 == self.recordYear {inFilter()}
                default: inFilter()
                } //end of switch
                
                
                
                if self.billItems.count == 0 {self.noSign.isHidden = false} else {self.noSign.isHidden = true}
                self.totalBills.text = "\(String(describing: self.billCounter)) Bills"
                self.totalAmount.text = "\(ViewController.fixedCurrency!)\(String(describing: self.AmountCounter))"
                self.totalTax.text = "Tax \(ViewController.fixedCurrency!)\(String (describing: self.taxCounter))"
                self.billerConnect.reloadData()
            }//end of if let dic
        })//end of dbref
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            if self.billItems.count != self.BillArray.count {
                print ("Stop")
            }
            
            self.thinking.isHidden = true
            self.thinking.stopAnimating()
            self.StatusChosen.isEnabled = true
        }
        
    }//end of tacCalc
    
    
    @IBAction func StatusChosen(_ sender: Any) {
        print("pressed")
        //noSign.isHidden = true
        //saveToFB() //check why is it here?
        self.thinking.isHidden = false
        self.thinking.startAnimating()
        StatusChosen.isEnabled = false
        switch StatusChosen.selectedSegmentIndex {
        case 0: StatusChoice = "Not Paid"
        case 1: StatusChoice = "All"
        default: break
        } //end of switch
        //fetchBills()
        taxCalc()
    }
    
    
    // button on table clicked
    func  approvalClicked(sender:UIButton!) {
        self.StatusChosen.isEnabled = false
        buttonRow = sender.tag
        
        if BillArrayStatus[buttonRow] != "Cancelled"
        { if BillArrayStatus[buttonRow] == "Billed" {  statusTemp = "Paid"
            self.dbRefEmployees.child(employeeID).child("myBills").child(String("-"+BillArray[buttonRow])).updateChildValues(["fBillStatus": statusTemp, "fBillStatusDate":
                mydateFormat5.string(from: Date())//was 3
                ], withCompletionBlock: { (error) in}) //end of update.
            BillArrayStatus[buttonRow] = statusTemp
        }//end of if billed
        else if BillArrayStatus[buttonRow] == "Paid" {  if StatusChoice == "Not Paid" { statusTemp = "Billed"
            self.dbRefEmployees.child(employeeID).child("myBills").child(String("-"+BillArray[buttonRow])).updateChildValues(["fBillStatus": statusTemp, "fBillStatusDate":
                mydateFormat5.string(from: Date())//was 3
                ], withCompletionBlock: { (error) in}) //end of update.
            BillArrayStatus[buttonRow] = statusTemp
        } else { //BillArrayStatus[buttonRow] == "Cancelled"
            alert3()}
            }//end of if paid
            
        }else {
            alert9()}// end of if cancelled
        
        if StatusChoice == "Not Paid"{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                self.StatusChosen.isMomentary = true
                self.StatusChosen.selectedSegmentIndex = 0
                self.StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
                self.StatusChosen.isMomentary = false
                self.StatusChosen.isEnabled = true
            }} else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                self.StatusChosen.isEnabled = true
            }//end of fispatch
        }//end of else
        
    }//end button clicked
    
    func  reSend(sender:UIButton!) {
        print("resend")
        buttonRow = sender.tag
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
    
    //func for mail
    func  configuredMailComposeViewController2() -> MFMailComposeViewController {
        let mailComposerVC2 = MFMailComposeViewController()
        mailComposerVC2.mailComposeDelegate = self
        mailComposerVC2.setSubject("Bill recovery")
        mailComposerVC2.setMessageBody(recoveredBill!, isHTML: false)
        mailComposerVC2.setToRecipients([ViewController.fixedemail])
        return mailComposerVC2
    }//end of MFMailcomposer
    
    func showSendmailErrorAlert() {
        let sendMailErorrAlert = UIAlertController(title:"Could Not Send Email", message: "Your device could not send e-mail. Please check e-mail configuration and try again.",preferredStyle: .alert)
        sendMailErorrAlert.message = "error occured"
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
    }
    
    func handleTap(sender: UITapGestureRecognizer? = nil) {
        filterMovement(delay: 0)    }
    
    func filterMovement(delay:Double){
        if isFilterHidden {
            self.blackView.isHidden = false
            self.filterConstrain.constant = 0
            UIView.animate(withDuration: (0.4), animations: {
                self.view.layoutIfNeeded()
            })
        }else{
            self.blackView.isHidden = true
            filterConstrain.constant = -240
            UIView.animate(withDuration:(0.4+delay), animations: {
                self.view.layoutIfNeeded()
            })
        }
        isFilterHidden = !isFilterHidden
    }//end of issidemenuhidden
    
    
    
    // alerts////////////////////////////////////////////////////////////////////////////////////////////
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


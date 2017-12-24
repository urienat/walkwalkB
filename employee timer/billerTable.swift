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
    
    //let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
    let Vimage = UIImage(named: "due")
    let nonVimage = UIImage(named: "emptyV")
    let paidImage = UIImage(named: "paid")
    let canceledImage = UIImage(named: "cancelled")
    //let greenFilter = UIImage(named: "sandWatchGreen")
    let greenFilter = UIImage(named: "sandWatchBig")
    let redFilter = UIImage(named: "sandWatchRed")
    var blueColor = UIColor(red :22/255.0, green: 131/255.0, blue: 248/255.0, alpha: 1.0)
    
    var monthToHandle : Int = 0
    var yearToHandle : Int = 0
    var taxBillsToHandle:Bool = false
    
    var paymentSys: String? = ""
    var paymentReference: String? = ""
    var recieptDate: String? = ""
    var billStatus:String? = "Billed"
    var documentName:String?
    var segmentedPressed:Int?


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
    
    //payment
    var recieptMailSaver : String?
    var refernceBlock :String?
    var taxForBlock : String?
    var taxationBlock :String?
    var paymentBlock :String?
    var billInfo :String?
    var midCalc:String?
    var midCalc2 :String?
    var  midCalc3 :String?

    @IBOutlet weak var paymentTitle: UITextField!
    @IBOutlet weak var paymentView: UIView!
    @IBOutlet weak var paymentMethood: UISegmentedControl!
    @IBAction func paymentMethood(_ sender: Any) {
        print("payment pressed")
        //paymentMethood.isEnabled = false
        switch paymentMethood.selectedSegmentIndex {
        case 0: paymentSys = "cash"; referenceTxt.isHidden = true
        case 1: paymentSys = "check"; referenceTxt.isHidden = false
        case 2: paymentSys = "other"; referenceTxt.isHidden = false
        default: paymentSys = "None"; referenceTxt.isHidden = true
        } //end of switch
        
    }
    
    
    @IBOutlet weak var referenceTxt: UITextField!
    
    @IBAction func savePayment(_ sender: Any) {
        paymentReference = referenceTxt.text
        billStatus = "Paid"
        print (paymentSys,paymentReference)
        BillArrayStatus[buttonRow] = statusTemp
        paymentView.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            print ("alert19")
            self.alert19()}
        
    }
    
    @IBAction func cancelPayment(_ sender: Any) {
        paymentView.isHidden = true
        paymentReference = ""
        paymentSys = ""
        recieptDate = ""
        billStatus = "Billed"
    
        print (paymentSys,paymentReference)
      //  self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )
        self.segmentedPressed = 0
        self.StatusChosen.selectedSegmentIndex = self.segmentedPressed!
        self.StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
        
    }
        
        
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
    fetchBills()
    filterImageConstrain.constant = 20
    filter.setImage(greenFilter, for: .normal)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
        self.filterMovement(delay: 1.3)
    }
    }
    
    @IBAction func currentMonthBtn(_ sender: Any) {
    filterDecided = 1
        fetchBills()
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
        fetchBills()
    filter.setImage(redFilter, for: .normal)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
    self.filterMovement(delay: 1.3)
    }
    }
    
    @IBAction func currentYearBtn(_ sender: Any) {
    filterImageConstrain.constant = 140
    filterDecided = 3
        fetchBills()
    filter.setImage(redFilter, for: .normal)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
    self.filterMovement(delay: 1.3)
    }
    }
    
    @IBAction func lastYearBtn(_ sender: Any) {
    filterImageConstrain.constant = 180
    filterDecided = 4
        fetchBills()
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
            if taxBillsToHandle == false {fetchBills(); StatusChosen.isHidden = false;filter.isHidden = false} else {billsForTaxMonth();StatusChosen.isHidden = true;filter.isHidden = true;titleLbl = "\(monthToHandle)-\(yearToHandle)";self.title = titleLbl}
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
        cell.l1.text = ("\(billItem.fBill!) - \(billItem.fBillEmployerName!) ")
        print ("fuf\(billItem.fBillTotalTotal!)" )
        print ("fuf2\(billItem.fBillTotalTotal!)" )
        
        if billItem.fBillTotalTotal != "" {cell.l3.text = billItem.fBillTotalTotal} else {cell.l3.text = billItem.fBillSum}
        cell.l4.text  = billItem.fBillCurrency!
        cell.l6.text = "\(mydateFormat10.string(from: mydateFormat5.date(from: billItem.fBillDate!)!))"
        
        print("fbillstatus\(billItem.fBillStatus!)")
        
        if billItem.fBillStatus! == "Billed" { cell.approval.setImage(nonVimage, for: .normal);cell.l1.alpha = 1;cell.l3.alpha = 1;cell.l4.alpha = 1;cell.l6.alpha = 1;cell.approval.alpha = 1}
        if  billItem.fBillStatus!  == "Paid" { cell.approval.setImage(paidImage, for: .normal);cell.l1.alpha = 1;cell.l3.alpha = 1;cell.l4.alpha = 1;cell.l6.alpha = 1;cell.approval.alpha = 1}
        if billItem.fBillStatus! ==  "Cancelled" { cell.approval.setImage(canceledImage,for: .normal);cell.l1.alpha = 0.5;cell.l3.alpha = 0.5;cell.l4.alpha = 0.5;cell.l6.alpha = 0.5}
        
        if taxBillsToHandle == false{ cell.approval.isEnabled = true} else {cell.approval.isEnabled=false}
        cell.approval.tag = indexPath.row
        print ("gggggg\(cell.approval.tag)")
        
        cell.approval.removeTarget(self, action:#selector(self.approvalClicked), for: UIControlEvents.touchDown)
        cell.approval.addTarget(self, action:#selector(self.approvalClicked), for: UIControlEvents.touchDown)
        
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
    
            func billsForTaxMonth(){
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
                
            if self.recordMonth == self.monthToHandle && self.recordYear == self.yearToHandle {
            self.billItems.append(billItem);if billItem.fBillStatus != "Cancelled" {self.billCounter+=1; self.AmountCounter += (Double(billItem.fBillTotalTotal!)!);  self.taxCounter += Double(billItem.fBillTax!)!};    self.BillArray.append(billItem.fBill!);self.BillArrayStatus.append(billItem.fBillStatus!)
            }
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
            }//end of bills for tax month
    
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
                fetchBills()
        }
    
        // button on table clicked
        func  approvalClicked(sender:UIButton!) {
        self.StatusChosen.isEnabled = false
        buttonRow = sender.tag
            
            self.dbRefEmployees.child(employeeID).child("myBills").child(String("-"+BillArray[buttonRow])).observeSingleEvent(of: .value,with: {(snapshot) in
                self.midCalc = snapshot.childSnapshot(forPath: "fBillSum").value! as? String
                self.midCalc2 = snapshot.childSnapshot(forPath: "fBillTax").value! as? String
                self.midCalc3 = snapshot.childSnapshot(forPath: "fBillTotalTotal").value! as? String
                print (self.midCalc3,self.midCalc2,self.midCalc)
                
            })
            
        
        if BillArrayStatus[buttonRow] != "Cancelled"
        { if BillArrayStatus[buttonRow] == "Billed" {  statusTemp = "Paid";
            paymentTitle.text = "Fully pay bill \(BillArray[buttonRow]) by"
            paymentView.isHidden = false
           // self.dbRefEmployees.child(employeeID).child("myBills").child(String("-"+BillArray[buttonRow])).updateChildValues(["fBillStatus": statusTemp, "fBillStatusDate":
           // mydateFormat5.string(from: Date())//was 3
            //], withCompletionBlock: { (error) in}) //end of update.
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
            //self.StatusChosen.isMomentary = true
           // self.StatusChosen.selectedSegmentIndex = 0
           // self.StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
           // self.StatusChosen.isMomentary = false
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
    
        //func for mail// ithink not used
        func  configuredMailComposeViewController2() -> MFMailComposeViewController {
        let mailComposerVC2 = MFMailComposeViewController()
        mailComposerVC2.mailComposeDelegate = self
        mailComposerVC2.setSubject("Bill recovery")
        mailComposerVC2.setMessageBody(recoveredBill!, isHTML: false)
        mailComposerVC2.setToRecipients([ViewController.fixedemail])
        return mailComposerVC2
        }//end of MFMailcomposer
    
        //func for mail of reciept
        func  configuredMailComposeViewController3() -> MFMailComposeViewController {
        let mailComposerVC3 = MFMailComposeViewController()
        mailComposerVC3.mailComposeDelegate = self
        mailComposerVC3.setSubject("Reciept")
        mailComposerVC3.setMessageBody(recieptMailSaver!, isHTML: false)
        mailComposerVC3.setToRecipients([ViewController.fixedemail])
        DispatchQueue.main.asyncAfter(deadline: .now()+2){
        self.saveBase64StringToPDF(self.recieptMailSaver!)
        }
            
        return mailComposerVC3
        }//end of MFMailcomposer

    func saveBase64StringToPDF(_ base64String: String) {
        guard
            var documentsURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last,
            let convertedData = Data(base64Encoded: base64String)
            else {
                //handle error when getting documents URL
                return
        }
    }
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
    
    func recieptProcess() {
        self.thinking.startAnimating()
        recieptDate = mydateFormat5.string(from: Date())
        self.fetchBillInfo()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2){
            
            self.recieptMailSaver = "\(self.mydateFormat10.string(from: Date()))\r\nRef#: Reciept-\(self.BillArray[self.buttonRow])\r\nAccount: \(self.employerFromMain)\r\n\r\n \(self.billInfo!)\r\n\r\n\r\n\r\nHi, \r\n\r\n\r\n\\r\n \r\nTotal: \(ViewController.fixedCurrency!)\(self.midCalc3)\r\n\(self.taxationBlock)\r\n\r\n\r\n\(self.paymentBlock)\r\n\r\n\r\nRegards\r\n\(ViewController.fixedName!)\(ViewController.fixedLastName!)\r\n\r\nMade by PerSession app. "
                
                
                //update bill with DB
            self.dbRefEmployees.child(self.employeeID).child("myBills").child(String("-"+self.BillArray[self.buttonRow])).updateChildValues(["fBillStatus": self.statusTemp, "fBillStatusDate":
                self.self.mydateFormat5.string(from: Date()),"fPaymentMethood": self.paymentSys, "fPaymentReference": self.paymentReference,"fRecieptDate":self.mydateFormat5.string(from: Date()),"fBillRecieptMailSaver":self.recieptMailSaver
                ], withCompletionBlock: { (error) in}) //end of update.
                self.navigationController!.popViewController(animated: true)
                
            }//end of if biller
        
        
    }//end of billprocess
    
    func fetchBillInfo(){
        taxationBlock = ""
        self.dbRefEmployees.queryOrderedByKey().queryEqual(toValue: self.employeeID).observeSingleEvent(of: .childAdded, with: { (snapshot) in
           
            let counterForMail = (snapshot.childSnapshot(forPath: "fCounter").value as! String)
            let taxSwitch = (snapshot.childSnapshot(forPath: "fSwitcher").value as! String)
            let taxation = (snapshot.childSnapshot(forPath: "fTaxPrecentage").value as! String)
            let taxName = (snapshot.childSnapshot(forPath: "fTaxName").value as! String)
            self.billInfo = (snapshot.childSnapshot(forPath: "fBillinfo").value as! String)
            if taxName == "" {self.taxForBlock = "Tax"} else {self.taxForBlock = taxName}
            
            
          
            
            
            if  taxSwitch == "Yes" {
            self.taxationBlock = ("\(self.taxForBlock): \(ViewController.fixedCurrency!)\(self.midCalc)\r\n Total (w/\(self.taxForBlock)): \(ViewController.fixedCurrency!)\(self.midCalc2)\r\n")
            
            if self.paymentReference != "" {self.refernceBlock = "Ref:\(self.paymentReference!)"} else {self.refernceBlock = ""}
            if self.paymentSys != "Other"{self.paymentBlock = "Payment made by \(self.paymentSys!) \(self.refernceBlock) - \(self.mydateFormat10.string(from:self.mydateFormat5.date(from: self.recieptDate!)!))"
            }else{// payment == other
            self.paymentBlock = ("Payment made: \(self.mydateFormat10.string(from:self.mydateFormat5.date(from: self.recieptDate!)!)) - \(self.refernceBlock) ")
            }
        }
            
        })
    }//end of billing

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
    func alert19(){
        print ("in alert19")
        
        let alertController19 = UIAlertController(title: ("Bill") , message: "Register a new reciept." , preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Just do it", style: .default) { (UIAlertAction) in
            self.recieptProcess()
        }
        
        let mailAction = UIAlertAction(title: "Mail it", style: .default) { (UIAlertAction) in
            print ("mail it")
            
            self.recieptProcess() 
            
            
            DispatchQueue.main.asyncAfter(deadline: .now()+2){
                print ("in mail controller")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mailController  =  storyboard.instantiateViewController(withIdentifier: "200")
                self.present(mailController, animated: false, completion: nil)
                let mailComposeViewController3 = self.configuredMailComposeViewController3()
                if MFMailComposeViewController.canSendMail() {
                    self.present(mailComposeViewController3, animated: true, completion: nil)
                } //end of if
                else{ self.showSendmailErrorAlert() }
                
               /* DispatchQueue.main.asyncAfter(deadline: .now()+2){
                    
                    self.segmentedPressed = 0
                    self.StatusChosen.selectedSegmentIndex = self.segmentedPressed!
                    self.StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
                }*/
            }
        }
        let printAction = UIAlertAction(title: "Print it", style: .default) { (UIAlertAction) in
            self.recieptProcess()
            //add printing process
        }
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            self.paymentReference = ""
            self.paymentSys = ""
            self.recieptDate = ""
            self.billStatus = "Billed"
            self.segmentedPressed = 0
            self.StatusChosen.selectedSegmentIndex = self.segmentedPressed!
            self.StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
        }
        
        alertController19.addAction(OKAction)
        alertController19.addAction(mailAction)
        alertController19.addAction(printAction)
        alertController19.addAction(CancelAction)
        self.present(alertController19, animated: true, completion: nil)
    }//end of alert19
            }//end of class

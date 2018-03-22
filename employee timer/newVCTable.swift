//
//  newVCTable.swift
//  employee timer
//
//  Created by אורי עינת on 1.10.2016.
//  Copyright © 2016 אורי עינת. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import MessageUI
import Intents

class newVCTable: UIViewController ,UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    let dbRef = FIRDatabase.database().reference().child("fRecords")
    let dbRefEmployers = FIRDatabase.database().reference().child("fEmployers")
    let dbRefEmployees = FIRDatabase.database().reference().child("fEmployees")

    let mydateFormat3 = DateFormatter()
    let mydateFormat5 = DateFormatter()
    let mydateFormat8 = DateFormatter()
    let mydateFormat10 = DateFormatter()
    let mydateFormat11 = DateFormatter()
    var blueColor = UIColor(red :22/255.0, green: 131/255.0, blue: 248/255.0, alpha: 1.0)
    var redColor = UIColor(red :170.0/255.0, green: 26.0/255.0, blue: 0/255.0, alpha: 1.0)
    
    var backArrow = UIImage(named: "backArrow")?.withRenderingMode(.alwaysTemplate)
    let star = UIImage(named: "star")
    let billDocument = UIImage(named: "billDocument")
    let Vimage = UIImage(named:"vNaked")
    let nonVimage = UIImage(named: "blank")
    let paidImage = UIImage(named: "paid")
    let billIcon = UIImage(named: "bill")
    let blackImport = UIImage(named: "blackImport")
    let pencilImage = UIImage(named: "pencilImage")
    let roundImageNormal = UIImage(named: "roundImageNormal")
    var seprator =  "⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯"
    var seprator2 = "⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶"
    var seprator3 = "======================================"

    var contact:String?
    let myGroup = DispatchGroup()
    let myGroupBillPay = DispatchGroup()
    var billStarted = false
    var billPayStarted = false
    var lastPrevious = ""
    var firstTime:Bool?
    var firstTimeGeneral:Bool?
    var mailSaver : String?
    var payPalBlock = ""
    var PaymentBlalnce: String? = ""
    var paymentSys: String? = ""
    var paymentReference: String? = ""
    var paymentDate: String? = ""
    var recieptDate: String? = ""
    var billStatus:String? = "Billed"
    var documentName:String?
    
    var midCalc = "0.0"
    var midCalc2 = "0.0"
    var midCalc3 = "0.0"
    var taxForBlock = ""
    var taxSwitch: String?
    var taxCalc: String?
    var taxName: String?
    var taxation: String?
    var taxId: String?
    var taxCalculated: Double?
    var beforeTaxCalculated: Double?

    var taxationBlock = ""
    var sessionBlock = ""
    var paymentBlock = ""
    var refernceBlock = ""

    let keeper = UserDefaults.standard
    var rememberMe1 = 0
    
    var totalForReport: String?
    var biller:Bool = false
    var htmlReport: String?
    var csv2 = NSMutableString()
    var paypal: String?
    var billInfo: String?
    var address :String?

    let btn5 = UIButton(type: .custom)
    let btn4 = UIButton(type: .custom)
    var sendBillIcon = UIImage(named:"sendBillIcon")?.withRenderingMode(.alwaysTemplate )

    var employerMail = ""
    var statusTemp:String?
    static var checkBox:Int = 0
    var sessionAllChanger : Int = 0
    var generalChange = ""
    
    var idOfEmployers: [String:AnyObject] = [:]
    var idOfEmployers2: [String:AnyObject] = [:]

    var FbArray: [AnyObject] = []
    var FbArray2: [String] = []
    var records = [recordsStruct]()
    var itemSum:Double = 0.00
    var amountItem:Double = 0.00
    var idArray: [String] = []
    var indicationArray: [String] = []
    var amountArray: [Double] = []
    var dateDuplicate: [String] = []
    var duplicateChecked:Bool = false
    var  duplicates: [String] = []
    var appArray: [String] = []
    var Status: String = "Pre"
    let cellId =  "cellId"
    var eventCounter = 0
    var calc = 0.0
    var Employerrate = 0.0
    var accountAdress = ""
    var accountName = ""
    var accountLastName = ""
    var accountParnet = ""
    let formatter = NumberFormatter()
    var employerFromMain: String?
    var buttonRow = 0
    var segmentedPressed:Int?
    var employerID = ""
    var employeeID = ""
    var counterForMail2: String?
    var recotdMonth : Int = 0
    var recordYear : Int = 0
    var currentMonth : Int = 0
    var currentYear : Int = 0
    
    //payment
    @IBOutlet weak var paymentView: UIView!
    @IBOutlet weak var taxIncluded: UILabel!
    @IBOutlet weak var toolbar1: UIToolbar!
    @IBOutlet weak var paymentMethood: UISegmentedControl!
    @IBAction func paymentMethood(_ sender: Any) {
    print("payment pressed")
        //paymentMethood.isEnabled = false
        switch paymentMethood.selectedSegmentIndex {
        case 0: paymentSys = "cash"; referenceTxt.isHidden = true
        case 1: paymentSys = "check"; referenceTxt.isHidden = false
        case 2: paymentSys = "wire"; referenceTxt.isHidden = false
        case 3: paymentSys = "other"; referenceTxt.isHidden = false
        default: paymentSys = ""; referenceTxt.isHidden = true
        } //end of switch
    }//end of payment methood
    @IBOutlet weak var referenceTxt: UITextField!
    @IBAction func savePayment(_ sender: Any) {
        paymentReference = referenceTxt.text
        paymentDate = mydateFormat5.string(from: Date())
        recieptDate = paymentDate
        billStatus = "Paid"
        paymentView.isHidden = true
        billProcess()
    }//end of save
    
    @IBAction func cancelPayment(_ sender: Any) {
        self.billPayStarted = false
        paymentView.isHidden = true
        self.referenceTxt.text = ""
        self.paymentMethood.selectedSegmentIndex = -1
        self.referenceTxt.isHidden = true
        paymentReference = ""
        paymentSys = ""
        paymentDate = ""
        recieptDate = ""
        billStatus = "Billed"
        self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )
        self.segmentedPressed = 0
        self.StatusChosen.selectedSegmentIndex = self.segmentedPressed!
        self.StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
        }//end of cancel
    @IBOutlet weak var thinking: UIActivityIndicatorView!
    @IBOutlet weak var totalBackground: UIView!
    @IBOutlet weak var tableConnect: UITableView!
    @IBOutlet weak var eventsLbl: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var perEvents: UILabel!
    @IBOutlet weak var noSign: UIImageView!
    @IBOutlet weak var billPay: UIBarButtonItem!
    @IBOutlet weak var billSender: UIBarButtonItem!
    @IBOutlet weak var noRateInfo: UIButton!
    @IBAction func noRateInfo(_ sender: Any) {
    alert80()
    }
    
    func sendBill() {
    toolbar1.isHidden = true
    thinking.startAnimating()
    billStarted = true
    print (duplicateChecked)
    if duplicateChecked == false {checkDuplicate()} else {
        billSender.isEnabled = false
        billPay.isEnabled = false
    thinking.startAnimating()
   
    refresh(presser: 1)        //// When your task completes
    myGroup.enter()
    myGroup.notify(queue: DispatchQueue.main) {
        if self.appArray.count != 0  && self.Employerrate != 0.0 {self.thinking.stopAnimating();self.billProcess()}
        if self.Employerrate == 0.0 {self.thinking.stopAnimating();self.alert80()}
        if self.appArray.count == 0 {
        self.thinking.stopAnimating()
        
        print("Queue3")
        self.billStarted = false
        }
        }
        }
    }//end of sendBill
    
    func billPayProcess(){
    toolbar1.isHidden = true
    thinking.startAnimating()
    self.billPayStarted = true
    if duplicateChecked == false {checkDuplicate()} else {
    billSender.isEnabled = false
    billPay.isEnabled = false
    myGroupBillPay.enter()
    refresh(presser: 1)        //// When your task completes
    myGroupBillPay.notify(queue: DispatchQueue.main) {
    if self.appArray.count != 0  && self.Employerrate != 0.0{
    self.paymentView.isHidden = false
    }
    if self.Employerrate == 0.0 {self.thinking.stopAnimating();self.alert80()}
    if self.appArray.count == 0 {
    self.thinking.stopAnimating()
    
    }
        }//end of my group
    }//end of else
    }//end of billpayprocess
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  view did load
        override func viewDidLoad() {
        tableConnect.backgroundColor = UIColor.clear
        
        let titleLbl = "Sessions"
        self.title = titleLbl
         
            
        let yourBackImage = UIImage(named: "backArrow")
        self.navigationController?.navigationBar.backIndicatorImage =  yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage

        //formatting decimal
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.roundingMode = .up
        
        tableConnect.delegate = self
        tableConnect.dataSource = self
        tableConnect.separatorColor = blueColor

        //formating the date
        mydateFormat3.dateFormat = DateFormatter.dateFormat(fromTemplate: "dd-MMM-yyyy",options: 0, locale: nil)!
        mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)",options: 0, locale: nil)!
        mydateFormat8.dateFormat = DateFormatter.dateFormat(fromTemplate: " MMM d, yyyy", options: 0, locale: Locale.autoupdatingCurrent)!
        mydateFormat10.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEE-dd-MMM-yyyy", options: 0, locale: Locale.autoupdatingCurrent)!
        mydateFormat11.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEE-dd-MMM-yyyy , (HH,mm)", options: 0, locale: Locale.autoupdatingCurrent)!

        dbRefEmployers.child(self.employerID).observeSingleEvent(of:.value, with: {(snapshot) in
        self.employerMail = String(describing: snapshot.childSnapshot(forPath: "fMail").value!) as String!
        self.lastPrevious = String(describing: snapshot.childSnapshot(forPath: "fLast").value!) as String!
        self.accountAdress = String(describing: snapshot.childSnapshot(forPath: "fAddress").value!) as String!
        self.accountName = String(describing: snapshot.childSnapshot(forPath: "fName").value!) as String!
        self.accountLastName = String(describing: snapshot.childSnapshot(forPath: "fEmployer").value!) as String!
        self.accountParnet = String(describing: snapshot.childSnapshot(forPath: "fParent").value!) as String!
        })
  
        self.thinking.color = self.blueColor
        self.thinking.isHidden = false
        self.thinking.startAnimating()
        StatusChosen.isEnabled = false
        periodChosen.isEnabled = false
        self.thinking.hidesWhenStopped = true
            
         
        btn4.setImage(billDocument , for: .normal)
        btn4.setTitle("You Owe Me", for: .normal)
        btn4.setTitleColor(redColor, for: .normal)
        btn4.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        btn4.addTarget(self, action:#selector(sendBill), for: UIControlEvents.touchDown)
        billSender.customView = btn4
            
        btn5.setImage(paidImage , for: .normal)
        btn5.setTitle(" PayDay", for: .normal)
        btn5.setTitleColor(blueColor, for: .normal)
        btn5.frame = CGRect(x: 0, y: 0, width: 130, height: 30)
        btn5.addTarget(self, action:#selector(billPayProcess), for: UIControlEvents.touchDown)
        billPay.customView = btn5
            
        paymentView.layer.cornerRadius = 10//paymentView.frame.height / 2.0
        paymentView.layer.masksToBounds = true
        paymentView.layer.borderWidth = 0.5
        paymentView.layer.borderColor = blueColor.cgColor
        paymentView.layoutIfNeeded()
          
        if keeper.integer(forKey: "dueInstruction") != 1 {rememberMe1 = 0 } else { rememberMe1 = 1 }
        }//end of view did load//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
        override func viewDidAppear(_ animated: Bool) {
        fetch {self.final()}
        }//view did appear end


        func tableView(_ tableConnect: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count}

        @IBOutlet weak var StatusChosen: UISegmentedControl!
        @IBAction func StatusChosen(_ sender: AnyObject) {
        print("pressed")
        self.thinking.isHidden = false
        self.thinking.startAnimating()
        StatusChosen.isEnabled = false
        periodChosen.isEnabled = false
        switch StatusChosen.selectedSegmentIndex {
        case 0: Status = "Pre"
        case 1: Status = "Approved"
        default: Status = "All";
        } //end of switch
        self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )
            
            self.fetch {
               print ("fetch")
                
                self.final()}
        }//end of status chosen

        @IBOutlet weak var periodChosen: UISegmentedControl!
        @IBAction func PeriodChosen(_ sender: AnyObject) {
        self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )
        self.thinking.isHidden = false
        self.thinking.startAnimating()
        StatusChosen.isEnabled = false
        periodChosen.isEnabled = false
        ;fetch {self.final()} }

        func tableView(_ tableConnect: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableConnect.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! newTableCell
        let record = records[indexPath.row]
        cell.backgroundColor = UIColor.clear

        cell.cellBtnExt.layer.borderWidth = 0.5;
        cell.cellBtnExt.layer.borderColor =  blueColor.cgColor
        cell.cellBtnExt.layer.cornerRadius =  10

        //changing the dates for prentation
        if let fInToDate = record.fIn {
        if ViewController.dateTimeFormat == "DateTime" { cell.l1.text = mydateFormat11.string(from: mydateFormat5.date(from: fInToDate)!)} else {cell.l1.text = mydateFormat10.string(from: mydateFormat5.date(from: fInToDate)!) } }
        else { cell.l1.text = "N/A"}

        if record.fIndication3 == "📆" { cell.l8.image = blackImport}
        if record.fIndication3 == "✏️" { cell.l8.image = pencilImage}
        if record.fIndication3 == "↺" { cell.l8.image = roundImageNormal}
        if record.fIndication3 == "📄" {  cell.l8.image = star}

            if record.fSpecialAmount != nil {cell.l1.text = " \(record.fSpecialItem!)"; cell.l9.text = "\(ViewController.fixedCurrency!)\(record.fSpecialAmount!)"}else {cell.l9.text = nil}

        if record.fStatus == "Approved" { cell.cellBtnExt.setImage(Vimage, for: .normal)}
        if record.fStatus == "Pre" { cell.cellBtnExt.setImage(nonVimage, for: .normal)}
        cell.cellBtnExt.tag = indexPath.row
        cell.cellBtnExt.removeTarget(self, action:#selector(self.approvalClicked), for: UIControlEvents.touchDown)
        cell.cellBtnExt.addTarget(self, action:#selector(self.approvalClicked), for: UIControlEvents.touchDown)

        if record.fBill != nil {cell.l7.text = record.fBill!} else {cell.l7.text = ""}
        return cell
        }//end of func cellforrowat

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "presentBill")
        { let billManager = segue.destination as? billView
        print ("presparesegue")
        billManager?.recoveredBill = mailSaver!
        billManager?.rebillprocess = false
        billManager?.document = documentName!
        billManager?.documentCounter = counterForMail2!
        billManager?.employeeID = employeeID
        billManager?.undoArray = idArray
        billManager?.employerID = employerID
        billManager?.lastPrevious = lastPrevious
        billManager?.payPalBlock = payPalBlock
        if  ViewController.professionControl! == "Dog walker" && accountParnet != "" {billManager?.contactForMail = "\(self.accountParnet) \(self.accountLastName) - \(self.accountName)"} else {
        billManager?.contactForMail = "\(self.accountName) \(self.accountLastName)"
        }
        }//end of if (segue...

        if (segue.identifier == "recordHandler")
        { var recordRow : IndexPath = self.tableConnect.indexPathForSelectedRow!
        print (recordRow)
        let recordManager = segue.destination as? datePicker2
        print ("presparesegue")
        recordManager?.recordToHandle = String(idArray[recordRow.row])
        }//end of if (segue...
        }//end of prepare

        func tableView(_ tableConnect: UITableView, didSelectRowAt indexPath: IndexPath) {}

        func  approvalClicked(sender:UIButton!) {
        self.billSender.isEnabled = false
        self.billPay.isEnabled = false
        buttonRow = sender.tag

        if appArray[buttonRow] == "Pre" { newVCTable.checkBox = 1; statusTemp = "Approved";if indicationArray[buttonRow] != "📄" {eventCounter+=1};if indicationArray[buttonRow] == "📄" {itemSum += Double(amountArray[buttonRow]) }; amountCalc()}
        else if appArray[buttonRow] == "Approved" { newVCTable.checkBox = 0; statusTemp = "Pre";if indicationArray[buttonRow] != "📄" {eventCounter-=1}; if indicationArray[buttonRow] == "📄" {itemSum -= Double(amountArray[buttonRow]) }; amountCalc()}
        else if  appArray[buttonRow] == "Paid" {newVCTable.checkBox = 2; statusTemp = "Paid";alert12()}
        if self.eventCounter == 0 {self.eventsLbl.text = " No Due Sessions";if  itemSum == 0{toolbar1.isHidden = true;noSign.isHidden = false}else{toolbar1.isHidden = false;noSign.isHidden = true}} else if self.eventCounter == 1 {self.eventsLbl.text = "\(String(self.eventCounter)) Due session";toolbar1.isHidden = false;noSign.isHidden = true} else {self.eventsLbl.text = "\(String(self.eventCounter)) due Sessions";toolbar1.isHidden = false;noSign.isHidden = true}

        if statusTemp != appArray[buttonRow] {
        appArray[buttonRow] = statusTemp!

        self.dbRef.child(String(idArray[buttonRow])).updateChildValues(["fStatus": statusTemp!], withCompletionBlock: { (error) in}) //end of update.
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2){//used to be 1
        self.billSender.isEnabled = true
        self.billPay.isEnabled = true
        }
        }//end button clicked

        func  moveSessionToBilled() {
        print ("moveSessionToBilled")
        if appArray.count != 0 {
        for h in 0...(appArray.count-1){
        buttonRow = h
        statusTemp = "Paid"
        if statusTemp != appArray[buttonRow] {//i think no need to status temp or to if
        appArray[buttonRow] = statusTemp!
        self.dbRef.child(String(idArray[buttonRow])).updateChildValues(["fStatus": statusTemp!], withCompletionBlock: { (error) in}) //end of update.
        }
        }//end of loop
        }//end of if
        }//end movesession

    func amountCalc(){
        if ViewController.taxOption == "Yes" && ViewController.taxCalc == "Over" {
            self.amount.text = "\(ViewController.fixedCurrency!)\(String(Double((1 + (Double(ViewController.taxation!)!/100.0)) * ((Double(self.eventCounter))*(self.Employerrate) + itemSum)).roundTo(places: 2)))"
        } else {
            self.amount.text = "\(ViewController.fixedCurrency!)\(String((Double(self.eventCounter))*(self.Employerrate) + itemSum))"
        }
    }
    
        func amountCalc3(){
           
            if ViewController.taxOption == "Yes" && ViewController.taxCalc == "Over" {self.calc = (1 + (Double(ViewController.taxation!)!/100.0)) * ((Double(self.eventCounter))*(self.Employerrate) + itemSum)
                
            } else {
        self.calc = (Double(self.eventCounter))*(self.Employerrate) + itemSum}
       
        self.amount.text =   ("\(ViewController.fixedCurrency!)\(String(Double(self.calc).roundTo(places: 2)))")
        
           
    }

        func billing(completion: @escaping () -> () ){
        taxationBlock = ""
        sessionBlock = ""
        biller = true

        self.dbRefEmployees.queryOrderedByKey().queryEqual(toValue: self.employeeID).observeSingleEvent(of: .childAdded, with: { (snapshot) in
        self.counterForMail2 = (snapshot.childSnapshot(forPath: "fCounter").value as! String)
        self.taxation = (snapshot.childSnapshot(forPath: "fTaxPrecentage").value as! String)
        self.taxName = (snapshot.childSnapshot(forPath: "fTaxName").value as! String)
        self.taxCalc = (snapshot.childSnapshot(forPath: "fTaxCalc").value as! String)
        self.taxSwitch = (snapshot.childSnapshot(forPath: "fSwitcher").value as! String)
        self.paypal = (snapshot.childSnapshot(forPath: "fPaypal").value as! String)
            if snapshot.childSnapshot(forPath: "fBillinfo").value as? String != nil {self.billInfo = "\(snapshot.childSnapshot(forPath: "fBillinfo").value as! String)"} else {self.billInfo = ""}
        print(snapshot.childSnapshot(forPath: "fTaxId").value as! String)
            
        if snapshot.childSnapshot(forPath: "fTaxId").value as! String == "" {self.taxId = ""} else {self.taxId = "Tax ID: \(snapshot.childSnapshot(forPath: "fTaxId").value as! String)"} 
        self.address = (snapshot.childSnapshot(forPath: "fAddress").value as! String)


        if self.eventCounter == 0 {self.sessionBlock = ""} else {self.sessionBlock = "\(self.seprator)\r\nTotal Number of sessions: \(self.eventCounter)  -   \(self.perEvents.text!)"}

        if  self.taxSwitch == "Yes" {
        if self.self.taxCalc == "Over" {self.taxCalculated =  Double(Double(self.taxation!)!*self.calc*0.01).roundTo(places: 2)}  else  { self.taxCalculated = Double((self.calc / Double(Double(self.taxation!)!*0.01+1)) * Double(Double(self.taxation!)!*0.01)).roundTo(places: 2)}

        if self.taxCalc == "Over" {self.beforeTaxCalculated = Double(self.calc).roundTo(places: 2)}  else  { self.beforeTaxCalculated =  self.calc -  Double((self.calc / Double(Double(self.taxation!)!*0.01+1)) * Double(Double(self.taxation!)!*0.01)).roundTo(places: 2)}

        self.midCalc =  String (describing: self.taxCalculated!)
        self.midCalc3 =  String(describing: self.beforeTaxCalculated!)
        print (self.midCalc)
        if self.taxName! == "" {self.taxForBlock = "Tax"} else {self.taxForBlock = self.taxName!}
        print (self.midCalc3)
        self.midCalc2 =  String(self.beforeTaxCalculated! + self.taxCalculated!)

        if self.paymentDate! == "" {self.paymentDate = self.mydateFormat5.string(from: Date());self.PaymentBlalnce = self.midCalc2} else { self.PaymentBlalnce = "0"}

        self.taxationBlock = ("\(self.seprator3)\r\nSubtotal: \(ViewController.fixedCurrency!)\(self.midCalc3)\r\n\(self.taxForBlock)(%\(self.taxation!)): \(ViewController.fixedCurrency!)\(self.midCalc)\r\nTotal (w/\(self.taxForBlock)): \(ViewController.fixedCurrency!)\(self.midCalc2)")
        } else {

        self.midCalc =  "0"
        self.midCalc2 =  String (describing:self.calc.roundTo(places: 2))
        self.midCalc3 = String (describing:self.calc.roundTo(places: 2))//check it!!!!!!
            
            if self.paymentDate! == "" {self.paymentDate = self.mydateFormat5.string(from: Date());self.PaymentBlalnce = self.midCalc2} else { self.PaymentBlalnce = "0"}

        self.taxationBlock = "\(self.seprator)\r\n\(self.seprator)\r\nTotal: \(ViewController.fixedCurrency!)\(self.midCalc3)"}

        if self.paymentReference != "" {self.refernceBlock = " - Ref:\(self.paymentReference!)"} else {self.refernceBlock = ""}
            if self.recieptDate != "" {if self.taxSwitch == "Yes" && self.taxForBlock == "VAT" {
        self.documentName = "VAT Invoice \(self.counterForMail2!)"} else {self.documentName = "Invoice \(self.counterForMail2!)"}; if self.paymentSys == "other" || self.paymentSys == ""{self.paymentBlock = ("\(self.seprator2)\(self.seprator2)\r\nPayment of \(ViewController.fixedCurrency!)\(self.midCalc2) made: \(self.mydateFormat10.string(from:self.mydateFormat5.date(from: self.recieptDate!)!)) \(self.refernceBlock)\r\nBalance due: \(ViewController.fixedCurrency!)\(self.PaymentBlalnce!) ")
        }
        else{self.paymentBlock = "\(self.seprator3)\(self.seprator3)\r\nPayment of \(ViewController.fixedCurrency!)\(self.midCalc2) made by \(self.paymentSys!) \(self.refernceBlock) - \(self.mydateFormat10.string(from:self.mydateFormat5.date(from: self.recieptDate!)!))\r\nBalance due: \(ViewController.fixedCurrency!)\(self.PaymentBlalnce!)"
        }
        }else{
                if self.taxSwitch == "Yes" && self.taxForBlock == "VAT" {self.documentName = "VAT Invoice \(self.counterForMail2!)"} else {self.documentName = "Invoice \(self.counterForMail2!)"}; // no payment only bill

        self.paymentBlock = "\r\n\(self.seprator3)\(self.seprator3)\r\nBalance due: \(ViewController.fixedCurrency!)\(self.PaymentBlalnce!)"
        if self.paypal != "" {self.payPalBlock = "\r\n\r\nPayment can be made through Paypal: \(self.paypal!)/\(self.midCalc2)"}else {self.payPalBlock = ""}
        }// end of else  self.paymentDate != ""

         completion()
        })
        }//end of billing


        func refresh(presser:Int){
        StatusChosen.isMomentary = true
        segmentedPressed = presser
        StatusChosen.selectedSegmentIndex = segmentedPressed!
        StatusChosen.sendActions(for: .valueChanged)
        StatusChosen.isMomentary = false
        }

        func checkDuplicate(){
        print ("check dupliates")
        print (dateDuplicate)
        duplicates = Array(Set(dateDuplicate.filter({ (i: String) in dateDuplicate.filter({ $0 == i }).count > 1})))
        print (duplicates)
        if duplicates.isEmpty == false {duplicates = duplicates.map{mydateFormat11.string(from: mydateFormat5.date(from: $0)!)};
        print (duplicates); alert23();duplicateChecked = true} else {duplicateChecked = true
        print("do nothing")
        }
        }

    // alerts/////////////////////////////////////////////////////////////////////////////////////

    func alert80(){
    let alertController80 = UIAlertController(title: ("No Rate") , message: "You can't bill as there is no rate for this account. You can set it at \(accountName) \(accountLastName) - 'File'", preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
    ViewController.profilePusher = true
    self.navigationController!.popViewController(animated: false)
    }
    let CancelAction = UIAlertAction(title: "Not now", style: .cancel) { (UIAlertAction) in
    //do nothing
    }
    alertController80.addAction(OKAction)
    alertController80.addAction(CancelAction)
    self.present(alertController80, animated: true, completion: nil)
    }

    func billProcess() {
    self.thinking.startAnimating()
        self.billing {
            self.afterBilling()
        }
    }

    func afterBilling(){
    
    self.htmlReport = self.csv2 as String!
    print(self.counterForMail2!)

    if self.biller == true {self.dbRefEmployees.child(self.employeeID).updateChildValues(["fCounter": String(describing: (Int(self.counterForMail2!)!+1))])//add counter to invoice #
    self.biller = false

    if  ViewController.professionControl! == "Dog walker" && self.accountParnet != "" {self.contact = "\(self.accountParnet) \(self.accountLastName) - \(self.accountName)"} else {
    self.contact = "\(self.accountName) \(self.accountLastName)"}

    self.mailSaver = "\(self.mydateFormat8.string(from: Date()))\r\n\r\n\r\n\(ViewController.fixedName!) \(ViewController.fixedLastName!)\r\n\(self.billInfo!)\r\n\(self.taxId!)\r\n\(self.address!)\r\n\(self.seprator2)\(self.seprator2)\r\n\r\nBill to:\r\n\(self.contact!)\r\n\(self.accountAdress)\r\n\(self.seprator2)\r\n\(self.htmlReport!)\(self.sessionBlock)\r\n\r\n\(self.taxationBlock)\r\n\(self.paymentBlock)\r\n\r\n\r\nMade by PerSession app. "

    //update bill with DB
        self.dbRefEmployees.child(self.employeeID).child("myBills").child("-\(self.counterForMail2!)").updateChildValues(["fBill": self.counterForMail2!,"fBillDate": self.mydateFormat5.string(from: Date()) ,"fBillStatus": self.billStatus!,"fBillStatusDate":self.mydateFormat5.string(from: Date()) ,"fBillEmployer": self.employerID,"fBillEventRate": self.perEvents.text!, "fBillEvents": String(self.eventCounter) as String,"fBillSum": self.midCalc3, "fBillCurrency": ViewController.fixedCurrency!,"fBillEmployerName": self.employerFromMain!, "fBillMailSaver" : self.mailSaver!,"fBillTax" : self.midCalc ,"fBillTotalTotal": self.midCalc2, "fDocumentName":self.documentName!,"fBalance": self.PaymentBlalnce!
    ], withCompletionBlock: { (error) in}) //end of update.//was 0

    self.dbRefEmployers.child(self.employerID).updateChildValues(["fLast":"Last billed: \(self.mydateFormat8.string(from: Date()))"], withCompletionBlock: { (error) in})
        self.dbRefEmployees.child(self.employeeID).child("myEmployers").updateChildValues([(self.employerID):Int((self.mydateFormat5.date(from: self.mydateFormat5.string(from: Date()))?.timeIntervalSince1970)!)])

    self.moveSessionToBilled()
    self.billStarted = false
    self.referenceTxt.text = ""
    self.paymentReference = ""
    self.paymentSys = ""
    self.recieptDate = ""
    self.paymentMethood.selectedSegmentIndex = -1
    self.referenceTxt.isHidden = true
        
    self.performSegue(withIdentifier: "presentBill", sender: self.mailSaver)

    }//end of if biller
    
    }//end of billprocess

    
    func alert12(){
    let alertController12 = UIAlertController(title: ("Change record status") , message: "You can not change status of records that were already billed.", preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
    self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )
    DispatchQueue.main.asyncAfter(deadline: .now()+1){
    self.refresh(presser: 0)
    }
    }
    alertController12.addAction(OKAction)
    self.present(alertController12, animated: true, completion: nil)
    }//end of alert12

    func alert23(){
    let alertController23 = UIAlertController(title: ("Double session?") , message: "It seems that following are duplicate sessions: \(self.duplicates). Is that OK? ", preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "Yes. I am aware.", style: .default) { (UIAlertAction) in
    self.duplicateChecked = true
    }
    let DeleteAction = UIAlertAction(title: "I need to delete it.", style: .cancel) { (UIAlertAction) in
    self.duplicateChecked = false
    //self.fetch()
    }
    alertController23.addAction(OKAction)
    alertController23.addAction(DeleteAction)
    self.present(alertController23, animated: true, completion: nil)
    }//end of alert23

    }//end of class//////////////////////////////////////////////////////////////

    extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    }

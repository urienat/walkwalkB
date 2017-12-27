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
    
    @IBOutlet weak var tableConnect: UITableView!
   
    let Vimage = UIImage(named: "due")
    let nonVimage = UIImage(named: "emptyV")
    let paidImage = UIImage(named: "paid")
    let billedImage = UIImage(named: "locked")
    let billIcon = UIImage(named: "bill")
    let sandwatchImage = UIImage(named: "sandWatch")
    let pencilImage = UIImage(named: "pencilImage")
    let roundImageNormal = UIImage(named: "roundImageNormal")
    var blueColor = UIColor(red :22/255.0, green: 131/255.0, blue: 248/255.0, alpha: 1.0)

    var mailSaver : String?
    var releaser: Int? = 0
    
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
    var stam: Double?
    var stam3: Double?

    var taxationBlock = ""
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
    var checkBoxGeneral:Int = 1
    var generalChange = ""
    
    var idOfEmployers: [String:AnyObject] = [:]
    var idOfEmployers2: [String:AnyObject] = [:]

    var FbArray: [AnyObject] = []
    var FbArray2: [String] = []

    var idArray: [String] = []
    var appArray: [String] = []
    var Status: String = "Pre"
    let cellId =  "cellId"
    var eventCounter = 0
    var calc = 0.0
    var Employerrate = 0.0
    let formatter = NumberFormatter()
    var employerFromMain: String?
    var buttonRow = 0
    
    var segmentedPressed:Int?
    
    var employerID = ""
    var employeeID = ""
    
    //payment
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
        paymentDate = mydateFormat5.string(from: Date())
        recieptDate = paymentDate
        billStatus = "Paid"
        print (paymentSys,paymentReference)
        paymentView.isHidden = true
        self.alert19()
        }//end of save
    
    @IBAction func cancelPayment(_ sender: Any) {
        paymentView.isHidden = true
        paymentReference = ""
        paymentSys = ""
        paymentDate = ""
        recieptDate = ""
        billStatus = "Billed"
        print (paymentSys,paymentReference)
        self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )
        self.segmentedPressed = 0
        self.StatusChosen.selectedSegmentIndex = self.segmentedPressed!
        self.StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
        }//end of cancel
    
    let mydateFormat3 = DateFormatter()
    let mydateFormat5 = DateFormatter()
    let mydateFormat10 = DateFormatter()
    let mydateFormat11 = DateFormatter()

    var counterForMail2: String?
    
    var recotdMonth : Int = 0
    var recordYear : Int = 0
    var currentMonth : Int = 0
    var currentYear : Int = 0

    let dbRef = FIRDatabase.database().reference().child("fRecords")
    let dbRefEmployers = FIRDatabase.database().reference().child("fEmployers")
    let dbRefEmployees = FIRDatabase.database().reference().child("fEmployees")
    
    @IBOutlet weak var eventsLbl: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var perEvents: UILabel!
    @IBOutlet weak var noSign: UIImageView!
    @IBOutlet weak var billPay: UIBarButtonItem!
    @IBOutlet weak var billSender: UIBarButtonItem!
    
    func sendBill() {
    billSender.isEnabled = false
    billPay.isEnabled = false
    releaser = 1
    refresh(presser: 1)
    DispatchQueue.main.asyncAfter(deadline: .now()+4.4){
    print(self.appArray.count)
    if self.appArray.count != 0 {self.thinking.stopAnimating(); self.alert18()}
    if self.appArray.count == 0 {
    self.thinking.stopAnimating()
    self.alert27()
        }
    self.billSender.isEnabled = false
    self.billPay.isEnabled = false
    self.releaser = 0
    }
    }//end of sendBill
    
    func billPayProcess(){
    billSender.isEnabled = false
    billPay.isEnabled = false
    releaser = 1
    refresh(presser: 1)

    DispatchQueue.main.asyncAfter(deadline: .now()+4.4){
    print(self.appArray.count)
    if self.appArray.count != 0 {self.thinking.stopAnimating();
    self.paymentRef()
    }
    if self.appArray.count == 0 {
    self.thinking.stopAnimating()
    self.alert27()
    }
    self.billSender.isEnabled = false
    self.billPay.isEnabled = false
    self.releaser = 0
    }
    }//end of billpayprocess
    
    var records = [recordsStruct]()
    @IBOutlet weak var thinking: UIActivityIndicatorView!
    @IBOutlet weak var totalBackground: UIView!
    @IBOutlet weak var generalApproval: UIButton!
    @IBAction func generalApproval(_ sender: Any) {
    generalApproval.isHidden = true

    if  checkBoxGeneral == 2 {
    refresh(presser: 1)
    }
        
    if  checkBoxGeneral == 1         {
    refresh(presser: 1)
    }
        
    DispatchQueue.main.asyncAfter(deadline: .now()+1){
    self.alert11()
        }
        
    }//end of approval button
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  view did load
        override func viewDidLoad() {
        super.viewDidLoad()
           
        tableConnect.backgroundColor = UIColor.clear
        
        let titleLbl = employerFromMain! + "'s Sessions"
        self.title = titleLbl
   
        //connectivity
        if Reachability.isConnectedToNetwork() == true
        {print("Internet Connection Available!")}
        else
        {print("Internet Connection not Available!")}
            
            //formatting decimal
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.roundingMode = .up
        
        
        tableConnect.delegate = self
        tableConnect.dataSource = self
        
            

        //formating the date
        mydateFormat3.dateFormat = DateFormatter.dateFormat(fromTemplate: "dd-MMM-yyyy",options: 0, locale: nil)!
        mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)",options: 0, locale: nil)!
        mydateFormat10.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEE-dd-MMM-yyyy", options: 0, locale: Locale.autoupdatingCurrent)!
        mydateFormat11.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEE-dd-MMM-yyyy , (HH,mm)", options: 0, locale: Locale.autoupdatingCurrent)!

        dbRefEmployers.child(self.employerID).observeSingleEvent(of:.value, with: {(snapshot) in
        self.employerMail = String(describing: snapshot.childSnapshot(forPath: "fMail").value!) as String!
        })
  
        self.thinking.color = self.blueColor
        self.thinking.isHidden = false
        self.thinking.startAnimating()
        StatusChosen.isEnabled = false
        periodChosen.isEnabled = false
        self.thinking.hidesWhenStopped = true
         
        //btn4.setImage(sendBillIcon , for: .normal)
        btn4.setTitle("Bill", for: .normal)
        btn4.setTitleColor(blueColor, for: .normal)
        btn4.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        btn4.addTarget(self, action:#selector(sendBill), for: UIControlEvents.touchDown)
        billSender.customView = btn4
            
        btn5.setTitle("Bill&Pay", for: .normal)
        btn5.setTitleColor(blueColor, for: .normal)
        btn5.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        btn5.addTarget(self, action:#selector(billPayProcess), for: UIControlEvents.touchDown)
        billPay.customView = btn5
            
        if keeper.integer(forKey: "dueInstruction") != 1 {rememberMe1 = 0 } else { rememberMe1 = 1 }
         
        tableConnect.separatorColor = blueColor
            
        paymentView.layoutIfNeeded()
        paymentView.layer.cornerRadius = 10//paymentView.frame.height / 2.0
        paymentView.layer.masksToBounds = true


            
        }//end of view did load//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
    
        override func viewDidAppear(_ animated: Bool) {
            let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
            connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {print("Connected")}
            else {print("Not connected")
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0){
            connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
            print("Connected after all")} else  {print("not connected after all");self.noFB()}
            })
            }}
            })
            
            eventCounter = 0
            
            fetch()
            
            }//view did appear end
    
   
            func tableView(_ tableConnect: UITableView, numberOfRowsInSection section: Int) -> Int {
                return records.count}
    
            @IBOutlet weak var StatusChosen: UISegmentedControl!
    
            @IBAction func StatusChosen(_ sender: AnyObject) {
            
            print("pressed")
            generalApproval.isEnabled = false
            self.thinking.isHidden = false
            self.thinking.startAnimating()
            StatusChosen.isEnabled = false
            periodChosen.isEnabled = false
                switch StatusChosen.selectedSegmentIndex {
                case 0: Status = "Pre";checkBoxGeneral = 1;generalApproval.isEnabled = true;generalApproval.isEnabled = true
                case 1: Status = "Approved" ;checkBoxGeneral = 2;  generalApproval.isEnabled = true//print ("status:\(Status)")
                case 2: Status = "Paid"  ;checkBoxGeneral = 0; generalApproval.isEnabled = false;
                default: Status = "All";generalApproval.isHidden = true;
                } //end of switch
                print ("status:\(Status)")
            self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )

            fetch()
            }//end of status chosen
    
        @IBOutlet weak var periodChosen: UISegmentedControl!
        @IBAction func PeriodChosen(_ sender: AnyObject) {
        generalApproval.isEnabled = false
        
        self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )
        self.thinking.isHidden = false
        self.thinking.startAnimating()
        StatusChosen.isEnabled = false
        periodChosen.isEnabled = false
        ;fetch() }
    
    
        func tableView(_ tableConnect: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableConnect.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! newTableCell
        let record = records[indexPath.row]
        cell.backgroundColor = UIColor.clear

               
        //changing the dates for prentation
        if let fInToDate = record.fIn {
        if ViewController.dateTimeFormat == "DateTime" { cell.l1.text = mydateFormat11.string(from: mydateFormat5.date(from: fInToDate)!)} else {cell.l1.text = mydateFormat10.string(from: mydateFormat5.date(from: fInToDate)!) } }
        else { cell.l1.text = "N/A"}
            
            if record.fIndication3 == "📆" { cell.l8.image = sandwatchImage}
            if record.fIndication3 == "✏️"||record.fIndication3 == "Manual" { cell.l8.image = pencilImage}
            if record.fIndication3 == "↺" {  cell.l8.image = roundImageNormal}
            //if record.fIndication3 == "⏳" {  cell.l8.image = sandwatchImageRed}

     
            if record.fStatus == "Approved" { cell.approval.setImage(Vimage, for: .normal);eventCounter+=1}
            if record.fStatus == "Pre" { cell.approval.setImage(nonVimage, for: .normal)}
            if record.fStatus == "Paid" { cell.approval.setImage(billedImage, for: .normal)}
            

            cell.approval.tag = indexPath.row
            print ("gggggg\(cell.approval.tag)")

 
        cell.approval.removeTarget(self, action:#selector(self.approvalClicked), for: UIControlEvents.touchDown)
        cell.approval.addTarget(self, action:#selector(self.approvalClicked), for: UIControlEvents.touchDown)

        if record.fBill != nil {cell.l7.text = record.fBill!} else {cell.l7.text = ""}
        print ("tag\(cell.approval.tag)")
        return cell
        }//end of func cellforrowat
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var recordRow : IndexPath = self.tableConnect.indexPathForSelectedRow!
        print (recordRow)
        if (segue.identifier == "recordHandler")
        { let recordManager = segue.destination as? datePicker2
        print ("presparesegue")
        recordManager?.recordToHandle = String(idArray[recordRow.row])
        }//end of if (segue...
        }//end of prepare

    
        func tableView(_ tableConnect: UITableView, didSelectRowAt indexPath: IndexPath) {}
        // func for transforming int to h:m:"
        func secondsTo (seconds : Double) -> (Double, Double) {
        return (seconds / 3600, (seconds.truncatingRemainder(dividingBy: 3600)/60))
        }

    
    
        //func for mail
        func  configuredMailComposeViewController2() -> MFMailComposeViewController {
        let mailComposerVC2 = MFMailComposeViewController()
        mailComposerVC2.mailComposeDelegate = self
        mailComposerVC2.setSubject("PerSession - \(counterForMail2!)")
        mailComposerVC2.setMessageBody("\(mailSaver!)", isHTML: false)
        mailComposerVC2.setToRecipients([employerMail])
        mailComposerVC2.setCcRecipients([ViewController.fixedemail])
        DispatchQueue.main.asyncAfter(deadline: .now()+2){
        self.saveBase64StringToPDF(self.mailSaver!)
        }
        return mailComposerVC2
        }//end of MFMailcomposer
    
        func showSendmailErrorAlert() {
        let sendMailErorrAlert = UIAlertController(title:"Could Not Send Email", message: "Your device could not send e-mail. Please check e-mail configuration and try again.",preferredStyle: .alert)
            sendMailErorrAlert.message = "error occured"
        }
    
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
        DispatchQueue.main.asyncAfter(deadline: .now()+0){
            self.alert66() }//it is not function due to window hirerarchy
        print("Mail cancelled")

        case MFMailComposeResult.saved.rawValue:
        print("Mail saved3")
        case MFMailComposeResult.sent.rawValue:
        print("Mail sent3")
        case MFMailComposeResult.failed.rawValue:
        print("Mail sent failure: %@", [error!.localizedDescription])
        default:
        break
        }//end of switch
        
        thinking.startAnimating()
        self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )
        DispatchQueue.main.asyncAfter(deadline: .now()+2){ //probably sensetive delay
        controller.dismiss(animated: true, completion: nil)
        }
        
        self.navigationController!.popViewController(animated: true)
        }//mfmailcomposercontrollet
    
        func  approvalClicked(sender:UIButton!) {
        
        billSender.isEnabled = false
        self.billPay.isEnabled = false

        buttonRow = sender.tag
        
        if appArray[buttonRow] == "Pre" { newVCTable.checkBox = 1; statusTemp = "Approved";eventCounter+=1;amountCalc()}
            else if appArray[buttonRow] == "Approved" { newVCTable.checkBox = 0; statusTemp = "Pre";eventCounter-=1;amountCalc()}
        else if  appArray[buttonRow] == "Paid" {newVCTable.checkBox = 2; statusTemp = "Paid";alert12()}
        print( "apparray buttonarray\(appArray[buttonRow])")
        print( "checkBox\(newVCTable.checkBox)")
        if self.eventCounter == 0 {self.eventsLbl.text = " No Due Sessions"} else if self.eventCounter == 1 {self.eventsLbl.text = "\(String(self.eventCounter)) Due session"} else {self.eventsLbl.text = "\(String(self.eventCounter)) due Sessions"}
        
        if statusTemp != appArray[buttonRow] {
        appArray[buttonRow] = statusTemp!
        
       self.dbRef.child(String(idArray[buttonRow])).updateChildValues(["fStatus": statusTemp!], withCompletionBlock: { (error) in}) //end of update.
        }
        print("id55\([idArray])")
        print("status\([appArray])")

        DispatchQueue.main.asyncAfter(deadline: .now()+1){
        self.billSender.isEnabled = true
        self.billPay.isEnabled = true

        }
        }//end button clicked
    
        // button  General on table clicked
        func  generalApprovalClicked() {
        if appArray.count != 0 {
        for h in 0...(appArray.count-1){
        buttonRow = h
        
        if checkBoxGeneral == 1 {  statusTemp = "Approved";segmentedPressed = 1 }
        else if checkBoxGeneral == 2 {statusTemp = "Paid";segmentedPressed = 2 }
        else if checkBoxGeneral == 0  { statusTemp = "Paid";segmentedPressed = 2 }
        if statusTemp != appArray[buttonRow] {
            appArray[buttonRow] = statusTemp!
            
        print("id\([idArray])")
        print("status\([appArray])")
            
        self.dbRef.child(String(idArray[buttonRow])).updateChildValues(["fStatus": statusTemp!], withCompletionBlock: { (error) in}) //end of update.
        }
        if checkBoxGeneral == 2{
        self.dbRef.child(String(idArray[buttonRow])).updateChildValues(["fBill": counterForMail2!], withCompletionBlock: { (error) in}) //end of update.
        }
         
        }//end of loop
        }//end of if
        }//end button  Generalclicked
    
        func fetch()  {
        
        eventCounter = 0
        self.idArray.removeAll()
        self.appArray.removeAll()
        self.records.removeAll()
        self.FbArray.removeAll()
        self.FbArray2.removeAll()
        htmlReport = nil
        
        self.csv2.append( ("Sessions:\r\n"))
        self.tableConnect.reloadData()
        dbRefEmployers.child(self.employerID).child("myEmployees").queryOrderedByKey().queryEqual(toValue: employeeID).observeSingleEvent(of: .childAdded, with:  {(snapshot) in
        self.Employerrate = Double(snapshot.childSnapshot(forPath: "fEmployerRate").value! as! Double)
        
        self.dbRefEmployers.child(self.employerID).child("fEmployerRecords").queryOrderedByValue().observeSingleEvent(of: .value, with: { (snapshot) in
        print("id of employers34\(String(describing: snapshot.value))")
          
        if snapshot.value as? [String : AnyObject] == nil {

        }else{
            
        self.idOfEmployers   = snapshot.value as! [String : AnyObject]
            
        func sortFunc   (_ s1: (key: String, value: AnyObject), _ s2: (key: String, value: AnyObject)) -> Bool {
        return   s2.value as! Int > s1.value as! Int
        }

        self.FbArray = (self.idOfEmployers.sorted(by: sortFunc) as [AnyObject] )
        print ("recordsFB\(self.FbArray)")
            
        for j in 0...(self.FbArray.count-1){
        let splitItem = self.FbArray[j] as! (String, AnyObject)
        print (splitItem)
        let split2    = splitItem.0
        print (split2)
        self.FbArray2.append(split2)
        }
           
        for i in 0...(self.FbArray2.count-1)  {

        if i == 0 {
        self.thinking.isHidden = false
        self.thinking.startAnimating()
        }
                
        if i == (self.FbArray2.count-1 ){
            }
        self.dbRef.child((self.FbArray2[i])).observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
        let record = recordsStruct()
        record.setValuesForKeys(dictionary)
        if record.fStatus == "W" || record.fEmployeeRef != self.employeeID {
        //do nothing
        }else{
        //array for record ID
        let id = snapshot.key
            let appStatus = record.fStatus
                        
        let period: Int = 5//self.periodChosen.selectedSegmentIndex
                        
        //handle to string to date of fIN from firbase/
        let finManupulated =  self.mydateFormat5.date(from: record.fIn!) //brings the string as a date
            
        //brings the month and day
        var calendar = Calendar.current
           // calendar.firstWeekday = 2 // set the week to start on monday
        let components = calendar.dateComponents([.year, .month, .day, ], from: finManupulated!)
        let today = calendar.dateComponents([.year, .month, .day], from: Date())
        self.recotdMonth = components.month!
        //self.recordWeek = components.weekOfYear!
        self.recordYear = components.year!
       // self.recordYearForWeek = components.yearForWeekOfYear!

        self.currentMonth = today.month!
        //self.currentWeek = today.weekOfYear!
            
        self.currentYear = today.year!
        //self.currentYearForWeek = today.yearForWeekOfYear!

                        
        func cases() {
        self.currentYear = today.year!
        //self.currentYearForWeek = today.yearForWeekOfYear!
        self.records.append(record)
        self.idArray.append(id)
        self.appArray.append(appStatus!)
        self.tableConnect.reloadData()
         
        if ViewController.dateTimeFormat == "DateTime" {"\(self.csv2.append( self.mydateFormat11.string(from: self.mydateFormat5.date(from: record.fIn!)!) ))";self.csv2.append("\r\n")
        } else {"  \(self.csv2.append( self.mydateFormat10.string(from: self.mydateFormat5.date(from: record.fIn!)!) ))";self.csv2.append("\r\n") }
            
        }// end of cases func
                        
        switch period{
        //current week
       /* case 0:
        if self.recordWeek == self.currentWeek && self.recordYearForWeek == self.currentYearForWeek && record.fStatus! == self.Status
        {cases()} else if self.recordWeek == self.currentWeek && self.recordYearForWeek == self.currentYearForWeek  && self.Status == "All"
        {cases() }
                            
        //last week
        case 1:
        if self.currentWeek-1 == 0 {self.currentWeek = 53; self.currentYearForWeek = (self.currentYearForWeek - 1)}
        if self.recordWeek == self.currentWeek-1 && self.recordYearForWeek == self.currentYearForWeek && record.fStatus! == self.Status
        {cases()} else if self.recordWeek == self.currentWeek-1 && self.recordYearForWeek == self.currentYearForWeek && self.Status == "All"
        {cases()}
                            
        //current month
        case 2:
        if self.recotdMonth == self.currentMonth && self.recordYear == self.currentYear && record.fStatus! == self.Status {cases()}
        else if self.recotdMonth == self.currentMonth && self.recordYear == self.currentYear && self.Status == "All"
        {cases()}
                            
        //last month
        case 3:
        if self.currentMonth-1 == 0 {self.currentMonth = 13 ; self.currentYear = (self.currentYear - 1)}
        if self.recotdMonth == (self.currentMonth-1) && self.recordYear == self.currentYear && record.fStatus! == self.Status
        {cases()} else if self.recotdMonth == (self.currentMonth-1) && self.recordYear == self.currentYear && self.Status == "All"
        {cases()}
         */
        //all periods
        default :
        if self.Status == "Approved" {if record.fStatus == "Approved" {cases()}} else if
        record.fStatus == "Pre" || record.fStatus == "Approved" {cases()
        }else if record.fStatus == nil
        {}
        else if self.Status == "All"
        {cases()}
        else {print ("in else: calc is :\(self.calc)")
        self.amount.text =  ("\(ViewController.fixedCurrency!)\(String(Double(self.calc).roundTo(places: 2)))")
        }
                            
        }//end of period switch
  
        }//end of else of fout is not empty
                    
        }// end of if let dictionary

        }, withCancel: { (Error) in
        print("error from FB")}
        )//end of dbref2
            
        }//end of loop
        }//end of elseif snapshot.value as? String == nil

        if self.releaser == 0 { self.thinking.stopAnimating()}
        sleep(UInt32(1))
        self.StatusChosen.isEnabled = true
        self.periodChosen.isEnabled = true
 
        }, withCancel: { (Error) in
        print("error from FB")}
        )//end of dbref1the second one
          
        }) //end of dbref employers0 the first one

        dbRef.removeAllObservers()
        dbRefEmployers.removeAllObservers()

        DispatchQueue.main.asyncAfter(deadline: .now()+3){
        if self.idArray.isEmpty == true {self.noSign.isHidden = false} else {self.noSign.isHidden = true}
        print (self.idArray.isEmpty)

        if self.eventCounter == 0 {self.eventsLbl.text = " No Due Sessions"} else if self.eventCounter == 1 {self.eventsLbl.text = "\(String(self.eventCounter)) Due session"} else {self.eventsLbl.text = "\(String(self.eventCounter)) due Sessions"}

        if self.Status == "All" /*|| self.Status == "Paid"*/{self.generalApproval.isHidden = true}
        self.calc = (Double(self.eventCounter))*(self.Employerrate)

        self.perEvents.text =  String("\(ViewController.fixedCurrency!)\(self.Employerrate) /session")

        self.amount.text =  ("\(ViewController.fixedCurrency!)\(String(Double(self.calc).roundTo(places: 2)))")

        if self.eventCounter != 0 {if self.rememberMe1 == 0 {self.alert90()}; self.generalApproval.isHidden = true;self.generalApproval.isEnabled = true;  if self.releaser == 0 {self.billSender.isEnabled = true;self.billPay.isEnabled = true}
        }else {
        self.billSender.isEnabled = false
        self.billPay.isEnabled = false

        self.generalApproval.isHidden = true;
        }
        }//end of dispatch
        }//end of fetch
    
        func amountCalc(){
        self.calc = (Double(self.eventCounter))*(self.Employerrate)
        self.amount.text =   ("\(ViewController.fixedCurrency!)\(String(Double(self.calc).roundTo(places: 2)))")
        }
    
        func noFB() {
        self.thinking.stopAnimating()
        self.alert30()
        }
    
        func billing(){
        taxationBlock = ""
        biller = true
        self.dbRefEmployees.queryOrderedByKey().queryEqual(toValue: self.employeeID).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            let counterForMail = (snapshot.childSnapshot(forPath: "fCounter").value as! String)
            let taxation = (snapshot.childSnapshot(forPath: "fTaxPrecentage").value as! String)
            let taxName = (snapshot.childSnapshot(forPath: "fTaxName").value as! String)
            self.taxCalc = (snapshot.childSnapshot(forPath: "fTaxCalc").value as! String)
            self.taxSwitch = (snapshot.childSnapshot(forPath: "fSwitcher").value as! String)
            self.paypal = (snapshot.childSnapshot(forPath: "fPaypal").value as! String)
            self.billInfo = (snapshot.childSnapshot(forPath: "fBillinfo").value as! String)
            self.address = (snapshot.childSnapshot(forPath: "fAddress").value as! String)

            if  self.taxSwitch == "Yes" {
            if self.self.taxCalc == "Over" {self.self.stam =  Double(Double(taxation)!*self.calc*0.01).roundTo(places: 2)}  else  { self.stam = Double((self.calc / Double(Double(taxation)!*0.01+1)) * Double(Double(taxation)!*0.01)).roundTo(places: 2)}

            if self.self.taxCalc == "Over" {self.stam3 = Double(self.calc).roundTo(places: 2)}  else  { self.stam3 =  self.calc -  Double((self.calc / Double(Double(taxation)!*0.01+1)) * Double(Double(taxation)!*0.01)).roundTo(places: 2)}
              
            self.midCalc =  String (describing: self.stam!)
            self.midCalc3 =  String(describing: self.stam3!)
                print (self.midCalc)
            if taxName == "" {self.taxForBlock = "Tax"} else {self.taxForBlock = taxName}
                print (self.midCalc3)
            self.midCalc2 =  String(self.stam3! + self.stam!)
            
            self.taxationBlock = ("\(self.taxForBlock): \(ViewController.fixedCurrency!)\(self.midCalc)\r\n Total (w/\(self.taxForBlock)): \(ViewController.fixedCurrency!)\(self.midCalc2)")
             } else {
            self.taxationBlock = ""}
            
            if self.paymentReference != "" {self.refernceBlock = "Ref:\(self.paymentReference!)"} else {self.refernceBlock = ""}
            

            if self.recieptDate != "" {self.documentName = "Bill & Payment"; if self.paymentSys == "other" || self.paymentSys == ""{self.paymentBlock = ("Payment of \(ViewController.fixedCurrency!)\(self.midCalc2) made: \(self.mydateFormat10.string(from:self.mydateFormat5.date(from: self.recieptDate!)!)) - \(self.refernceBlock) ")
                }
            else{self.paymentBlock = "Payment of \(ViewController.fixedCurrency!)\(self.midCalc2) made by \(self.paymentSys!) \(self.refernceBlock) - \(self.mydateFormat10.string(from:self.mydateFormat5.date(from: self.recieptDate!)!))"
                }
                
            }else{self.documentName = "Bill"; // no payment only bill
            if self.paypal != "" { self.paymentBlock = ("Payment can be made through Paypal: \(self.paypal!)/\(self.midCalc2)")}else {self.paymentBlock = ""}
            }// end of else  self.paymentDate != ""
            
   
            self.counterForMail2 = counterForMail
            print("guygug3\(self.counterForMail2!)")
            })
            }//end of billing
    
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
    
        func refresh(presser:Int){
        StatusChosen.isMomentary = true
        segmentedPressed = presser
        StatusChosen.selectedSegmentIndex = segmentedPressed!
        StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
        StatusChosen.isMomentary = false
        }
    
        func paymentRef(){
            paymentView.isHidden = false
            
        }

  
    // alerts/////////////////////////////////////////////////////////////////////////////////////
    func alert30(){
    let alertController30 = UIAlertController(title: ("No connection") , message: "Currently there is no connection with database. Please try again.", preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
    }

    alertController30.addAction(OKAction)
    self.present(alertController30, animated: true, completion: nil)
    }
    
    func alert90(){
    let alertController90 = UIAlertController(title: ("Preapre Due Records") , message: "You can mark your Sessions as 'Due' by touching the empty square.", preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
    self.keeper.set(1, forKey: "dueInstruction")
    self.rememberMe1 = 1
    self.billSender.isEnabled = true
    self.billPay.isEnabled = true

    }
    alertController90.addAction(OKAction)
    self.present(alertController90, animated: true, completion: nil)
    }
    
    func alert11(){
    generalApproval.isHidden = true;
    if checkBoxGeneral == 1 {  generalChange =  "You are about to change status for all  records in this list to 'Due'. Records would be added  under their new status. You can 'Undo' spesific record by clicking 'Due' icon on each record."}
    else if checkBoxGeneral == 2 {generalChange = "Mail with bill of due records is preapred. Sending or saving the mail, would change records to final status of 'Billed'."}
    else if checkBoxGeneral == 0 { generalChange = "You can not change status of records that were already billed."}
    if appArray.count == 0 {}
    else {
    let alertController11 = UIAlertController(title: ("Change list of records") , message: generalChange , preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
    if self.checkBoxGeneral == 1{
    self.generalApprovalClicked()
    }
    else if self.checkBoxGeneral == 2{
    self.billing()
    }
    else {//do nothing
    }
    self.generalApproval.isHidden = true;
    }
    let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
    if self.checkBoxGeneral == 2 {self.segmentedPressed = 1}
    else if self.checkBoxGeneral == 0 { self.segmentedPressed = 2}
    else if self.checkBoxGeneral == 1 {self.segmentedPressed = 0 }
    self.StatusChosen.selectedSegmentIndex = self.segmentedPressed!
    self.generalApproval.isHidden = true;
    }
    alertController11.addAction(OKAction)
    if self.checkBoxGeneral != 0 { alertController11.addAction(CancelAction)}
    self.present(alertController11, animated: true, completion: nil)
    }
    }//end of alert11
    
    func billProcess() {
    self.thinking.startAnimating()
    if paymentDate! == "" {paymentDate = mydateFormat5.string(from: Date()) }
    self.billing()

    DispatchQueue.main.asyncAfter(deadline: .now()+2){
    self.htmlReport = self.csv2 as String!
    if self.biller == true {self.dbRefEmployees.child(self.employeeID).updateChildValues(["fCounter": String(describing: (Int(self.counterForMail2!)!+1))])//add counter to invouce #

    self.biller = false
        
        self.mailSaver = "\(self.mydateFormat10.string(from: Date()))\r\nRef#: \(self.documentName!)-\(self.counterForMail2!)\r\nAccount: \(self.employerFromMain!)\r\n\r\n\(self.billInfo!)\r\n\(self.address!)\r\n\r\nHi, \r\n\r\nThese are the sessions,  we had together:\r\n\(self.htmlReport!)\r\nTotal Number of sessions: \(self.eventCounter) \r\n\(self.perEvents.text!)\r\n \r\nTotal: \(ViewController.fixedCurrency!)\(self.midCalc3)\r\n\(self.taxationBlock)\r\n\r\n\r\n\(self.paymentBlock)\r\n\r\nRegards\r\n\(ViewController.fixedName!)\(ViewController.fixedLastName!)\r\n\r\nMade by PerSession app. "


    //update bill with DB
        self.dbRefEmployees.child(self.employeeID).child("myBills").child("-\(self.counterForMail2!)").updateChildValues(["fBill": self.counterForMail2!,"fBillDate": self.mydateFormat5.string(from: Date()) ,"fBillStatus": self.billStatus!, "fBillEmployer": self.employerID,"fBillEventRate": self.perEvents.text!, "fBillEvents": String(self.eventCounter) as String,"fBillSum": self.midCalc3, "fBillCurrency": ViewController.fixedCurrency!,"fBillEmployerName": self.employerFromMain!, "fBillMailSaver" : self.mailSaver!,"fBillTax" : self.midCalc ,"fBillTotalTotal": self.midCalc2,"fPaymentMethood": self.paymentSys, "fPaymentReference": self.paymentReference, "fDocumentName":self.documentName!,"fRecieptDate":self.recieptDate!,"fBillRecieptMailSaver":""
    ], withCompletionBlock: { (error) in}) //end of update.//was 0
    self.generalApprovalClicked()
    }//end of if biller
    }//end of dispatch
    }//end of billprocess
    
    func alert19(){
    DispatchQueue.main.asyncAfter(deadline: .now()){
    self.billSender.isEnabled = false
    self.billPay.isEnabled = false
    }//end of dispatch

    let alertController19 = UIAlertController(title: ("Bill") , message: "Register a new Bill and set sessions from 'Due' to 'Billed'." , preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "Just do it", style: .default) { (UIAlertAction) in
    self.billProcess()
    self.navigationController!.popViewController(animated: true)

    }
        
    let mailAction = UIAlertAction(title: "Mail it", style: .default) { (UIAlertAction) in
    self.billProcess()
    DispatchQueue.main.asyncAfter(deadline: .now()+2){
    if MFMailComposeViewController.canSendMail() {
    let mailComposeViewController2 = self.configuredMailComposeViewController2()
    self.present(mailComposeViewController2, animated: true, completion: nil)
    }else{
    print ("can't send")
    self.showSendmailErrorAlert() }//end of else
    self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )
    /*
    DispatchQueue.main.asyncAfter(deadline: .now()+2){

    self.segmentedPressed = 0
    self.StatusChosen.selectedSegmentIndex = self.segmentedPressed!
    self.StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
    }//end of dispatch
    */
    }//end of dispatch
    }//end of mail action
        
    let printAction = UIAlertAction(title: "Print it", style: .default) { (UIAlertAction) in
    self.billProcess()
    //add printing process
    self.navigationController!.popViewController(animated: true)

    }
        
    let CancelAction = UIAlertAction(title: "Cancel ", style: .cancel) { (UIAlertAction) in
    self.paymentReference = ""
    self.paymentSys = ""
    self.paymentDate = ""
    self.recieptDate = ""
    self.billStatus = "Billed"
    self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )
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
    
    func alert18(){
    DispatchQueue.main.asyncAfter(deadline: .now()){
    self.billSender.isEnabled = false
    self.billPay.isEnabled = false
    }//end of dispatch
        
    let alertController18 = UIAlertController(title: ("Bill") , message: "Register a new Bill and set sessions from 'Due' to 'Billed'." , preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "Just do it", style: .default) { (UIAlertAction) in
    self.billProcess()
    self.navigationController!.popViewController(animated: true)

    
    }//end of OK
        
    let mailAction = UIAlertAction(title: "Mail it", style: .default) { (UIAlertAction) in
    self.billProcess()
    DispatchQueue.main.asyncAfter(deadline: .now()+2){
    let mailComposeViewController2 = self.configuredMailComposeViewController2()
    if MFMailComposeViewController.canSendMail() {
    self.present(mailComposeViewController2, animated: true, completion: nil)
    }else{ self.showSendmailErrorAlert() }//end of else

    self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )
    
   // DispatchQueue.main.asyncAfter(deadline: .now()+2){
    //self.segmentedPressed = 0
    //self.StatusChosen.selectedSegmentIndex = self.segmentedPressed!
    //self.StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
    //}//end of dispatch
    }//end of dispatch
    }//end of mail
        
    let printAction = UIAlertAction(title: "Print it", style: .default) { (UIAlertAction) in
    self.billProcess()
    //add printing process
    }
        
    let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
    self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )
    self.segmentedPressed = 0
    self.StatusChosen.selectedSegmentIndex = self.segmentedPressed!
    self.StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
    }//end of cancel
        
    alertController18.addAction(OKAction)
    alertController18.addAction(mailAction)
    alertController18.addAction(printAction)
    alertController18.addAction(CancelAction)
    self.present(alertController18, animated: true, completion: nil)
    }//end of alert18
    
    func alert27() {
    DispatchQueue.main.asyncAfter(deadline: .now()){
    self.billSender.isEnabled = false
    self.billPay.isEnabled = false
    }

    let alertController27 = UIAlertController(title: ("Bill records") , message:" There are no  sessions with 'Due' status. Please mark sessions that you would like to bill by touching the empty square or create new 'sessions'." , preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
    self.refresh(presser: 0)
    }
        
    alertController27.addAction(OKAction)
    self.present(alertController27, animated: true, completion: nil)
    }//end of alert27
    
    func alert66() {
        
        let alertController66 = UIAlertController(title: ("Cancel Mail") , message:" Mail was cancelled, but the bill was registered to send it or print it go to bills" , preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            self.refresh(presser: 0)
        }
        
        alertController66.addAction(OKAction)
        self.present(alertController66, animated: true, completion: nil)
    }//end of alert66

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

    }//end of class//////////////////////////////////////////////////////////////

    extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    }

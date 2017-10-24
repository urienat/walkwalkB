//
//  billsTable.swift
//  employee timer
//
//  Created by אורי עינת on 19.2.2017.
//  Copyright © 2017 אורי עינת. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import MessageUI



class billsTable: UIViewController ,UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableConnect: UITableView!
    
    let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
    let Vimage = UIImage(named: "due")
    let nonVimage = UIImage(named: "emptyV")
    let paidImage = UIImage(named: "paid")
    let billedImage = UIImage(named: "locked")
    let billIcon = UIImage(named: "bill")

    //variabled for date filtering
    let mydateFormat = DateFormatter()
    let mydateFormat2 = DateFormatter()
    let mydateFormat3 = DateFormatter()
    
    var whiteColor = UIColor(red :255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    var greenColor = UIColor(red :32.0/255.0, green: 150.0/255.0, blue: 24.0/255.0, alpha: 1.0)
    
    static var paidCheckBox:Int = 0
    
    
    var idOfEmployers: [String:AnyObject] = [:]
    var idOfEmployers2: [String:AnyObject] = [:]
    
    var FbArray: [AnyObject] = []
    var FbArray2: [String] = []
    
    var idArray: [String] = []
    var appArray: [String] = []
    var Status: String = "Pre"
    let cellId =  "cellId"
    var eventCounter = 0
    var timeCounter = 0.0
    var calc = 0.0
    var Employerrate = 0.0
    var payment = ""
    let formatter = NumberFormatter()
    var spesificToInt = 0.00
    var employerFromMain: String?
    var buttonRow = 0
    
    var segmentedPressed:Int?
    
    
    var employerID = ""
    var employeeID = ""
    /*

    
    
    var counterForMail2: String?
    
    var recotdMonth : Int = 0
    var recordDay : Int = 0
    var recordWeek : Int = 0
    var recordYear : Int = 0
    var recordYearForWeek : Int = 0
    
    var currentMonth : Int = 0
    var currentDay : Int = 0
    var currentWeek : Int = 0
    var currentYear : Int = 0
    var currentYearForWeek :Int = 0
    
    let dbRef = FIRDatabase.database().reference().child("fRecords")
    let dbRefEmployers = FIRDatabase.database().reference().child("fEmployers")
    let dbRefEmployees = FIRDatabase.database().reference().child("fEmployees")
    
    
    
    
    @IBAction func exportData(_ sender: Any) {alert()}
    @IBOutlet weak var eventsNumber: UILabel!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var perEvents: UILabel!
    @IBOutlet weak var perHour: UILabel!
    @IBOutlet weak var currencySymbol: UILabel!
    @IBOutlet weak var noSign: UIImageView!
    @IBAction func sendABill(_ sender: Any) {
        
        
        
        
        //refresh
        StatusChosen.isMomentary = true
        segmentedPressed = 1
        StatusChosen.selectedSegmentIndex = segmentedPressed!
        
        StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
        
        StatusChosen.isMomentary = false
        
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1){
            self.alert19()
        }
        
    }//end of approval button
    
    
    @IBOutlet weak var thinking: UIActivityIndicatorView!
    
    var records = [recordsStruct]()
    
    @IBOutlet weak var totalBackground: UIView!
    
    @IBOutlet weak var generalApproval: UIButton!
    @IBAction func generalApproval(_ sender: Any) {
        generalApproval.isHidden = true
        
        print("checkBoxcell\(checkBoxGeneral)")
        
        if  checkBoxGeneral == 2 {
            //refresh
            StatusChosen.isMomentary = true
            segmentedPressed = 1
            StatusChosen.selectedSegmentIndex = segmentedPressed!
            
            StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
            
            StatusChosen.isMomentary = false
            
            
        }
        
        if  checkBoxGeneral == 1         {
            //refresh
            StatusChosen.isMomentary = true
            segmentedPressed = 1
            StatusChosen.selectedSegmentIndex = segmentedPressed!
            
            StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
            
            StatusChosen.isMomentary = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1){
            self.alert11()
        }
        /*switch checkBoxGeneral {
         //pre
         case 0: generalApproval.setImage(billedImage, for: .normal); checkBoxGeneral = 1 //
         
         
         
         //Approved
         case 1:segmentedPressed = 1
         StatusChosen.selectedSegmentIndex = segmentedPressed!
         //generalApproval.setImage(billIcon, for: .normal);checkBoxGeneral = 2//in the end of due
         //Paid
         case 2:  generalApproval.setImage(billedImage, for: .normal);checkBoxGeneral = 0// in the  end of billing
         //default
         default: break
         ////
         } //end of switch
         DispatchQueue.main.asyncAfter(deadline: .now()+1){
         self.alert11()}
         */
    }//end of approval button
    
    
    
    
    /////////////////////////////////////////////////  view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImage.image = UIImage(named: "Grass5")
        
        
        
        self.view.insertSubview(backgroundImage, at: 0)
        
        
        let titleLbl = employerFromMain! + "'s"
        self.title = titleLbl
        
        //connectivity
        if Reachability.isConnectedToNetwork() == true
        {
            print("Internet Connection Available!")
        }
        else
        {
            print("Internet Connection not Available!")
        }
        
        
        //formatting decimal
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.roundingMode = .up
        
        
        tableConnect.delegate = self
        tableConnect.dataSource = self
        
        
        //formating the date
        mydateFormat.dateFormat = DateFormatter.dateFormat(fromTemplate:  " EEE-dd-MMM-yyyy, (HH:mm)"
            ,options: 0, locale: nil)!
        mydateFormat2.dateFormat = DateFormatter.dateFormat(fromTemplate:  " HH:mm"
            , options: 0, locale: nil)!
        mydateFormat3.dateFormat = DateFormatter.dateFormat(fromTemplate:  " MM/dd/yyyy"
            , options: 0, locale: nil)!
        
        dbRefEmployers.child(self.employerID).observeSingleEvent(of:.value, with: {(snapshot) in
            self.employerMail = String(describing: snapshot.childSnapshot(forPath: "fMail").value!) as String!
            
            //print ("fgu\(self.employerMail)")
            
        })
        
        self.thinking.color = self.greenColor
        self.thinking.isHidden = false
        self.thinking.startAnimating()
        StatusChosen.isEnabled = false
        periodChosen.isEnabled = false
        self.thinking.hidesWhenStopped = true
        
        
    }//end of view did load/////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
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
        
        eventCounter = 0
        timeCounter = 0.0
        fetch()
    }//view did appear end
    
    func tableView(_ tableConnect: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count}
    
    @IBOutlet weak var StatusChosen: UISegmentedControl!
    
    
    
    @IBAction func StatusChosen(_ sender: AnyObject) {
        
        print("pressed")
        // totalBackground.backgroundColor = whiteColor
        noSign.isHidden = true
        generalApproval.isEnabled = false
        saveToFB() //check why is it here?
        // alert()
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
        self.csv.deleteCharacters(in: NSMakeRange(0, self.csv.length-1) )
        self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )
        
        fetch()  }//end of status chosen
    
    @IBOutlet weak var periodChosen: UISegmentedControl!
    @IBAction func PeriodChosen(_ sender: AnyObject) {saveToFB()
        totalBackground.backgroundColor = greenColor
        
        noSign.isHidden = true
        
        generalApproval.isEnabled = false
        
        
        
        self.csv.deleteCharacters(in: NSMakeRange(0, self.csv.length-1) )
        self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )
        self.thinking.isHidden = false
        self.thinking.startAnimating()
        StatusChosen.isEnabled = false
        periodChosen.isEnabled = false
        
        ;fetch() }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning() }
    
    
    func tableView(_ tableConnect: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("id3\([idArray])")
        print("status3\([appArray])")
        
        let cell = tableConnect.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! newTableCell
        
        print("id2\([idArray])")
        print("status2\([appArray])")
        
        let record = records[indexPath.row]
        
        //changing the Total for presentation
        if let recordToInt = Double(record.fTotal!) {
            let (h,m) = secondsTo(seconds: (recordToInt))
            cell.l3.text = String(Int(h)) + "h:" + String (Int(m)) + "m"}
        else {cell.l3.text = "   N/A"}
        
        //changing the dates for prentation
        if let fInToDate = record.fIn {
            cell.l1.text = fInToDate}
        else { cell.l1.text = "N/A"}
        
        
        cell.l2.text = "Till " + mydateFormat2.string(from: mydateFormat.date(from: record.fOut!)!)
        cell.l4.text = ("\(record.fIndication!) \(record.fIndication3!) \(record.fIndication2!)")
        if record.fPoo == "Yes" { cell.l5.text = "💩"} else {cell.l5.text = ""}
        if record.fPee == "Yes" { cell.l6.text = "💧"} else {cell.l6.text = ""}
        
        if record.fStatus == "Approved" { cell.approval.setImage(Vimage, for: .normal)}
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
            // print ("segue:" + idArray[recordRow])
            //sleep (0)
        }//end of if (segue...
        
        
    }//end of prepare
    
    
    func tableView(_ tableConnect: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    // func for transforming int to h:m:"
    func secondsTo (seconds : Double) -> (Double, Double) {
        return (seconds / 3600, (seconds.truncatingRemainder(dividingBy: 3600)/60))
    }
    
    
    
    //mail export
    func alert () {
        print("export")
        let alertController = UIAlertController(title: "Export \(employerFromMain!)'s records to your email for archive purposes. For billing , please use 'Bill' function on 'Due' records.  ", message: "Are You Sure?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            //nothing
            self.csv.deleteCharacters(in: NSMakeRange(0, self.csv.length-1) )
            self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )
        }//end of cancel action
        
        let exportAction = UIAlertAction(title: "Yes, preapre it.", style: .default) { (UIAlertAction) in
            print ("Export it!!!")
            self.csvReport = self.csv.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)! as Data
            self.htmlReport = self.csv2 as String!
            
            let mailComposeViewController = self.configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } //end of if
            else{ self.showSendmailErrorAlert() }
            // navigationController!.popViewController(animated: true)
            self.csv.deleteCharacters(in: NSMakeRange(0, self.csv.length-1) )
            self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )
        }//end of export action
        
        alertController.addAction(cancelAction)
        alertController.addAction(exportAction)
        present(alertController, animated: true, completion: nil)
    } //end of func alert (mail export)
    
    
    //mail export for client
    func alert6 () {
        print("export")
        let alertController6 = UIAlertController(title: "Mail to \(employerFromMain!) their due records", message: "Are You Sure?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            //nothing
            self.csv.deleteCharacters(in: NSMakeRange(0, self.csv.length-1) )
            self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )
            self.segmentedPressed = 0
            self.StatusChosen.selectedSegmentIndex = self.segmentedPressed!
            self.StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
            
        }//end of cancel action
        
        let exportAction = UIAlertAction(title: "Yes, prepare mail.", style: .default) { (UIAlertAction) in
            print ("Send it")
            
            print (self.employeeID)
            
            
            
            
            self.csvReport = self.csv.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)! as Data
            self.htmlReport = self.csv2 as String!
            
            
            
            let mailComposeViewController2 = self.configuredMailComposeViewController2()
            if MFMailComposeViewController.canSendMail() {
                
                self.present(mailComposeViewController2, animated: true, completion: nil)
            } //end of if
            else{ self.showSendmailErrorAlert() }
            // navigationController!.popViewController(animated: true)
            self.csv.deleteCharacters(in: NSMakeRange(0, self.csv.length-1) )
            self.csv2.deleteCharacters(in: NSMakeRange(0, self.csv2.length-1) )
        }//end of export action
        
        alertController6.addAction(cancelAction)
        alertController6.addAction(exportAction)
        present(alertController6, animated: true, completion: nil)
    } //end of func alert (mail export)
    
    //func for export
    func  configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setSubject("csv file from your app")
        mailComposerVC.setMessageBody("\(mydateFormat3.string(from: Date()))  \r\n\r\n\r\n Hi, \r\n \r\n These are records for  period chosen (csv file is attached as well):\r\n\(htmlReport!)\r\n number of records:\(self.eventCounter)\r\n Total time: \(totalTime.text!)\r\n \(self.perEvents.text!)\r\n \(self.perHour.text!)\r\n \r\nTotal (\(ViewController.fixedCurrency!)): \(self.amount.text!)\r\n\r\n\r\n Regards WalkWalk app )", isHTML: false)
        mailComposerVC.setToRecipients([ViewController.fixedemail])
        mailComposerVC.addAttachmentData(csvReport!, mimeType: "text/csv", fileName: "Your pets' records")//the csv attachement through here
        return mailComposerVC
    }//end of MFMailcomposer
    
    //func for mail
    func  configuredMailComposeViewController2() -> MFMailComposeViewController {
        let mailComposerVC2 = MFMailComposeViewController()
        mailComposerVC2.mailComposeDelegate = self
        mailComposerVC2.setSubject("Records from your petcare")
        mailComposerVC2.setMessageBody("\(mydateFormat3.string(from: Date()))\r\n ref#: app-\(counterForMail2!)\r\n\r\n\r\n Hi, \r\n \r\n These are due records for the period:\r\n\(htmlReport!)\r\n number of records:\(self.eventCounter)\r\n Total time: \(totalTime.text!)\r\n \(self.perEvents.text!)\r\n \(self.perHour.text!)\r\n \r\nTotal due(\(ViewController.fixedCurrency!)): \(self.amount.text!)\r\n\r\n\r\n Regards\r\n  \(ViewController.fixedName!) \(ViewController.fixedLastName!) ", isHTML: false)
        mailComposerVC2.setToRecipients([employerMail])
        mailComposerVC2.setCcRecipients([ViewController.fixedemail])
        
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
        case MFMailComposeResult.saved.rawValue:
            print("Mail saved3")
            if biller == true {self.dbRefEmployees.child(self.employeeID).updateChildValues(["fCounter": String(describing: (Int(self.counterForMail2!)!+1))])//add counter to invouce #
                //update bill with DB
                self.dbRefEmployees.child(employeeID).child("myBills").child(counterForMail2!).updateChildValues(["fBill": counterForMail2!,"fBillDate": mydateFormat.string(from: Date()) ,"fBillStatus": "Billed", "fBillEmployer": self.employerID,"fBillPayment":self.payment,"fBillEventRate": perEvents.text!,"fBillHourRate": perHour.text!, "fBillEvents": String(eventCounter) as String,"fBillTotalTime": totalTime.text!,"fBillSum": self.amount.text!, "fBillCurrency": ViewController.fixedCurrency!
                    ], withCompletionBlock: { (error) in}) //end of update.
                
                
                
                
                self.generalApprovalClicked()
                
            }
            
        case MFMailComposeResult.sent.rawValue:
            print("Mail sent3")
            if biller == true {            self.dbRefEmployees.child(self.employeeID).updateChildValues(["fCounter": String(describing: (Int(self.counterForMail2!)!+1))])//add counter to invouce #
                self.generalApprovalClicked()
                
            }
            
        case MFMailComposeResult.failed.rawValue:
            print("Mail sent failure: %@", [error!.localizedDescription])
        default:
            break
        }
        // Dismiss the mail compose view controller.
        biller = false
        controller.dismiss(animated: true, completion: nil)
        
        
    }
    
    func thisWeek() {}
    
    //image background rotation
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if(UIApplication.shared.statusBarOrientation.isLandscape)
        {backgroundImage.frame = self.view.bounds} else   {backgroundImage.frame = self.view.bounds}
    }
    
    
    // button on table clicked
    func  approvalClicked(sender:UIButton!) {
        
        buttonRow = sender.tag
        
        if appArray[buttonRow] == "Pre" { newVCTable.checkBox = 1; statusTemp = "Approved";}
        else if appArray[buttonRow] == "Approved" { newVCTable.checkBox = 0; statusTemp = "Pre"}
        else if  appArray[buttonRow] == "Paid" {newVCTable.checkBox = 2; statusTemp = "Paid";alert12()}
        print( "apparray buttonarray\(appArray[buttonRow])")
        print( "checkBox\(newVCTable.checkBox)")
        self.eventsNumber.text = String(self.eventCounter)
        
        if statusTemp != appArray[buttonRow] {
            appArray[buttonRow] = statusTemp!
            
            print("id\([idArray])")
            print("status\([appArray])")
            
            
            self.dbRef.child(String(idArray[buttonRow])).updateChildValues(["fStatus": statusTemp!], withCompletionBlock: { (error) in}) //end of update.
        }
        print("id55\([idArray])")
        print("status\([appArray])")
        
        
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
                
                
                
                
                
                print("id55\([idArray])")
                print("status\([appArray])")
                
            }//end of loop
            
            
            
            StatusChosen.selectedSegmentIndex = segmentedPressed!
            
            StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
            
            //  self.StatusChosen.isEnabled = false
            // self.periodChosen.isEnabled = false
            // thinking.startAnimating()
            
            
            // fetch()
        }//end of if
    }//end button  Generalclicked
    
    func segmentChanged() {
        
        
    }
    
    func saveToFB (){
        // print(idArray)
        //for (index,_) in idArray.enumerated() {
        //self.dbRef.child(String(idArray[index])).updateChildValues(["fStatus": appArray[index]], withCompletionBlock: { (error) in }) //end of update.
        
        //}
        
        //fetch()
        
    }
    
    
    
    func fetch()  {
        
        
        eventCounter = 0
        timeCounter = 0.0
        self.idArray.removeAll()
        self.appArray.removeAll()
        self.records.removeAll()
        self.FbArray.removeAll()
        self.FbArray2.removeAll()
        
        csvReport = nil
        htmlReport = nil
        print ("fff\(csv)")
        
        
        self.csv.append("Pet Family, Date In, Time In,Date Out, Time Out, Total,Gps/Manual,Indication IN, Indication Out, Status, Bill#,\n")
        //self.csv2.append( ("Hi, \r\n \r\n These are due records for the period:\r\n")) ;self.csv2.append("\r\n")
        self.csv2.append( ("Status             Date\t                               Total\r\n\r\n"))
        
        self.tableConnect.reloadData()
        dbRefEmployers.child(self.employerID).child("myEmployees").queryOrderedByKey().queryEqual(toValue: employeeID).observeSingleEvent(of: .childAdded, with:  {(snapshot) in
            
            
            
            self.payment = String(describing: snapshot.childSnapshot(forPath: "fPayment").value!) as String!
            self.Employerrate = Double(snapshot.childSnapshot(forPath: "fEmployerRate").value! as! Double)
            
            self.dbRefEmployers.child(self.employerID).child("fEmployerRecords").queryOrderedByValue().observeSingleEvent(of: .value, with: { (snapshot) in
                print("id of employers34\(snapshot.value)")
                
                if snapshot.value as? [String : AnyObject] == nil {
                    print("null")
                    //self.alert9()
                    
                }
                else{
                    
                    
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
                    print("fbarray22\([self.FbArray])")
                    
                    print ("recordsFB2\(self.FbArray2)")
                    
                    
                    
                    
                    
                    for i in 0...(self.FbArray2.count-1)  {
                        print("i\(i)")
                        
                        if i == 0 {
                            self.thinking.isHidden = false
                            self.thinking.startAnimating()
                            
                        }
                        
                        if i == (self.FbArray2.count-1 ){
                            
                            //self.thinking.stopAnimating()
                            print("end of fbarray2")
                            
                            
                        }
                        print ("fbarray beforedbred\(self.FbArray2[i])")
                        self.dbRef.child((self.FbArray2[i])).observeSingleEvent(of: .value, with: { (snapshot) in
                            print("gggg\([self.FbArray2[i]])")
                            
                            print ("snapppp\(snapshot.value)")
                            if let dictionary = snapshot.value as? [String: AnyObject] {
                                print("!!!!!")
                                let record = recordsStruct()
                                record.setValuesForKeys(dictionary)
                                print ("dic :\(dictionary)")
                                
                                
                                //ignore if FOUT = nil
                                if record.fOut == nil || record.fEmployeeRef != self.employeeID {
                                    //do nothing
                                }
                                    
                                else{
                                    //array for record ID
                                    let id = snapshot.key
                                    let appStatus = record.fStatus
                                    
                                    //Switch cases
                                    let period: Int = self.periodChosen.selectedSegmentIndex
                                    
                                    //handle to string to date of fIN from firbase/
                                    print(record.fIn!)
                                    let finManupulated =  self.mydateFormat.date(from: record.fIn!) //brings the string as a date
                                    
                                    print ("StringsToDate"); print (finManupulated as Any)
                                    
                                    
                                    //brings the month and day
                                    var calendar = Calendar.current
                                    calendar.firstWeekday = 2 // set the week to start on monday
                                    let components = calendar.dateComponents([.year, .month, .day, .weekOfYear,.yearForWeekOfYear], from: finManupulated!)
                                    let today = calendar.dateComponents([.year, .month, .day, .weekOfYear, .yearForWeekOfYear], from: Date())
                                    self.recotdMonth = components.month!
                                    self.recordWeek = components.weekOfYear!
                                    self.recordYear = components.year!
                                    self.recordYearForWeek = components.yearForWeekOfYear!
                                    
                                    
                                    self.currentMonth = today.month!
                                    self.currentWeek = today.weekOfYear!
                                    print(self.currentWeek)
                                    print (calendar.firstWeekday)
                                    self.currentYear = today.year!
                                    self.currentYearForWeek = today.yearForWeekOfYear!
                                    print(self.currentYearForWeek)
                                    
                                    
                                    func cases() {
                                        
                                        self.currentYear = today.year!
                                        self.currentYearForWeek = today.yearForWeekOfYear!
                                        
                                        //print (record.fStatus!)
                                        self.spesificToInt = Double(record.fTotal!)!
                                        print("\(record.fTotal)")
                                        self.timeCounter += self.spesificToInt //changed for add per due
                                        
                                        self.records.append(record)
                                        //print("timecounter from switch:, \(self.timeCounter)")
                                        self.idArray.append(id)
                                        self.appArray.append(appStatus!)
                                        print("id4\([self.idArray])")
                                        print("status4\([self.appArray])")
                                        //print (self.idArray)
                                        self.tableConnect.reloadData()
                                        
                                        self.eventCounter+=1
                                        let (hForTotal,mForTotal) = self.secondsTo(seconds: (self.timeCounter))
                                        self.totalTime.text = String(Int(hForTotal)) + "h:" + String (Int(mForTotal)) + "m"
                                        
                                        //changing the Total for presentation
                                        let recordToInt = Double(record.fTotal!)
                                        let (h,m) = self.secondsTo(seconds: (recordToInt)!)
                                        let totalForReport = String(Int(h)) + "h:" + String (Int(m)) + "m"
                                        
                                        
                                        self.csv.append("\( record.fEmployer!),\(record.fIn!),\(record.fOut!),\(totalForReport),\(record.fIndication3!),\(record.fIndication!),\(record.fIndication2!),\(record.fStatus!),\(record.fBill)\n")
                                        
                                        self.csv2.append(record.fStatus!);self.csv2.append("       \t\t\t\t")
                                        self.csv2.append((record.fIn!));self.csv2.append("     \t\t")
                                        self.csv2.append(totalForReport);self.csv2.append("\t")
                                        self.csv2.append("\r\n")
                                        
                                        
                                    }// end of cases func
                                    
                                    switch period{
                                    //current week
                                    case 0:
                                        if self.recordWeek == self.currentWeek && self.recordYearForWeek == self.currentYearForWeek && record.fStatus! == self.Status
                                        {cases()} else if self.recordWeek == self.currentWeek && self.recordYearForWeek == self.currentYearForWeek  && self.Status == "All"
                                        {  //print("elseeeeeeecurrentweek"); print ("status:\(self.Status)")
                                            cases() }
                                        
                                    //last week
                                    case 1:
                                        if self.currentWeek-1 == 0 {self.currentWeek = 53; self.currentYearForWeek = (self.currentYearForWeek - 1)}
                                        
                                        if self.recordWeek == self.currentWeek-1 && self.recordYearForWeek == self.currentYearForWeek && record.fStatus! == self.Status
                                        {//print("elseeeeeeelast week"); print ("status:\(self.Status)")
                                            cases()} else if self.recordWeek == self.currentWeek-1 && self.recordYearForWeek == self.currentYearForWeek && self.Status == "All"
                                        {cases()}
                                        
                                    //current month
                                    case 2:
                                        if self.recotdMonth == self.currentMonth && self.recordYear == self.currentYear && record.fStatus! == self.Status {
                                            cases()
                                            
                                        }
                                            
                                        else if self.recotdMonth == self.currentMonth && self.recordYear == self.currentYear && self.Status == "All"
                                        { //print("elseeeeeee"); print ("status:\(self.Status)")
                                            print("record from month:\(record.fEmployerRef)")
                                            
                                            cases()
                                            
                                        }
                                        
                                    //last month
                                    case 3:
                                        if self.currentMonth-1 == 0 {self.currentMonth = 13 ; self.currentYear = (self.currentYear - 1)}
                                        if self.recotdMonth == (self.currentMonth-1) && self.recordYear == self.currentYear && record.fStatus! == self.Status
                                        {cases()
                                            
                                            
                                        } else if self.recotdMonth == (self.currentMonth-1) && self.recordYear == self.currentYear && self.Status == "All"
                                        {cases()}
                                        
                                    //all periods
                                    default :
                                        
                                        if self.Status == "Approved" {if record.fStatus == "Approved" {cases()}} else if
                                            record.fStatus! == "Pre" || record.fStatus == "Approved" {cases()
                                            print ("in first: calc is :\(self.calc)")
                                        }
                                            
                                        else if record.fStatus == nil
                                        {print ("in nil: calc is :\(self.calc)")
                                        }
                                        else if self.Status == "All"
                                        {cases()
                                            print (record.fEmployerRef!)
                                        }
                                            
                                        else {print ("in else: calc is :\(self.calc)")
                                            self.amount.text = String(self.calc)
                                            self.currencySymbol.text = ViewController.fixedCurrency
                                        }
                                        
                                    }//end of period switch
                                    
                                    self.eventsNumber.text = String(self.eventCounter)
                                    if self.eventCounter != 0{ self.generalApproval.isHidden = true;self.generalApproval.isEnabled = true; self.noSign.isHidden = true }
                                        
                                    else {self.generalApproval.isHidden = true;  self.noSign.isHidden = false;self.noSign.alpha = 0.5;
                                    }
                                    
                                    if self.Status == "All" /*|| self.Status == "Paid"*/{self.generalApproval.isHidden = true}
                                    
                                    
                                    let (hForTotal,mForTotal) = self.secondsTo(seconds: self.timeCounter)
                                    self.totalTime.text = String(Int(hForTotal)) + "h:" + String (Int(mForTotal)) + "m"
                                    if self.payment=="Normal" {   self.calc = Double(Int(hForTotal))*(self.Employerrate)+Double(Int(mForTotal))*(self.Employerrate)/60} else if self.payment == "Round" {   self.calc = (Double(self.eventCounter))*(self.Employerrate)} else    {self.calc = 0.0}
                                    if self.payment=="Normal" {   self.perEvents.text = "" ;self.perHour.text =  String("\(ViewController.fixedCurrency!)\(self.Employerrate) /hour") } else if self.payment == "Round" {  self.perEvents.text =  String("\(ViewController.fixedCurrency!)\(self.Employerrate) /round") ;self.perHour.text =  ""   } else    {self.perEvents.text = ""; self.perHour.text = ""}
                                    
                                    self.amount.text = self.formatter.string(for: self.calc)
                                    self.currencySymbol.text = ViewController.fixedCurrency!
                                    
                                    
                                    
                                }//end of else of fout is not empty
                                
                            }// end of if let dictionary
                            
                        }, withCancel: { (Error) in
                            print("error from FB")}
                        )//end of dbref2
                        
                        
                    }//end of loop
                }//end of elseif snapshot.value as? String == nil
                
                self.thinking.stopAnimating()
                
                sleep(UInt32(1))
                
                self.StatusChosen.isEnabled = true
                self.periodChosen.isEnabled = true
                
                
            }, withCancel: { (Error) in
                print("error from FB")}
            )//end of dbref1the second one
            
            
            
        }) //end of dbref employers0 the first one
        
        
        dbRef.removeAllObservers()
        dbRefEmployers.removeAllObservers()
        print ("hghg\(idArray)")
        
        
        
    }//end of fetch
    
    //no Firebase connection
    
    func noFB() {
        
        self.thinking.stopAnimating()
        self.alert30()
        
    }
    
    func billing(){
        biller = true
        self.dbRefEmployees.queryOrderedByKey().queryEqual(toValue: self.employeeID).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            let counterForMail = (snapshot.childSnapshot(forPath: "fCounter").value as! String)
            print("guygug\(counterForMail)")
            print("guygug2\(self.counterForMail2)")
            
            self.counterForMail2 = counterForMail
            print("guygug3\(self.counterForMail2!)")
        })
        alert6()
    }//end of billing
    
    // alerts/////////////////////////////////////////////////////////////////////////////////////
    func alert30(){
        let alertController30 = UIAlertController(title: ("No connection") , message: "Currently there is no connection with database. Please try again.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        }
        
        alertController30.addAction(OKAction)
        self.present(alertController30, animated: true, completion: nil)
    }
    
    func alert9(){
        let alertController9 = UIAlertController(title: ("No Records") , message: "Currently there is no records for this pet.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        }
        
        alertController9.addAction(OKAction)
        self.present(alertController9, animated: true, completion: nil)
    }
    
    func alert11(){
        generalApproval.isHidden = true;
        
        if checkBoxGeneral == 1 {  generalChange =  "You are about to change status for all  records in this list to 'Due'. Records would be added  under their new status. You can 'Undo' spesific record by clicking 'Due' icon on each record."}
        else if checkBoxGeneral == 2 {generalChange = "Mail with bill of due records is preapred. Sending or saving the mail, would change records to final status of 'Billed'."}
        else if checkBoxGeneral == 0 { generalChange = "You can not change status of records that were already billed."}
        if appArray.count == 0 {}
        else {
            print ("checkbox0\(self.checkBoxGeneral)")
            
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
                print ("checkbox1\(self.checkBoxGeneral)")
                
                
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
    
    
    func alert19(){
        
        
        if appArray.count == 0 {}
        
        let alertController19 = UIAlertController(title: ("Bill records") , message: "Mail with bill of walksmarked as 'due' is preapred. Sending or saving the mail, would change records to final status of 'Billed'." , preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            
            self.billing()
            
        }
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            self.segmentedPressed = 0
            self.StatusChosen.selectedSegmentIndex = self.segmentedPressed!
            self.StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
            
            ;
        }
        
        alertController19.addAction(OKAction)
        alertController19.addAction(CancelAction)
        
        self.present(alertController19, animated: true, completion: nil)
        
    }//end of alert19
    
    
    func alert12(){
        
        
        
        let alertController12 = UIAlertController(title: ("Change record status") , message: "You can not change status of records that were already billed.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        }
        
        
        alertController12.addAction(OKAction)
        
        self.present(alertController12, animated: true, completion: nil)
        
        
        
        
    }//end of alert12
 */
    
}

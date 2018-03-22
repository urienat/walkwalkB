//
//  datePicker2.swift
//  employee timer
//
//  Created by אורי עינת on 5.9.2016.
//  Copyright © 2016 אורי עינת. All rights reserved.
//

import UIKit
import Foundation
import FirebaseDatabase

class datePicker2: UIViewController {
    
    let dbRef = FIRDatabase.database().reference().child("fRecords")
    let dbRefEmployer = FIRDatabase.database().reference().child("fEmployers")
    let dbRefEmployee = FIRDatabase.database().reference().child("fEmployees")
    var blueColor = UIColor(red :22/255.0, green: 131/255.0, blue: 248/255.0, alpha: 1.0)
    var backArrow = UIImage(named: "backArrow")?.withRenderingMode(.alwaysTemplate)
    var home = UIImage(named: "home")
    var titleLbl = ""
    var recordToHandle = String()
    
    var sessionMode:Bool?
    var taxForSpecial: String?
    let dateForItem = Date()
    var segmentedPressed:Int?
    //let niner  = NSNumber. :UInt64 = 9999999999999
    //let niner = -9999999999

    @IBOutlet weak var backHeight: NSLayoutConstraint!
    
    //let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
    
    var locker = ""
    var employerID = ""
    var employeeID = ""
    var recordStatus = "save"
    var textForTax = ""
    var saveRecord : UIBarButtonItem?
    
    let mydateFormat5 = DateFormatter()
    let mydateFormat10 = DateFormatter()
    let mydateFormat11 = DateFormatter()

    @IBAction func extendedDate1Button(_ sender: Any) {
    datePickerbBackground .isHidden = false
    }
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var sessionItem: UISegmentedControl!
    @IBAction func sessionItem(_ sender: Any) {
        switch sessionItem.selectedSegmentIndex {
        case 0:   //Session
        backHeight.constant = 330
        itemBackground.isHidden = true
        saveRecord?.isEnabled = true
                 datePickerbBackground .isHidden = false
         startLbl.isHidden = false
         startLbl.text = "Walk"
         date1button.isHidden = false
         timeIn.isHidden = false
         extendedDate1Button.isHidden = false
         sessionMode = true
            
        case 1: //item
        backHeight.constant = 200
        datePickerbBackground .isHidden = true
        startLbl.isHidden = true
        date1button.isHidden = true
        extendedDate1Button.isHidden = true
        timeIn.isHidden = true
        itemBackground.isHidden = false
        print (ViewController.fixedCurrency)
        checkItemDeltails()
        sessionMode = false
        
        amount.text = "Rate(\(ViewController.fixedCurrency!))"


        default: break
        } //end of switch
        
    }
    
    @IBAction func itemStartedit(_ sender: Any) {
    
    checkItemDeltails()
    }
    @IBAction func itemEdited(_ sender: Any) {
    checkItemDeltails()
    }
    @IBAction func amountEdited(_ sender: Any) {
    checkItemDeltails()
    }
    
    @IBAction func amountStartEdit(_ sender: Any) {
    
        checkItemDeltails()
    }
    @IBOutlet weak var itemBackground: UIView!
    @IBOutlet weak var itemDescription: UITextField!
    @IBOutlet weak var amountNumber: UITextField!
    @IBOutlet weak var amount: UILabel!
    
    
    @IBOutlet weak var textForSpecial: UITextView!
    @IBOutlet weak var timeIn: UITextField!
    @IBOutlet weak var animationImage: UIImageView!
    @IBOutlet weak var topOfStart: NSLayoutConstraint!
    @IBOutlet weak var startLbl: UILabel!
    @IBOutlet weak var extendedDate1Button: UIButton!
    @IBOutlet weak var date1button: UIButton!
    @IBOutlet weak var datePickerbBackground: UIView!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var TimeIN: UITextField!
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var Employer: UILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBAction func pickerDone(_ sender: Any) {
        
    self.saveRecord = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(self.saveToDB2) )
    self.saveRecord?.isEnabled = true
    navigationItem.rightBarButtonItem = saveRecord
    datePickerChanged(DatePicker: DatePicker)
    }
    
    var employerFromMain: String?
    var inDate = String()
    
    @IBAction func deleter(_ sender: Any) {
    alert()
    }
    @IBOutlet weak var deleter: UIBarButtonItem!
    
    func bringRecord() {
    dbRef.child(recordToHandle).observeSingleEvent(of:.value, with: { (snapshot) in
    if let dictionary = snapshot.value as? [String: String] {
    let record = recordsStruct()
    record.setValuesForKeys(dictionary)
    print (dictionary)
        
    
        if record.fSpecialAmount != nil {self.sessionMode = false } else {self.sessionMode = true}
        if self.sessionMode == false {
            self.amountNumber.text = record.fSpecialAmount!
            self.itemDescription.text = record.fSpecialItem!
            self.refresh(presser: 1)
        } else { self.refresh(presser: 0)}
        
    if ViewController.dateTimeFormat == "DateTime" { self.TimeIN.text = self.mydateFormat11.string(from: self.mydateFormat5.date(from: record.fIn!)!)} else {self.TimeIN.text = self.mydateFormat11.string(from: self.mydateFormat5.date(from: record.fIn!)!) }
    self.inDate = record.fIn!
    self.DatePicker.setDate( self.mydateFormat5.date(from: record.fIn!)!  , animated: true)

    self.locker = record.fStatus!
    if self.locker == "Paid" {self.deleter.isEnabled = false;self.date1button.isEnabled = false; self.extendedDate1Button.isEnabled = false }
    else {self.deleter.isEnabled = true;self.date1button.isEnabled = true; self.extendedDate1Button.isEnabled = true}
    
    self.titleLbl = "Edit"
    self.title = self.titleLbl
    
    self.employerID = record.fEmployerRef!
    self.employeeID = record.fEmployeeRef!
    }
    } , withCancel: { (Error) in
        self.alert30()
        print("error from FB")})

    }//end of func bring record
    
    /////////////////////////////////////////////////////////////////  view did load starts///////////////////////
    override func viewDidLoad() {
    super.viewDidLoad()
        

        let yourBackImage = UIImage(named: "backArrow")
            self.navigationController?.navigationBar.topItem?.title = employerFromMain
            self.navigationController?.navigationBar.backIndicatorImage =  yourBackImage
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
            //self.navigationController?.navigationBar.reloadInputViews()
        
        
        
        //formating the date
        mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)",options: 0, locale: nil)!
        mydateFormat10.dateFormat = DateFormatter.dateFormat(fromTemplate: " EEE-dd-MMM-yyyy", options: 0, locale: Locale.autoupdatingCurrent)!
        mydateFormat11.dateFormat = DateFormatter.dateFormat(fromTemplate: " EEE-dd-MMM-yyyy , (HH,mm)", options: 0, locale: Locale.autoupdatingCurrent)!
        
        if recordToHandle == "" {
            sessionItem.isHidden = true//false
            deleter.isEnabled = false
            
            print (ViewController.dateTimeFormat)
            
            if ViewController.dateTimeFormat == "DateTime" { print ("khkhkj");self.TimeIN.text = mydateFormat11.string(from: Date())} else {self.TimeIN.text = mydateFormat10.string(from: Date()) }
            
            
            self.saveRecord = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(self.saveToDB2) )
            navigationItem.rightBarButtonItem = saveRecord
            self.saveRecord?.isEnabled = false
            if sessionMode == true {titleLbl = "Add session" ;refresh(presser: 0)} else {titleLbl = "Add other item" ;refresh(presser: 1)}
            
            
        }else{
            sessionItem.isHidden = true
            deleter.isEnabled = true
            self.saveRecord = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(self.saveToDB2) )
            self.saveRecord?.isEnabled = false;
            navigationItem.rightBarButtonItem = saveRecord
            self.deleter.isEnabled = true
            bringRecord()
        }//end of else
        
    if ViewController.dateTimeFormat == "DateTime" {self.DatePicker.datePickerMode = .dateAndTime } else { self.DatePicker.datePickerMode = .date}
        //sessionMode = true
      
      
        
      
       
        
       
        
        self.title = titleLbl
        
        datePickerbBackground.layer.borderWidth = 0.5
        datePickerbBackground.layer.borderColor = blueColor.cgColor
        datePickerbBackground.layer.cornerRadius =  10//CGFloat(25)
        datePickerbBackground.layoutIfNeeded()
        
        itemBackground.layer.borderWidth = 0.5
        itemBackground.layer.borderColor = blueColor.cgColor
        itemBackground.layer.cornerRadius =  10//CGFloat(25)
        itemBackground.layoutIfNeeded()
        
        if ViewController.taxCalc == "Over" {self.textForTax = "and its rate excluding \(String(describing: ViewController.taxName!))"} else {self.textForTax = "and its rate including \(String(describing: ViewController.taxName!))"}
        if ViewController.taxOption == "No" {self.taxForSpecial = "and its rate." } else {self.taxForSpecial = "\(self.textForTax)." }
        
        textForSpecial.text = "Add item's short description \(String(describing: taxForSpecial!))"
 
    } ///end of did load/////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func datePickerChanged(DatePicker:UIDatePicker) {
    datePickerbBackground .isHidden = true
    if ViewController.dateTimeFormat == "DateTime" { self.TimeIN.text = mydateFormat11.string(from: DatePicker.date) } else {self.TimeIN.text = mydateFormat10.string(from: DatePicker.date) }
    }//end of func
    
    func saveToDB2() {
        connectivityCheck()
        saveRecord?.isEnabled = false
        self.navigationItem.setHidesBackButton(true, animated: true)
        
    if recordToHandle == "" {
        if sessionMode == true{
    let record = ["fIn" : mydateFormat5.string(from: DatePicker.date), "fEmployer": String (describing : employerFromMain!),"fIndication3" :"✏️","fStatus" : "Approved","fEmployeeRef": String (describing : employeeID),"fEmployerRef":  String (describing : employerID)]
    let recordRefence = self.dbRef.childByAutoId()
    recordRefence.setValue(record)
            
    self.dbRefEmployee.child(self.employeeID).child("fEmployeeRecords").updateChildValues([recordRefence.key:Int(-(DatePicker.date.timeIntervalSince1970))])
    self.dbRefEmployer.child(self.employerID).child("fEmployerRecords").updateChildValues([recordRefence.key:Int(-(DatePicker.date.timeIntervalSince1970))])
    
    
          } //end of session mode
        else {
            let record = ["fIn" : mydateFormat5.string(from: dateForItem), "fEmployer": String (describing : employerFromMain!),"fIndication3" :"📄","fStatus" : "Approved","fEmployeeRef": String (describing : employeeID),"fEmployerRef":  String (describing : employerID),"fSpecialItem" : itemDescription.text!,"fSpecialAmount": amountNumber.text!,"fSessionCreated": self.mydateFormat5.string(from: Date())]
            let recordRefence = self.dbRef.childByAutoId()
            recordRefence.setValue(record)
            
            self.dbRefEmployee.child(self.employeeID).child("fEmployeeRecords").updateChildValues([recordRefence.key: -2147483647])
            self.dbRefEmployer.child(self.employerID).child("fEmployerRecords").updateChildValues([recordRefence.key: -2147483647])
        }//end of else
    } // end of recordToHandle == ""
    else
    {
        if sessionMode == true {let record = ["fIn" : mydateFormat5.string(from: DatePicker.date),"fIndication3" :"✏️","fStatus" : "Approved" ]
            dbRef.child(recordToHandle).updateChildValues(record)
            
            self.dbRefEmployee.child(self.employeeID).child("fEmployeeRecords").updateChildValues([recordToHandle:Int(-(DatePicker.date.timeIntervalSince1970))])
            self.dbRefEmployer.child(self.employerID).child("fEmployerRecords").updateChildValues([recordToHandle:Int(-(DatePicker.date.timeIntervalSince1970))])
            
        } else
        {let record = ["fIn" : mydateFormat5.string(from: DatePicker.date),"fIndication3" :"📄","fStatus" : "Approved","fSpecialItem" : itemDescription.text!,"fSpecialAmount": amountNumber.text!]
              dbRef.child(recordToHandle).updateChildValues(record)
        }
  
   
    } //end of else
        
   
    ViewController.sessionPusher = true
    self.navigationController!.popViewController(animated: false)

    }//end of savetodb2
    
    @IBAction func date1(_ sender: AnyObject) {
    datePickerbBackground .isHidden = false
    }
    
   
    
    func refresh(presser:Int){
        sessionItem.isMomentary = true
        segmentedPressed = presser
        sessionItem.selectedSegmentIndex = segmentedPressed!
        sessionItem.sendActions(for: .valueChanged)
        sessionItem.isMomentary = false
    }
    
    func checkItemDeltails(){
    print ("checked")
        
        if itemDescription.text?.isEmpty == true || itemDescription.text == "" || amountNumber.text?.isEmpty == true {saveRecord?.isEnabled = false } else {saveRecord?.isEnabled = true}
    }
  ////alerts////////////////////////////////////////////////////////////////////////////////////////////////////////
    
//deletealert
func alert () {
if recordStatus != "" {
print("delete")
let alertController = UIAlertController(title: "Delete", message: "This record would be deleted. Are You Sure?", preferredStyle: .alert)
let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
//nothing
}
    
let deleteAction = UIAlertAction(title: "Yes delete it.", style: .default) { (UIAlertAction) in
print ("delete it!!!")
self.dbRef.child(self.recordToHandle).removeValue()
self.dbRefEmployee.child(self.employeeID).child("fEmployeeRecords").child(self.recordToHandle).removeValue()
self.dbRefEmployer.child(self.employerID).child("fEmployerRecords").child(self.recordToHandle).removeValue()

self.navigationController!.popViewController(animated: true)
}

alertController.addAction(cancelAction)
alertController.addAction(deleteAction)
self.present(alertController, animated: true, completion: nil)
}
}//end of func alert


    

}///end!!!//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

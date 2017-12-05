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
    
    var titleLbl = ""
    var recordToHandle = String()
    
    let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
    
    var locker = ""

    var employerID = ""
    var employeeID = ""
    var recordStatus = "save"
    
    var saveRecord : UIBarButtonItem?
    //varibalwds for rounding
    var roundSecond = 0
    var roundMinute = 0
    var roundHour = 0
    var roundDay = 0
    var totalManual = 0
    
    var tempTotal = 0
    var roundIndicator = String()
    let mydateFormat5 = DateFormatter()
    let mydateFormat10 = DateFormatter()
    let mydateFormat11 = DateFormatter()



    @IBOutlet weak var extendedDate2Button: UIButton!
    @IBOutlet weak var date2Button: UIButton!
    @IBAction func extendedDate2Button(_ sender: Any) {
        datePickerbBackground .isHidden = true
        datePickerBackground2.isHidden = false

    }
    
    
    @IBAction func extendedDate1Button(_ sender: Any) {
        
        datePickerbBackground .isHidden = false
        datePickerBackground2.isHidden = true

    }
    
    @IBOutlet weak var topOfStart: NSLayoutConstraint!
    @IBOutlet weak var startLbl: UILabel!
    @IBOutlet weak var stopLbl: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var extendedDate1Button: UIButton!
    @IBOutlet weak var date1button: UIButton!
    @IBOutlet weak var datePickerbBackground: UIView!
    @IBOutlet weak var datePickerBackground2: UIView!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var TimeIN: UITextField!
    @IBOutlet weak var TimeOut: UITextField!
    @IBOutlet weak var Total: UITextField!
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var DatePicker2: UIDatePicker!
    @IBOutlet weak var Employer: UILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var deleteBackground: UIView!
    
    
    @IBAction func pickerDone(_ sender: Any) {
    datePickerChanged(DatePicker: DatePicker)
    }
    
    @IBAction func picker2Done(_ sender: Any) {
        datePickerChanged2(DatePicker: DatePicker2)
    }
   
    
    var calcTimeIn = Date()
    var calcTimeOut = Date()
    var calcTotal = 0
    var employerFromMain: String?
    var outDate = String()
    var inDate = String()
    
    @IBAction func deleter(_ sender: Any) {
        alert()
    }
   
    @IBOutlet weak var deleter: UIBarButtonItem!
    
    func bringRecord() {  dbRef.child(recordToHandle).observeSingleEvent(of:.value, with: { (snapshot) in
    if let dictionary = snapshot.value as? [String: String] {
    let record = recordsStruct()
    record.setValuesForKeys(dictionary)
        print (dictionary)
        self.roundIndicator = record.fTotal!
        print (self.roundIndicator)
        
        if self.roundIndicator == "-1" { self.TimeOut.isHidden = true;self.date2Button.isHidden = true;self.date2Button.isEnabled = false;self.TimeOut.isHidden = true;self.Total.isHidden = true;self.totalLabel.isHidden = true;self.stopLbl.isHidden = true;self.startLbl.text = "Session";self.extendedDate2Button.isHidden = true;self.extendedDate2Button.isEnabled = false;self.topOfStart.constant = 60;
           self.saveRecord?.isEnabled = true;self.saveRecord = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(self.saveToDB2) )
        }
        
        else
        {self.TimeOut.isHidden = false; self.date2Button.isHidden = false; self.date2Button.isEnabled = true;self.TimeOut.isHidden = false;self.Total.isHidden = false;self.totalLabel.isHidden = false;self.stopLbl.isHidden = false;self.startLbl.text = "Start";self.extendedDate2Button.isHidden = false;self.extendedDate2Button.isEnabled = true;self.topOfStart.constant = 40;self.TimeOut.text = self.mydateFormat5.string(from: Date());
          //  self.saveRecord = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(self.saveAlert) );
            self.saveRecord?.isEnabled = false
        }//end of else
        
        
        
        let  (totaltoTimeh,totalToTimem) = self.secondsTo(seconds: Int(record.fTotal!)!)
        self.Total.text = String(totaltoTimeh) + "h : " + String (totalToTimem) + "m"
        self.tempTotal = Int(record.fTotal!)!
        print(self.tempTotal)
        
        if ViewController.dateTimeFormat == "DateTime" { self.TimeIN.text = self.mydateFormat11.string(from: self.mydateFormat5.date(from: record.fIn!)!)} else {self.TimeIN.text = self.mydateFormat11.string(from: self.mydateFormat5.date(from: record.fIn!)!) }
        self.inDate = record.fIn!
        
        
        self.DatePicker.setDate( self.mydateFormat5.date(from: record.fIn!)!  , animated: true)

        self.TimeOut.text = self.mydateFormat5.string(from:   self.mydateFormat5.date(from: record.fOut!)!)
        self.outDate = record.fOut!
        self.DatePicker2.setDate( self.mydateFormat5.date(from: record.fOut!)!  , animated: true)

       
        self.locker = record.fStatus!
        print (self.locker)
        if self.locker == "Paid" {self.deleter.isEnabled = false;self.date1button.isEnabled = false;self.date2Button.isEnabled = false; self.extendedDate1Button.isEnabled = false;self.extendedDate2Button.isEnabled = false; }
        else {self.deleter.isEnabled = true;self.date1button.isEnabled = true;self.date2Button.isEnabled = true; self.extendedDate1Button.isEnabled = true;self.extendedDate2Button.isEnabled = true}
        
        self.titleLbl = "Edit record"
        self.title = self.titleLbl
        
        self.employerID = record.fEmployerRef!
        self.employeeID = record.fEmployeeRef!
        }
        }, withCancel: { (Error) in
        print("error from FB123456")
        })
        
        
    }//end of func bring record
    
    /////////////////////////////////////////////////////////////////  view did load starts///////////////////////
    override func viewDidLoad() {
    super.viewDidLoad()
        
        if ViewController.dateTimeFormat == "DateTime" {self.DatePicker.datePickerMode = .dateAndTime } else { self.DatePicker.datePickerMode = .date}

      
        //connectivity
        if Reachability.isConnectedToNetwork() == true
        {
            print("Internet Connection Available!")
        }
        else
        {
            print("Internet Connection not Available!")
            alert50()
        }
        
      
        //formating the date
        mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)"
            ,options: 0, locale: nil)!
        mydateFormat10.dateFormat = DateFormatter.dateFormat(fromTemplate: " EEE-dd-MMM-yyyy", options: 0, locale: Locale.autoupdatingCurrent)!
        mydateFormat11.dateFormat = DateFormatter.dateFormat(fromTemplate: " EEE-dd-MMM-yyyy , (HH,mm)", options: 0, locale: Locale.autoupdatingCurrent)!
        if recordToHandle == "" {
            deleter.isEnabled = false
            
                  if ViewController.dateTimeFormat == "DateTime" { self.TimeIN.text = mydateFormat11.string(from: Date())} else {self.TimeIN.text = mydateFormat10.string(from: Date()) }
            
            titleLbl = "Add for " + employerFromMain!
            
         TimeOut.isHidden = true;date2Button.isHidden = true;date2Button.isEnabled = false;TimeOut.isHidden = true;Total.isHidden = true;totalLabel.isHidden = true;stopLbl.isHidden = true;startLbl.text = "Session";extendedDate2Button.isHidden = true;extendedDate2Button.isEnabled = false;topOfStart.constant = 60;
                
                saveRecord?.isEnabled = true;        saveRecord = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(saveToDB2))
                self.roundIndicator = "-1"
                
        }//end of if
        else{
            deleter.isEnabled = true

             saveRecord = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(saveToDB2))
            self.deleter.isEnabled = true
           
            bringRecord()

            
            

            }//end of else
        
        
        navigationItem.rightBarButtonItem = saveRecord

            self.title = titleLbl
 
    } ///end of did load/////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //override func viewDidAppear(_ animated: Bool) {
        
  //  }
    
    func datePickerChanged(DatePicker:UIDatePicker) {
        

        datePickerbBackground .isHidden = true
        datePickerBackground2.isHidden = true
         if ViewController.dateTimeFormat == "DateTime" { self.TimeIN.text = mydateFormat11.string(from: DatePicker.date) } else {self.TimeIN.text = mydateFormat10.string(from: DatePicker.date) }
        
        print("in as a date:")
        print( calcTimeIn)
        
        if DatePicker.date >  Date() {
           // self.TimeOut.text = self.mydateFormat.string(from: DatePicker.date)
            self.TimeOut.text = self.mydateFormat5.string(from: DatePicker.date)

            self.DatePicker2.setDate( DatePicker.date , animated: true)
        }
        print("in as a date:")
        print( roundIndicator)
        
        if  self.roundIndicator == "-1"  {} else { calcuatingTotal() }
        
        }//end of func
    
    func datePickerChanged2(DatePicker:UIDatePicker) {

        datePickerbBackground .isHidden = true
        datePickerBackground2.isHidden = true
        TimeOut.text = mydateFormat.string(from: DatePicker.date) //brings the a date as a string
        calcuatingTotal()

        }
   
    func saveToDB() {
        navigationController!.popViewController(animated: true)
        
        
        if calcTotal > 0  {
        print ("bigger than 0")
        
            if recordToHandle == "" {
                let record = ["fIn" : mydateFormat5.string(from: DatePicker.date), "fOut" : mydateFormat5.string(from: DatePicker2.date), "fTotal" : String (describing : calcTotal), "fEmployer": String (describing : employerFromMain!),"fIndication3" :"✏️","fStatus" : "Pre", "fEmployeeRef": String (describing : employeeID),"fEmployerRef":  String (describing : employerID)]
        
            let recordRefence = self.dbRef.childByAutoId()
            recordRefence.setValue(record)
                
                
                
                
            self.dbRefEmployee.child(self.employeeID).child("fEmployeeRecords").updateChildValues([recordRefence.key:Int(-(DatePicker.date.timeIntervalSince1970))])
            self.dbRefEmployer.child(self.employerID).child("fEmployerRecords").updateChildValues([recordRefence.key:Int(-(DatePicker.date.timeIntervalSince1970))])            }//  end od if recors to handle is ""
            else {
            let record = ["fIn" : mydateFormat5.string(from: DatePicker.date), "fOut" : mydateFormat5.string(from: DatePicker2.date), "fTotal" : String (describing : calcTotal) ,"fIndication3" :"✏️","fStatus" : "Pre" ]
            dbRef.child(recordToHandle).updateChildValues(record)
                self.dbRefEmployee.child(self.employeeID).child("fEmployeeRecords").updateChildValues([recordToHandle:Int(-(DatePicker.date.timeIntervalSince1970))])
                self.dbRefEmployer.child(self.employerID).child("fEmployerRecords").updateChildValues([recordToHandle:Int(-(DatePicker.date.timeIntervalSince1970))])
                
            } //end od else
   
            }//end od if calctotal >0
            else { //it's less than minimum - do not save
            // saveRecord!.isEnabled = true
            print ("less than 0")

            }//end od else
    
            }
    
    func saveToDB2() {
        navigationController!.popViewController(animated: true)
        print (calcTotal)

        
            if recordToHandle == "" {
                let record = ["fIn" : mydateFormat5.string(from: DatePicker.date), "fOut" : mydateFormat5.string(from: DatePicker.date), "fTotal" : "-1", "fEmployer": String (describing : employerFromMain!),"fIndication3" :"✏️","fStatus" : "Pre","fEmployeeRef": String (describing : employeeID),"fEmployerRef":  String (describing : employerID)]
                
                let recordRefence = self.dbRef.childByAutoId()
                recordRefence.setValue(record)
                
                
                
                
                self.dbRefEmployee.child(self.employeeID).child("fEmployeeRecords").updateChildValues([recordRefence.key:Int(-(DatePicker.date.timeIntervalSince1970))])
                self.dbRefEmployer.child(self.employerID).child("fEmployerRecords").updateChildValues([recordRefence.key:Int(-(DatePicker.date.timeIntervalSince1970))])            }//  end od if recors to handle is ""
            else {
                let record = ["fIn" : mydateFormat5.string(from: DatePicker.date), "fOut" : mydateFormat5.string(from: DatePicker.date), "fTotal" :"-1","fIndication3" :"✏️","fStatus" : "Pre" ]
                dbRef.child(recordToHandle).updateChildValues(record)
                self.dbRefEmployee.child(self.employeeID).child("fEmployeeRecords").updateChildValues([recordToHandle:Int(-(DatePicker.date.timeIntervalSince1970))])
                self.dbRefEmployer.child(self.employerID).child("fEmployerRecords").updateChildValues([recordToHandle:Int(-(DatePicker.date.timeIntervalSince1970))])
                
            } //end od else
            
     
            }
    
        @IBAction func cancelPressed(_ sender: AnyObject) {
        }
    
        func calcuatingTotal() {
        //rounding
            
        let calendar = Calendar.current
        let date2 = calendar.dateComponents([.day, .hour,.minute,.second, .month], from: DatePicker.date)
        print ("date in\(self.inDate)")
        
        let date1 = calendar.dateComponents([.day, .hour,.minute, .second, .month], from: DatePicker2.date)
         print ("date out\(self.outDate)")

        
        self.roundSecond = date1.second! - date2.second!
        self.roundMinute = date1.minute! - date2.minute!
        self.roundHour = date1.hour! - date2.hour!
            print ("date out\(self.roundHour)")

        if date2.month == date1.month {self.roundDay = date1.day! - date2.day!} // same month
        else if date2.month!+1 == date1.month! && date1.day == 1 // two months
        {
        if date2.month == 1 || date2.month == 3 || date2.month == 5 || date2.month == 7 || date2.month == 8 || date2.month == 10 {self.roundDay = date1.day!+31 - date2.day!}
        if date2.month == 4 || date2.month == 6 || date2.month == 9 || date2.month == 11 {self.roundDay = date1.day!+30 - date2.day!}
        if date2.month == 2 {self.roundDay = date1.day!+28 - date2.day!}
        }
        else if date2.month! == 12 && date1.month! == 1 && date1.day == 1 {self.roundDay = date1.day!+31 - date2.day!}// between dec and jan
            
        else
        {if date1.month! > date2.month! {self.roundDay = 2} //same year more than a month
        else if date1.month! < date2.month!{
            
            
            self.roundDay = -1 }}//negative month
        
        
        print ("second\(self.roundSecond)")
        print ("roundMinute\(self.roundMinute)")
        print ("hour\(self.roundHour)")
        print ("roundDay\(self.roundDay)")
        
        if self.roundDay == 0 {  self.totalManual = self.roundMinute*60 + self.roundHour*3600}
        else if self.roundDay == 1 {self.totalManual = ((24-date2.hour!+date1.hour!)*3600 + (self.roundMinute*60))}
        else if self.roundDay > 1 {logicAlert()
            self.totalManual = 0
        }
        else {self.totalManual = 0}
        
        calcTotal = totalManual
        print (calcTotal)
        self.saveRecord = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(self.saveAlert))

            
        if calcTotal > 0
            
        {
            let (h,m) = secondsTo(seconds: Int(calcTotal))
            Total.text = String(h) + "h : " + String (m) + "m"
            saveRecord?.isEnabled = true
           
            
            if calcTotal > (24*3600) {
            
            logicAlert()
            self.Total.text = "   N/A"
            saveRecord?.isEnabled = false
                
                calcTotal = 0
            }
            }//end of if
        else  {
            self.Total.text = "   N/A"
            saveRecord?.isEnabled = false

            calcTotal = 0

            }//end od else
            
            navigationItem.rightBarButtonItem = saveRecord
            
        }//end od calcuating total
    
    @IBAction func date1(_ sender: AnyObject) {
        datePickerbBackground .isHidden = false
        datePickerBackground2.isHidden = true
        }
    
    @IBAction func date2(_ sender: AnyObject) {
        datePickerbBackground .isHidden = true
        datePickerBackground2.isHidden = false
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        }
    
    // func for transforming int to h:m:"
    func secondsTo (seconds : Int) -> (Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60)
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
        else {saveAlert()}
        }//end of func alert

   //save alert
        func saveAlert () {
        print("save")
        if recordStatus != "Locked" {
        let alertController = UIAlertController(title: "Save", message: "Are You Sure?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            //nothing
        }
        let saveAction = UIAlertAction(title: "Yes Save it.", style: .default) { (UIAlertAction) in
         self.saveToDB2()
        //self.navigationController!.popViewController(animated: true)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        self.present(alertController, animated: true, completion: nil)
        }
        else{ let alertController3 = UIAlertController(title: "Locked Record", message: "Can't edit a record that was already approved or rejected.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
        //nothing
        }
        alertController3.addAction(okAction)
        self.present(alertController3, animated: true, completion: nil)
        }//end of else
        }//end of save alert
    
    
    //Logic alert
            func logicAlert () {
            let alertController4 = UIAlertController(title: "Record's limit", message: "Sorry, but  24 hours is record's limit. Please update.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
                //nothing
            }
            alertController4.addAction(OKAction)
        
            self.present(alertController4, animated: true, completion: nil)
            }//end of logic alert
    
    func alert50(){
        let alertController50 = UIAlertController(title: ("Internet Connection") , message: " There is no internet - Check communication avilability.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        }
        
        alertController50.addAction(OKAction)
        self.present(alertController50, animated: true, completion: nil)
    }
    


}///end!!!//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

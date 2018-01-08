//
//  calanderExt.swift
//  perSession
//
//  Created by uri enat on 26/11/2017.
//  Copyright © 2017 אורי עינת. All rights reserved.
//


import Foundation
import UIKit
import Firebase
import Google
import GoogleSignIn
import GoogleAPIClientForREST

class calander: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
   
    let dbRef = FIRDatabase.database().reference().child("fRecords")
    let dbRefEmployer = FIRDatabase.database().reference().child("fEmployers")
    let dbRefEmployee = FIRDatabase.database().reference().child("fEmployees")
    
    let mydateFormat5 = DateFormatter()
    let mydateFormat6 = DateFormatter()
    let mydateFormat9 = DateFormatter()
    var blueColor = UIColor(red :22/255.0, green: 131/255.0, blue: 248/255.0, alpha: 1.0)

    @IBOutlet weak var navBar: UINavigationItem!
    
    var calIn = ""
    var calInFB = ""
    
    var spesific : Bool = false
    
    var employerFromMain = ""
    var employerIdFromMain = ""
    var employer = ""
    
    var eventCounter = 0
    var eventCounterBlock = ""
    var minDate:Date?
    
    //let btn1 = UIButton(type: .custom)

    var employeeId = ""
    var employerId = ""
    var employerArray: [String:Int] = [:]
    var employerArray2: [String] = []
    var employerArray3: [String:String] = [:]
    var employerNameForGoogle = ""
    var employerLastNameForGoogle = ""
    var employerNameLastNameForGoogle = ""
    var LastCalander: String?
    var Dictionary = [String: String]()
    var beginDate = Date()
    var helpText : UITextField?
    
    @IBOutlet var thinking: UIActivityIndicatorView!
    @IBOutlet weak var helpBackground: UIView!
    
    @IBAction func doneHelp(_ sender: Any) {
        print ("done pressed")
        helpBackground.isHidden = true
        alert123()
    }
    
    @IBOutlet weak var datePickerBG: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var animationImage: UIImageView!
    @IBOutlet weak var textAdd: UITextView!
    @IBOutlet weak var helpTxtView: UITextView!
    
    @IBAction func done(_ sender: Any) {
    datePicker.maximumDate = Date()
    datePicker.minimumDate = Date() - 24*3600*60
   // LastCalander = mydateFormat5.string(from:  datePicker.date)
        
    self.minDate = datePicker.date
        self.dbRefEmployee.child(employeeId).updateChildValues(["fLastCalander":self.mydateFormat5.string(from: self.minDate!)])

    datePickerBG.isHidden = true
    alert123()
    }

    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    //private let scopes = [kGTLRAuthScopeCalendarReadonly]
    let scopes = [kGTLRAuthScopeCalendar]
    let service = GTLRCalendarService()
    let output = UITextView()
    let updater = GTLRCalendar_Event()
    var id1: String?

    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectivityCheck()
        
        title = "Import Calander"
        
        mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)",options: 0, locale: nil)!
        mydateFormat6.dateFormat = DateFormatter.dateFormat(fromTemplate: " EEE-dd-MMM-yyyy, (HH:mm)", options: 0, locale:Locale.autoupdatingCurrent )!
        mydateFormat9.dateFormat = DateFormatter.dateFormat(fromTemplate: " dd-MMM-yy", options: 0, locale:Locale.autoupdatingCurrent )!

        service.shouldFetchNextPages = true
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() == true{
            GIDSignIn.sharedInstance().signInSilently()
            print ("in")
            googleCalanderConnected()
        }else{
            print ("out")
            GIDSignIn.sharedInstance().signIn()
            }
        datePickerBG.layer.borderWidth = 0.5
        datePickerBG.layer.borderColor = blueColor.cgColor
        datePickerBG.layer.cornerRadius =  15//CGFloat(25)
        datePickerBG.layoutIfNeeded()
        
        helpTxtView.layer.borderWidth = 0.5
        helpTxtView.layer.borderColor = blueColor.cgColor
        helpTxtView.layer.cornerRadius =  15//CGFloat(25)
        helpTxtView.layoutIfNeeded()
        thinking.hidesWhenStopped = true

        
    }//end of view did load ////////////////////////////////////////////////////////////////////////////////////////
    
        func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
        withError error: Error!) {
        if let error = error {
        showAlert(title: "Authentication Error", message: error.localizedDescription)
        self.service.authorizer = nil
        } else {
        //self.signInButton.isHidden = true
        //self.output.isHidden = false
        self.service.authorizer = user.authentication.fetcherAuthorizer()
        googleCalanderConnected()
        }
        }// end of sign func
    
        // Construct a query and get a list of upcoming events
        func fetchEvents() {
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")// instard of "primary"
        query.maxResults = 500
        // DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
        print("0.2 \(self.LastCalander!)")
            print (self.minDate)
            minDate =  NSCalendar.current.startOfDay(for: minDate!)
            print (self.minDate)
            
            query.timeMin = GTLRDateTime(date: minDate!)
        print ("before min \(String(describing: self.LastCalander))")

        //query.timeMin = GTLRDateTime(date: self.mydateFormat5.date(from: self.LastCalander!)!)

        query.timeMax = GTLRDateTime(date: Date())
        query.singleEvents = true
        query.orderBy = kGTLRCalendarOrderByStartTime
        self.service.executeQuery(
        query,
        delegate: self,
        didFinish: #selector(self.displayResultWithTicket(ticket:finishedWithObject:error:)))
        //}//end of dispatch

        }//end of fetchevents

        // Display the start dates and event summaries in the UITextView
        func displayResultWithTicket(
        ticket: GTLRServiceTicket,finishedWithObject response :  GTLRCalendar_Events,error : NSError?) {
        if let error = error {
        showAlert(title: "Error", message: error.localizedDescription)
        return
        }
        eventCounter = 0
        var outputText = ""
        if let events = response.items, !events.isEmpty {
        for event in events {
        let start = event.start!.dateTime ?? event.start!.date!
        //let end = event.end!.dateTime ?? event.start!.date!
        calIn = self.mydateFormat6.string(from: start.date)
        calInFB = self.mydateFormat5.string(from: start.date)
        employer = event.summary!

        _ = DateFormatter.localizedString(
        from: start.date,
        dateStyle: .short,
        timeStyle: .short)

        outputText += "\(calIn) - \(event.summary!)\r\n\r\n"
        
        let keyExists = employerArray3[("\(event.summary!)")]

        if (keyExists)  != nil {
                if spesific == false {
                if (keyExists!) != nil { print ("another all included");employerId = employerArray3[event.summary!]!
                saveToDB2()
                //avoid double entry
                id1 = event.identifier
                updater.summary = ("\(event.summary!)+")
                eventCounter += 1
                updateRead()
                }//end of if
                } else {
                print ("keyexist\(keyExists)")
                print ("employerid\(employerIdFromMain)")
                if (keyExists!) == employerIdFromMain { print ("another spesific included");employerId = employerArray3[event.summary!]!
                saveToDB2()
                //avoid double entry
                id1 = event.identifier
                updater.summary = ("\(event.summary!)+")
                eventCounter += 1
                updateRead()
                
                }//end of if
                }//end of else
                }// end of if key exist != nil
            
            }//end of for event
            }//end of if let event
            
            if eventCounter == 0 {animationImage.isHidden = true; self.eventCounterBlock = "No sessions" ;ViewController.sessionPusher = false}else if eventCounter == 1 {animationImage.isHidden = false; self.eventCounterBlock = "One session";ViewController.sessionPusher = true} else {self.eventCounterBlock = "\(String(self.eventCounter)) sessions";ViewController.sessionPusher = true }
            // save last date
            if spesific == false {textAdd.text = "\(self.eventCounterBlock) imported from calander";ViewController.sessionPusher = false
                
            }
            else {textAdd.text = "\(self.eventCounterBlock) for \(employerFromMain) imported from calander"}
            thinking.stopAnimating()

            self.animation()
            DispatchQueue.main.asyncAfter(deadline: .now()+3){
            self.navigationController!.popViewController(animated: true)
                
            }
            }//end of function
    
            func animation(){
            self.animationImage.center.x -= self.view.bounds.width
            //self.animationImage.isHidden = false
            self.animationImage.alpha = 1
            UIView.animate(withDuration: 2.0, animations:{
            self.animationImage.center.x += self.view.bounds.width
            })
            UIView.animate(withDuration: 2.0, delay :2.0 ,options:[],animations: {
            self.animationImage.alpha = 0
            },completion:nil)
            UIView.animate(withDuration: 1.0, delay :4.0 ,options:[],animations: {
            DispatchQueue.main.asyncAfter(deadline: .now()){
            UIView.animate(withDuration: 3.0, delay :0.0 ,options:[],animations: {
                self.textAdd.alpha = 1
            },completion:nil)
            UIView.animate(withDuration: 2.0, delay :3.0 ,options:[],animations: {
                self.textAdd.alpha = 0
            },completion:nil)
            }
            },completion:nil)
            }//end of animation

            func updateRead(){
            let query2 = GTLRCalendarQuery_EventsPatch.query(withObject: self.updater , calendarId: "primary", eventId:id1!)
            service.executeQuery(query2) { (ticket: GTLRServiceTicket, Any, error) in
            if let error = error {self.showAlert(title: "Error", message: error.localizedDescription)
            return
            }//end of if error
            }//end of execute
            }//end of func

            func saveToDB2() {
            let record = ["fIn" : calInFB,  "fEmployer": String (describing : employer),"fIndication3" :"📆","fStatus" : "Approved","fEmployeeRef": String (describing : employeeId),"fEmployerRef":  String (describing : employerId)]

            let recordRefence = self.dbRef.childByAutoId()
            recordRefence.setValue(record)

            self.dbRefEmployee.child(employeeId).child("fEmployeeRecords").updateChildValues([recordRefence.key:Int(-((self.mydateFormat5.date(from: calInFB))?.timeIntervalSince1970)!)])
            self.dbRefEmployer.child(self.employerId).child("fEmployerRecords").updateChildValues([recordRefence.key:Int(-((self.mydateFormat5.date(from: calInFB))?.timeIntervalSince1970)!)])

            }//end of save
    
        func findEmployerId(){
        employerArray3.removeAll()
        employerArray2.removeAll()
        employerArray.removeAll()

        self.dbRefEmployee.child(employeeId).queryOrderedByValue().observeSingleEvent(of: .value, with: { (snapshot) in
        self.employerArray = snapshot.childSnapshot(forPath: "myEmployers").value! as! [String:Int]
        self.employerArray2 = Array(self.employerArray.keys) // for Dictionary
        print ("employerArray2\(self.employerArray2)")
        print ("match")
           
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
        for eachEmployer in 0...(self.employerArray2.count-1){
            print ("eachEmployer\(eachEmployer)")

        self.dbRefEmployer.child(self.employerArray2[eachEmployer]).observeSingleEvent(of: .value, with: { (snapshot) in
        self.employerLastNameForGoogle = String(describing: snapshot.childSnapshot(forPath: "fEmployer").value!) as String!
        self.employerNameForGoogle = String(describing: snapshot.childSnapshot(forPath: "fName").value!) as String!
    
        print ("eachEmployerB\(eachEmployer)")
        print ("self.employerArray2[eachEmployer]\(self.employerArray2[eachEmployer])")

        self.employerArray3[("\(self.employerNameForGoogle) \(self.employerLastNameForGoogle)")] = self.employerArray2[eachEmployer]
        print ("array3\(self.employerArray3)")

        })
        }//end of loop
        }//end of dispatch
        })//end of dbref employeeid
        }//end of find
    
        func helper(){
        self.helpBackground.isHidden = false
        }
    
        func googleCalanderConnected(){
        let currentUser = FIRAuth.auth()?.currentUser
        print (currentUser as Any)
        if currentUser != nil {
        print(currentUser!.uid)
        employeeId = (currentUser!.uid)
        self.dbRefEmployee.child(self.employeeId).observeSingleEvent(of: .value , with: { (snapshot) in
        self.LastCalander = String(describing: snapshot.childSnapshot(forPath: "fLastCalander").value!) as String!
        
            
        if self.LastCalander == "New" { self.alert456()} else{
        //setting minimum date
        print ((Date()-(3600*24*45)))
        print (self.mydateFormat5.date(from: self.LastCalander!)!)
        if (Date()-(3600*24*45)) > self.mydateFormat5.date(from: self.LastCalander!)! {print ("date is later");self.minDate = (Date()-(3600*24*45))} else {print ("lastcalander is later"); self.minDate = self.mydateFormat5.date(from: self.LastCalander!)!}
        self.alert123()
        }
        })//end of dbref
        findEmployerId()
        }// end of if current user is not nil
        }//end of ggc
    
    func pop(alert: UIAlertAction!){
    self.navigationController!.popViewController(animated: true)
    }
    
    
// alerts/////////////////////////////////////////////////////////////////////////////////////////////////////////
            // Helper for showing an alert
            func showAlert(title : String, message: String) {
            let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
            )
            let ok = UIAlertAction  (
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: self.pop
        
            )
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            }

            func  alert123(){

            if self.LastCalander == nil {
            print ("nil and therefore alert456");
            alert456()
            } else {
            if mydateFormat5.date(from: self.LastCalander!)! <=  Date()-(3600*24*60)
            {self.LastCalander = mydateFormat5.string(from: Date()-(3600*24*60))}
            }//end of else
            print (LastCalander!)


            let alertController123 = UIAlertController(title: ("Import Calander Sessions") , message: "You are about to import calander's sessions occured till now" , preferredStyle: .alert)

            let spesificAction = UIAlertAction(title: "Import \(employerFromMain)'s only", style: .default) { (UIAlertAction) in
            self.spesific = true
                self.thinking.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            self.fetchEvents()
            }
            }

            let allAction = UIAlertAction(title: "Import all accounts", style: .default) { (UIAlertAction) in
            self.spesific = false
                self.thinking.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            self.fetchEvents()
            }
            }
            
            let helpAction = UIAlertAction(title: "Help", style: .default) { (UIAlertAction) in
            self.helper()
                }

            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            self.navigationController!.popViewController(animated: true)
            //do nothing
            }

            if self.employerFromMain != "" {alertController123.addAction(spesificAction)}
            if self.employerFromMain == "" {alertController123.addAction(allAction)}
            alertController123.addAction(helpAction)
            alertController123.addAction(CancelAction)
            self.present(alertController123, animated: true, completion: nil)

            }//end of alert123

            func  alert456(){

            if self.LastCalander == nil || self.LastCalander == "New" {self.LastCalander = mydateFormat5.string(from: Date()-(3600*24*45))}
            print (LastCalander!)


            let alertController456 = UIAlertController(title: ("Set import starting date") , message: "Import calander's sessions starting from \(mydateFormat9.string(from: mydateFormat5.date(from: LastCalander!)!))." , preferredStyle: .alert)

            let OKAction = UIAlertAction(title: "Starting date is OK", style: .default) { (UIAlertAction) in
            self.minDate = (Date()-(3600*24*45))
                self.dbRefEmployee.child(self.employeeId).updateChildValues(["fLastCalander":self.mydateFormat5.string(from: self.minDate!)])
            //self.spesific = false
                self.alert123()
            //self.fetchEvents()
            }

            let dateAction = UIAlertAction(title: "Change starting date", style: .default) { (UIAlertAction) in
            print("change date")
            self.datePickerBG.isHidden = false
            }

            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            self.navigationController!.popViewController(animated: true)
            //do nothing
            }

            alertController456.addAction(OKAction)
            alertController456.addAction(dateAction)
            alertController456.addAction(CancelAction)
            self.present(alertController456, animated: true, completion: nil)
            }
            }

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

    
    var calIn = ""
    var calInFB = ""
    
   var spesific : Bool = false
    
    var employerFromMain = ""
    var employerIdFromMain = ""
    var employer = ""
    
    let btn1 = UIButton(type: .custom)


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
    
    @IBOutlet weak var datePickerBG: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var animationImage: UIImageView!
    @IBOutlet weak var textAdd: UITextView!
    
    @IBAction func done(_ sender: Any) {
    datePicker.maximumDate = Date()
    datePicker.minimumDate = Date() - 24*3600*60
        
    LastCalander = mydateFormat5.string(from:  datePicker.date)
    print (LastCalander!)
        
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
        
        

        
        mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)"
            ,options: 0, locale: nil)!
        mydateFormat6.dateFormat = DateFormatter.dateFormat(fromTemplate: " EEE-dd-MMM-yyyy, (HH:mm)", options: 0, locale:Locale.autoupdatingCurrent )!
        mydateFormat9.dateFormat = DateFormatter.dateFormat(fromTemplate: " dd-MMM-yy", options: 0, locale:Locale.autoupdatingCurrent )!

        service.shouldFetchNextPages = true

        let currentUser = FIRAuth.auth()?.currentUser
        print (currentUser as Any)
        if currentUser != nil {
            
            print(currentUser!.uid)
            employeeId = (currentUser!.uid)
            //create zugot
            
                self.dbRefEmployee.child(self.employeeId).observeSingleEvent(of: .value , with: { (snapshot) in
                self.LastCalander = String(describing: snapshot.childSnapshot(forPath: "fLastCalander").value!) as String!
                print ("self.LastCalander!")
                print (self.LastCalander!)
                self.alert123()

                
            })//end of dbref
            

            findEmployerId()

        }
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        if GIDSignIn.sharedInstance().hasAuthInKeychain() == true{
            
            GIDSignIn.sharedInstance().signInSilently()
            print ("in")
            
        }
        else{
            print ("out")
            let signInButton = GIDSignInButton()
            view.addSubview(signInButton)
            signInButton.frame = CGRect(x: view.frame.width/2-104, y: 130, width: 208, height: 45)

            //not sign in
            
        }
        
        
        
        //Add a UITextView to display output.
        output.frame = view.bounds
        output.isEditable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        output.isHidden = true
        //view.addSubview(output);
        
       

        let help =  UIBarButtonItem(title: "Help", style: .plain, target: self, action: #selector(self.helper))
        navigationItem.rightBarButtonItem = help
        
    }//end of view did load ////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
      //      self.signInButton.isHidden = true
            self.output.isHidden = false
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            
            
        }
    }
    
    
    
    // Construct a query and get a list of upcoming events
    func fetchEvents() {
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")// instard of "primary"
        query.maxResults = 50
       // DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
        print("0.2 \(self.LastCalander!)")
        //query.timeMin = GTLRDateTime(date: (Date()-(3600*24*45)))
            print (self.LastCalander)
            
        query.timeMin = GTLRDateTime(date: self.mydateFormat5.date(from: self.LastCalander!)!)

        print("222")

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
        print ("\(event.summary!)")
        print (employerArray3)
        print ([employerArray3[event.summary!]] )
        
            let keyExists = employerArray3[("\(event.summary!)")]

            if (keyExists)  != nil {
                
                if spesific == false {
                if (keyExists!) != nil { print ("another all included");employerId = employerArray3[event.summary!]!
                saveToDB2()
                //avoid double entry
                id1 = event.identifier
                updater.summary = ("\(event.summary!)+")
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
                updateRead()
                }//end of if
                }//end of else

                }// end of if key exist != nil
            
            }//end of for event
            }
            // save last date
            if spesific == false {textAdd.text = "Accounts' sessions\r\n\r\n imported from calander"
                self.dbRefEmployee.child(employeeId).updateChildValues(["fLastCalander":self.mydateFormat5.string(from: Date())])}
            else {
                
                textAdd.text = "\(employerFromMain)'s sessions\r\n imported from calander"

            }
            animation()
            
            DispatchQueue.main.asyncAfter(deadline: .now()+4){

            self.navigationController!.popViewController(animated: true)
            }
            
            }//end of function
    
            func animation(){
            self.animationImage.center.x -= self.view.bounds.width
            self.animationImage.isHidden = false
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
    if let error = error {
    self.showAlert(title: "Error", message: error.localizedDescription)
    return
    }//end of if error
    }
    }//end of func
 
    func saveToDB2() {
    let record = ["fIn" : calInFB,  "fEmployer": String (describing : employer),"fIndication3" :"📆","fStatus" : "Pre","fEmployeeRef": String (describing : employeeId),"fEmployerRef":  String (describing : employerId)]
            
    let recordRefence = self.dbRef.childByAutoId()
    recordRefence.setValue(record)
        
    self.dbRefEmployee.child(employeeId).child("fEmployeeRecords").updateChildValues([recordRefence.key:Int(-((self.mydateFormat5.date(from: calInFB))?.timeIntervalSince1970)!)])
    self.dbRefEmployer.child(self.employerId).child("fEmployerRecords").updateChildValues([recordRefence.key:Int(-((self.mydateFormat5.date(from: calInFB))?.timeIntervalSince1970)!)])
        
    }//end of save
    
    func findEmployerId(){
        print ("fetch employerId")
        
        employerArray3.removeAll()
        employerArray2.removeAll()
        employerArray.removeAll()
        
        self.dbRefEmployee.child(employeeId).queryOrderedByValue().observeSingleEvent(of: .value, with: { (snapshot) in
            
        self.employerArray = snapshot.childSnapshot(forPath: "myEmployers").value! as! [String:Int]
        self.employerArray2 = Array(self.employerArray.keys) // for Dictionary
        print ("employerArray2\(self.employerArray2)")
          
        print ("match")
        for eachEmployer in 0...(self.employerArray2.count-1){
            
        self.dbRefEmployer.child(self.employerArray2[eachEmployer]).child("fEmployer").observeSingleEvent(of: .value, with: { (snapshot) in
        self.employerLastNameForGoogle = String(describing: snapshot.value!)
        self.employerArray3[self.employerLastNameForGoogle] = self.employerArray2[eachEmployer]
        print ("tttt1\(self.employerLastNameForGoogle)")
        })

        
        self.dbRefEmployer.child(self.employerArray2[eachEmployer]).child("fName").observeSingleEvent(of: .value, with: { (snapshot) in
        self.employerNameForGoogle = String(describing: snapshot.value!)
        if  self.employerNameForGoogle != ""   {self.employerArray3[self.employerNameForGoogle] = self.employerArray2[eachEmployer] }
        print ("tttt2\(self.employerNameForGoogle)")
            
        self.employerNameLastNameForGoogle = ("\(self.employerNameForGoogle) \(self.employerLastNameForGoogle)")
        if  self.employerNameForGoogle != "" {self.employerArray3[self.employerNameLastNameForGoogle] = self.employerArray2[eachEmployer]}
        print ("tttt3\(self.employerNameLastNameForGoogle)")
        print("uuuu4\(self.employerArray3)")
        })

        }//end of loop
        })//end of dbref employeeid
        }//end of find
    
    func helper(){
        view.addSubview(helpText!)
        helpText?.frame = CGRect(x: view.frame.width/2-104, y: 130, width: 208, height: 45)
        
    }
    

   
    
    
    
// alerts/////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func  alert123(){
        print (LastCalander)

        if self.LastCalander == nil || self.LastCalander == "New" {self.LastCalander = mydateFormat5.string(from: Date()-(3600*24*45))}
        print (LastCalander!)

        
        let alertController123 = UIAlertController(title: ("Import Calander Sessions") , message: "You are about to import calander's sessions from \(mydateFormat9.string(from: mydateFormat5.date(from: LastCalander!)!)) till Now." , preferredStyle: .alert)

        
        //let alertController123 = UIAlertController(title: ("Import Calander Sessions") , message: "You are about to import calander's sessions from \( mydateFormat9 .string(from: mydateFormat5.date(from: LastCalander!)!)) till Now." , preferredStyle: .alert)
        let allAction = UIAlertAction(title: "All accounts", style: .default) { (UIAlertAction) in
            self.spesific = false
        self.fetchEvents()
        }
        
        let spesificAction = UIAlertAction(title: "\(employerFromMain) only", style: .default) { (UIAlertAction) in
            self.spesific = true
        self.fetchEvents()
        }
        
        let dateAction = UIAlertAction(title: "Change begining date", style: .default) { (UIAlertAction) in
        print("change date")
        self.datePickerBG.isHidden = false
        }
        
        
        
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        self.navigationController!.popViewController(animated: true)
            //do nothing
        }
        
        alertController123.addAction(allAction)
        if self.employerFromMain != "" {alertController123.addAction(spesificAction)}
        alertController123.addAction(dateAction)
        alertController123.addAction(CancelAction)

        
        self.present(alertController123, animated: true, completion: nil)
        
    }
}

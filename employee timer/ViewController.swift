//BackUP
//  ViewController.swift
//  HP2
//
//  Created by אורי עינת on 1.9.2016.
//  Copyright © 2016 אורי עינת. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import CoreLocation
import MapKit
import AVFoundation

class ViewController: UIViewController , MKMapViewDelegate, CLLocationManagerDelegate ,UITableViewDelegate,UITableViewDataSource{
    
    var window: UIWindow?

    
    
    //database reference

    let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
    var newRegister = ""
    
    let dbRef = FIRDatabase.database().reference().child("fRecords")
    let dbRefEmployer = FIRDatabase.database().reference().child("fEmployers")
    let dbRefEmployee = FIRDatabase.database().reference().child("fEmployees")
    var tableRowHeight:Int?
    var employerRadious:Int?
    
    static var fixedCurrency:String!
    static var fixedName:String!
    static var fixedLastName:String!
    static var fixedemail:String!

    var paymentUpdate = String()
    var RateUpdate = 0.0

    
    var alive:Bool?
    static var checkSubOnce: Int?
    var addDog: Int?

    static var refresh:Bool?

    var player : AVAudioPlayer?
    
     var employerlistSub = UIView.self

    
    var savedActiveRecord = ""

    @IBOutlet weak var profile: UIBarButtonItem!
    
    var greenColor = UIColor(red :32.0/255.0, green: 150.0/255.0, blue: 24.0/255.0, alpha: 1.0)
    var redColor = UIColor(red :170.0/255.0, green: 26.0/255.0, blue: 0/255.0, alpha: 1.0)
    var brownColor = UIColor(red :141/255.0, green: 111/255.0, blue: 56/255.0, alpha: 1.0)
    var yellowColor = UIColor(red :225/255.0, green: 235/255.0, blue: 20/255.0, alpha: 1.0)
    var blueColor = UIColor(red :22/255.0, green: 131/255.0, blue: 248/255.0, alpha: 1.0)


    
    let Vimage = UIImage(named: "V")
    let nonVimage = UIImage(named: "emptyV")
    let dogVimage = UIImage(named: "dogshadow")
    let noSign = UIImage(named:"noSign")
    let sandwtchImageBig = UIImage(named: "sandWatchBig")
    let roundImageBig = UIImage(named: "roundBig")
    let pencilImage = UIImage(named: "pencilImage")

   
    var leashImage = UIImage(named:"Leash")?.withRenderingMode(.alwaysTemplate)
    var meluna = UIImage(named:"meluna")?.withRenderingMode(.alwaysTemplate)
    var billsIcon = UIImage(named:"billsIcon")?.withRenderingMode(.alwaysTemplate)
    var walkerProfile = UIImage(named:"walkerProfile")?.withRenderingMode(.alwaysTemplate)

    
    var ImageFromFirebase : UIImage?

    let mydateFormat = DateFormatter()
    let mydateFormat2 = DateFormatter()
    let mydateFormat5 = DateFormatter()

  
    //varibalwds for roundung
    var roundSecond = 0
    var roundMinute = 0
    var roundHour = 0
    var roundDay = 0
    var total = 0
    var gpsTag = ""
    var gpsTag2 = ""

    var activeId = ""
    var activeid2 = ""
    var  recordInProcess = ""
    
    let locationManager = CLLocationManager()
    var employerLocation: CLLocation?
    var location :CLLocation?
    
    
    
    var employerItem = ""
    var profileImageUrl = ""
    var dogItem = ""
    var activeItem = ""
    var employerInProcess = ""
    var employerIdRef = ""

     var activeSign = ""
    
    var dOut = ""
    
    var methood = "Normal"
    
    var pickerlabel =  UILabel.self
    

    @IBOutlet weak var thinking2: UIActivityIndicatorView!
    @IBOutlet weak var employerList: UITableView!
    @IBOutlet weak var employerListTop: NSLayoutConstraint!
    
    @IBOutlet weak var emoloyerListBottom: NSLayoutConstraint!
    @IBOutlet weak var employerListHeiget: NSLayoutConstraint!
    @IBOutlet weak var employerListBottom: NSLayoutConstraint!
    
    var listOfEmployers = [String:Int]()
    
    //Choose an employer object
    var pickerData: [String] = [String]()
    var dogData: [String] = [String]()
    var activeData: [String] = [String]()

    var pickerIP: [String] = [String]()
    var employerIdArray: [AnyObject] = []
    var employerIdArray2: [AnyObject] = []

    var imageArray: [String] = [String]()
    
    //variable for Segue
    var employerToS = ""
    var employerIDToS = ""
    var employeeIDToS = ""

    
    
    
    //variables for the Timer
    var employeeTimer = Timer()
    var employeeCounter: Int = 0
    var employeeCounterAsDate = Date()

    var dIn = String (describing: Date())
    var dIn2 = String (describing: Date())

    //var timeOut = Date()
  
    //Poo Pee
        var poo = "No"
        var pee = "No"
        @IBOutlet weak var pooBackground: UIView!
        @IBOutlet weak var PooSwitch: UISwitch!
        @IBAction func pooAction(_ sender: Any) {
        if PooSwitch.isOn {poo = "Yes"
        self.dbRef.child(self.activeId).updateChildValues(["fPoo" : "Yes"])
        }
        else {poo = "No"}
        print ("poo from switch\(poo)")
        }//end of poo action
    
        @IBOutlet weak var peeSwitch: UISwitch!
        @IBAction func peeAction(_ sender: Any) {
        if peeSwitch.isOn {pee = "Yes"
        self.dbRef.child(self.activeId).updateChildValues(["fPee" : "Yes"])
        }
        else{pee = "No"}
        }//end of pee action
   
    
    
    //The  appear
    
        @IBOutlet weak var timeBackground: UIView!
        @IBOutlet weak var timeh: UILabel!
        @IBOutlet weak var timem: UILabel!
        @IBOutlet weak var times: UILabel!
        @IBOutlet weak var DateIn: UILabel!
        @IBOutlet weak var workedFor: UILabel!
        @IBOutlet weak var addAmanualRecord: UIView!
    
        @IBOutlet weak var records: UIBarButtonItem!
        @IBOutlet weak var bills: UIBarButtonItem!
        @IBOutlet weak var petFile: UIBarButtonItem!

        @IBOutlet weak var setting: UIBarButtonItem!
        @IBOutlet weak var blinker: UILabel!
        @IBOutlet weak var blinker2: UILabel!
        @IBOutlet weak var chooseEmployer: UIButton!
        @IBOutlet weak var gpsDistance: UITextField!
        @IBOutlet weak var animationImage: UIImageView!
    
    @IBOutlet weak var startImage: UIImageView!
    @IBOutlet weak var stopImage: UIImageView!
    
    
    @IBOutlet weak var toolBar: UIToolbar!
    let btn1 = UIButton(type: .custom)
    let btn2 = UIButton(type: .custom)
    let btn3 = UIButton(type: .custom)
    let btn4 = UIButton(type: .custom)

    
    
  //  @IBOutlet weak var dogFileLbl: UITextField!
   // @IBOutlet weak var fileLbl: UITextField!

    
    //background that helps "add a manual background" disappear after it eas chosen
        @IBOutlet weak var stopBackground: UIView!
        @IBOutlet weak var startBackground: UIView!
    
    //start timer action
        @IBAction func Start(_ sender: AnyObject) {
            
            if self.paymentUpdate == "Normal" {

            timeh.text = "00H"
            timem.text = "00m"
            employeeCounter = 0
            
            //sound for start
            playSound()
        self.timeBackground.alpha = 1
            
        self.animationImage.alpha = 1
            self.postStartView()

        self.dbRefEmployee.child(self.employeeIDToS).child("myEmployers").updateChildValues([(self.employerIDToS):1]) //consider chane font color
        print ("location:\(String(describing: location))")
        print ("employerLocation:\(String(describing: employerLocation))")
        if let distance = location?.distance(from: employerLocation!) {
            gpsDistance.text = String(Int(distance))
            if distance > 80 {print ("distance is far \( distance)");  gpsTag = "🚩"}
            else {print ("distance is OK \(distance)"); gpsTag = "🏳"}
            print ("location:\(String(describing: location))")
        } //end of if let distance
        
        //timer loop
        self.employeeTimer.invalidate()
        //employeeCounter = 0
        employeeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        
        //intial date and time of the timer
        dIn =  mydateFormat5.string(from: Date()) //brings the a date as a string
        dIn2 = mydateFormat2.string(from: Date()) //brings the a date as a string
        DateIn.text = "Started:  " + self.dIn2
       
        let record = ["fIn" : dIn, "fEmployer": String (describing : employerToS),"fEmployeeRef": employeeIDToS,"fEmployerRef": employerIDToS, "fIndication" : gpsTag,"fStatus" : "W" , "fPoo" : "No", "fPee" : "No"]
        let fInRef = dbRef.childByAutoId()
        fInRef.setValue(record)
        print (String(describing:self.chooseEmployer.currentTitle!))
        activeId = fInRef.key
        print("activeID \(activeId)")
        dbRefEmployer.child(self.employerIDToS).updateChildValues(["finProcess" : activeId])
        recordInProcess = activeId
      
        pee = "No"
        poo = "No"
        if poo == "No" {PooSwitch.setOn(false, animated: true)} else {PooSwitch.setOn(true, animated: true)}
        if pee == "No" {peeSwitch.setOn(false, animated: true)} else {peeSwitch.setOn(true, animated: true)}
            }//end of if normal
            else{
                
                print ("ffff")
                //sound for start
                playSound()
                 self.DateIn.text = "Walking...\(self.dIn2)"
                self.postRoundView()

               
                self.dbRefEmployee.child(self.employeeIDToS).child("myEmployers").updateChildValues([(self.employerIDToS):1]) //consider chane font color
                print ("location:\(String(describing: location))")
                print ("employerLocation:\(String(describing: employerLocation))")
                if let distance = location?.distance(from: employerLocation!) {
                    gpsDistance.text = String(Int(distance))
                    if distance > 80 {print ("distance is far \( distance)");  gpsTag = "🚩"}
                    else {print ("distance is OK \(distance)"); gpsTag = "🏳"}
                    print ("location:\(String(describing: location))")
                } //end of if let distance
                
                //intial date and time of the timer
                dIn =  mydateFormat5.string(from: Date()) //brings the a date as a string
                dIn2 = mydateFormat2.string(from: Date()) //brings the a date as a string
               // DateIn.text = "Started:  " + self.dIn2
                
                let record = ["fIn" : dIn, "fOut": dIn,"fIndication2":gpsTag,"fIndication3": "↺","fTotal":"-1", "fEmployer": String (describing : employerToS),"fEmployeeRef": employeeIDToS,"fEmployerRef": employerIDToS, "fIndication" : gpsTag,"fStatus" : "Pre" , "fPoo" : "No", "fPee" : "No"]
                let fInRef = dbRef.childByAutoId()
                fInRef.setValue(record)
                print(fInRef)
                
                print (String(describing:self.chooseEmployer.currentTitle!))
                                
                self.dbRefEmployee.child(self.employeeIDToS).child("fEmployeeRecords").updateChildValues([fInRef.key:Int(-(self.mydateFormat5.date(from: self.dIn)?.timeIntervalSince1970)!)])
                self.dbRefEmployer.child(self.employerIDToS).child("fEmployerRecords").updateChildValues([fInRef.key:Int(-(self.mydateFormat5.date(from: self.dIn)?.timeIntervalSince1970)!)])

                
            }//end of else

        }//end of start
    
    //update counter for the timer
        func updateCounter() {
        //print("employeecounter pre+\(employeeCounter)")
        employeeCounter += 1
        let (h,m,_) = secondsTo(seconds: employeeCounter)

       

        if blinker.isHidden == false {
            self.blinker.isHidden = true
            self.blinker2.isHidden = true
        } else { self.blinker.isHidden = false;            self.blinker2.isHidden = false
            }//end of else
            
            if 10 > m {timem.text = String("0\(m)m")} else
            {timem.text = String("\(m)m")}
            if 10 > h  {timeh.text = String("0\(h)H")} else {timeh.text = String("\(h)H")}
            if h > 23  {employeeCounter = 0; logicAlert()
                
            }
        }//end of update counter
    
        func secondsTo (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600 ) % 60)
        }//end of secondsTo
    
    //Stop button of the timer

    
        @IBOutlet weak var stopButton: UIButton!
        @IBOutlet weak var startButton: UIButton!
    
        @IBAction func Stop(_ sender: AnyObject) {

        employeeTimer.invalidate()
       
        dOut = mydateFormat5.string(from: Date()) //brings the a date as a string
        workedFor.text = "till: " + ( mydateFormat2.string(from: mydateFormat5.date(from: dOut)!))
        
        
        //self.employeeCounter = 0
            if let distance2 = location?.distance(from: employerLocation!) {
                gpsDistance.text =  String(Int(distance2))

                 print("distance2 is:\(distance2)")
                if distance2 > 80 {print ("distance is far \( distance2)");  gpsTag2 = "🚩"}
                else {print ("distance is OK \(distance2)"); gpsTag2 = "🏳"}
                print ("location:\(String(describing: location))")
            } //end of if let distance
            
        normalClosure()

      //  self.locationManager.stopUpdatingLocation() //addit to tho stop updating location
        }//end of stop
    
    
    
    
    override func viewDidLoad() {  //view did load/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    super.viewDidLoad()
        
        
print ("started view did load")
        ViewController.checkSubOnce = 1
        
        //check if user not deleted
     checkUserAgainstDatabase { (alive, error3) in
       
        }
        
        employerList.dataSource = self
        employerList.delegate = self
        
        records.isEnabled = false

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
        
        employerList.backgroundColor = UIColor.clear
        
        
        //application did become active
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.applicationDidBecomeActive(notification:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.applicationDidBecomeActive(notification:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
       
        //application stop active
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.applicationDidBecomePassive(notification:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.applicationDidBecomePassive(notification:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)

        let currentUser = FIRAuth.auth()?.currentUser
        print (currentUser as Any)
           if currentUser != nil {
            print(currentUser!.uid)
            self.employeeIDToS = (currentUser!.uid)
            print ("employerIDTOS\(self.employeeIDToS)")
            print ("employeridref\(self.employerIdRef)")
            print ("employeridref2\(self.employerIdRef)")
            self.fetchEmployers()
            self.dbRefEmployee.removeAllObservers()

            //self.employerList.reloadData()
            //self.employerList.reloadInputViews()
            
    
        
          //  self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Grass12")!)
       // self.view.insertSubview(backgroundImage, at: 0)
       // if(UIApplication.shared.statusBarOrientation.isLandscape)
      //  {self.view.insertSubview(backgroundImage, at: 30)
      //  backgroundImage.frame = self.view.bounds}
        
        if poo == "No" {PooSwitch.setOn(false, animated: true)} else {PooSwitch.setOn(true, animated: true)}
        if pee == "No" {peeSwitch.setOn(false, animated: true)} else {peeSwitch.setOn(true, animated: true)}
        if methood == "Normal" {print ("Normal!!!!!!!!")}
       
        //GPS
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()// thi smean that it won't work when app in the background - consider change it accordingly.
        self.locationManager.startUpdatingLocation()
        
        //formating the date
        mydateFormat.dateFormat = DateFormatter.dateFormat(fromTemplate: " EEE-dd-MMM-yyyy, (HH:mm)", options: 0, locale: nil)!
        mydateFormat2.dateFormat = DateFormatter.dateFormat(fromTemplate:  " HH:mm", options: 0, locale: nil)!
        mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)"
                ,options: 0, locale: nil)!
        
        DateIn.text = ""
       
        self.dbRefEmployee.queryOrderedByKey().queryEqual(toValue: currentUser?.uid).observeSingleEvent(of: .childAdded, with: { (snapshot) in
        ViewController.fixedCurrency = String(describing: snapshot.childSnapshot(forPath: "fCurrency").value!) as String
            ViewController.fixedName =  String(describing: snapshot.childSnapshot(forPath: "fName").value!) as String
            ViewController.fixedLastName =  String(describing: snapshot.childSnapshot(forPath: "fLastName").value!) as String
            ViewController.fixedemail =  String(describing: snapshot.childSnapshot(forPath: "femail").value!) as String


        })
            
           } else {
            
            print ("i am here")
            print ("newreg\(newRegister)")
            if  newRegister == "YES" {
                self.navigationController? .pushViewController(self.storyboard!.instantiateViewController(withIdentifier: "setting"), animated: false)
            }//end of Yes
            //no user connected
        }//end of else
        ////////end of firauth
 
        self.thinking2.hidesWhenStopped = true
        self.thinking2.startAnimating()
        
        btn1.setImage(leashImage, for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 60, height: 100)
        btn1.addTarget(self, action:#selector(recordsClicked), for: UIControlEvents.touchDown)
        records.customView = btn1
        
        btn2.setImage(meluna, for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 60, height: 100)
        btn2.addTarget(self, action:#selector(petFileClicked), for: UIControlEvents.touchDown)
        petFile.customView = btn2
        
        btn3.setImage(billsIcon, for: .normal)
        btn3.frame = CGRect(x: 0, y: 0, width: 60, height: 100)
        btn3.addTarget(self, action:#selector(billsClicked), for: UIControlEvents.touchDown)
        bills.customView = btn3
        
        btn4.setImage(walkerProfile, for: .normal)
        btn4.frame = CGRect(x: 0, y: 0, width: 60, height: 100)
        btn4.addTarget(self, action:#selector(profileClicked), for: UIControlEvents.touchDown)
        profile.customView = btn4

       
        


    }// end of viewdidload//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
    override func viewDidAppear(_ animated: Bool) {
        self.locationManager.startUpdatingLocation()

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
        
        if ViewController.refresh == true ||  employerToS ==  "Add new dog" {
        chooseEmployer.sendActions(for: .touchUpInside)
        ViewController.refresh = false
            
           
        
            
        }
        

    }//end of view did appear
    
    override func viewDidDisappear(_ animated: Bool) {
        self.locationManager.stopUpdatingLocation()
    }
  
        override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if(UIApplication.shared.statusBarOrientation.isLandscape)
        {backgroundImage.frame = self.view.bounds} else   {backgroundImage.frame = self.view.bounds}
        }//end of did rotate
    
    
    //sound
    // let alertSound = audioPlayer.data
    //try audioPlayer = AVAudioPlayer.init(data: alertSound!, fileTypeHint: "wav")
    
    // audioPlayer.prepareToPlay()
    //audioPlayer.play()
    
    func playSound() {
        let url = Bundle.main.url(forResource: "dogBark", withExtension: "wav")
        
        do {
            player = try AVAudioPlayer(contentsOf: url!)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }//end of palysound
    
    //check subscription
    func checkSubs()
    {
    //    /*
       print(ViewController.checkSubOnce!,self.employerIdArray2.count)
        
        if ViewController.checkSubOnce == 1 && self.employerIdArray2.count > 3 || self.employerIdArray2.count > 2 && addDog == 1 { RebeloperStore.shared.verifyRenewablePurchase(.autoRenewableSubscription1) { (result, resultString) in
            print( result)
            
            if result == false { ViewController.checkSubOnce = 1;print ("no subscription"); self.alert83() //uncomment to make sure there is a subbscription check
            }
            else {ViewController.checkSubOnce = 2} //end of else  meaning there is subscription
            }//end of subscription result check
            
            }else {ViewController.checkSubOnce = 2}// alreadu checked checksubonce = 2 or count <2
        ViewController.checkSubOnce = 2//uncomment to enable check
        addDog = 0
 
// */
    }//end of func
  
    //Check if user does exists
    func checkUserAgainstDatabase(completion: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        guard let currentUser = FIRAuth.auth()?.currentUser else { return }
        currentUser.getTokenForcingRefresh(true) { (idToken, error) in
            if let error = error {
                completion(false, error as NSError?)
                print(error.localizedDescription)
                
               try! FIRAuth.auth()!.signOut()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
               // let loginViewController  =  storyboard.instantiateViewController(withIdentifier: "loginScreen")
                //self.window?.rootViewController = loginViewController
                self.present((storyboard.instantiateViewController(withIdentifier: "loginScreen")), animated: true, completion: nil)

                
            } else {
                
                completion(true, nil)
            }
        }
    }

    
    //did become active procedure
    func applicationDidBecomeActive(notification: NSNotification) {
        thinking2.startAnimating()
        self.locationManager.startUpdatingLocation()

        //stopButton.sendActions(for: .touchUpInside)
        if petFile.isEnabled == true {
       // self.activeId = idFromSleep
            print ("resumeactiveID\(self.activeId)")
            self.recordInProcess = self.savedActiveRecord
            print ("resumeRecordinprocess\(self.recordInProcess)")
            
            bringCoordninates()
            
            // reset varibales on select
            poo  = "No"
            pee = "No"
            //employeeCounter = 0
            
            //manage the view
            PooSwitch.onTintColor = brownColor
            peeSwitch.onTintColor = yellowColor
            
            
            if recordInProcess != "" {
                bringRecord()
                //postStartView()
            }
            else{
                preStartView()
            }//end of elsee
            
            //set variable for Segue
           // employerToS = String(describing:chooseEmployer.currentTitle!)

            print (employerToS)
            
            print("vv")
            
            

        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {

        self.thinking2.stopAnimating()
        }

    }// end of func application did become
    
    //did stop active procedure
    func applicationDidBecomePassive(notification: NSNotification) {
        
        //stopButton.sendActions(for: .touchUpInside)
        if petFile.isEnabled == true {
            savedActiveRecord =  self.recordInProcess
            print ("resumeactiveID\(self.activeId)")
            self.locationManager.stopUpdatingLocation()

        }
    }// end of func application did stop
    
    //chose employer
        @IBAction func chooseEmployerBtn(_ sender: AnyObject) {
            
            thinking2.startAnimating()
            timeh.text = ""
            timem.text = ""
            employerIDToS = ""
            employerToS = ""
        //self.employeeTimer.invalidate() //dismiss func of counter

        fetchEmployers()
        self.dbRefEmployee.removeAllObservers()
            
        postTimerView()
        self.animationImage.alpha = 1


        }//end of choose employerbtn
    
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        }
    
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print ("GPS ERORR!!!!!!")
        }
    
    func recordsClicked() {
      performSegue(withIdentifier: "employerforVC", sender: employerToS)
    }
    
    func petFileClicked() {
        performSegue(withIdentifier: "employerForDogFile", sender: employerToS)
    }
    
    func  billsClicked() {
        performSegue(withIdentifier: "employerForBills", sender: employerToS)
    }
    
    func  profileClicked() {
        performSegue(withIdentifier: "setting", sender: employerToS)
    }
    //add record
    
    @IBAction func addManualRecord(_ sender: Any) {
    
            print ("click")
            
            
       // performSegue(withIdentifier: "employerforRecord", sender: employerToS)
        }
  
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "employerforRecord") {
        let secondView = segue.destination as? datePicker2
            secondView?.employerFromMain = employerToS
            secondView?.employerID = employerIDToS
            secondView?.employeeID = employeeIDToS
            secondView?.paymentMethood = paymentUpdate

        }//end of if
        
        else if (segue.identifier == "employerForDogFile"){
        let recordsView = segue.destination as? dogFile
        recordsView?.employerID = employerIDToS
        recordsView?.employerFromMain = employerToS
        recordsView?.employeeID = employeeIDToS
        }//end of else if
            
        else if (segue.identifier == "employerForBills"){
            let recordsView = segue.destination as? biller
            recordsView?.employerID = employerIDToS
            recordsView?.employerFromMain = employerToS
            recordsView?.employeeID = employeeIDToS
        }//end of else if
    
        else{
        let recordsView = segue.destination as? newVCTable
        recordsView?.employerFromMain = employerToS
        recordsView?.employerID = employerIDToS
        recordsView?.employeeID =  employeeIDToS
        }
        }//end of prepare
    
    //locTION DELEGTE METHODS
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        // self.locationManager.stopUpdatingLocation() //addit to tho stop updating location
        }
    
    //bring record
        func bringRecord() {

        timeh.text = ""
        timem.text = ""
        print (recordInProcess)
        dbRef.child(recordInProcess).observeSingleEvent(of:.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: String] {
            let record = recordsStruct()
            record.setValuesForKeys(dictionary)
            print ("Dic:\(dictionary)")
            self.activeId = self.recordInProcess
            
            // bring in process data to record
            self.dIn = record.fIn!
                self.dIn2 = self.mydateFormat2.string(from:self.mydateFormat5.date(from: self.dIn)!)
                self.DateIn.reloadInputViews()
                print ("din from  in process\(self.dIn)")
                                self.DateIn.text = "Started:  " + self.dIn2

                
                //should understand the time local!!!!!!!
                let timerResume =  Date().timeIntervalSince((self.mydateFormat5.date(from: self.dIn))!)   //the diffrence date() din
                print ("timeresume\(timerResume)")
                self.employeeCounter = Int(timerResume)
                self.employeeTimer.invalidate()
                self.employeeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
              
                self.gpsTag = record.fIndication!

                self.poo  = record.fPoo!
                self.pee = record.fPee!
                if self.poo == "No" {self.PooSwitch.setOn(false, animated: true)} else {self.PooSwitch.setOn(true, animated: true)}
                if self.pee == "No" {self.peeSwitch.setOn(false, animated: true)} else {self.peeSwitch.setOn(true, animated: true)}
            }// end of if let dictionary
        }, withCancel: { (Error) in
            print("error from FB")
        })
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                
                self.thinking2.stopAnimating(self.postStartView())

            }

            
            } //end of bring record
    
    //bring record round
    func bringRecordRound() {
        
        
        dbRef.child(activeid2).observeSingleEvent(of:.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: String] {
                let record = recordsStruct()
                record.setValuesForKeys(dictionary)
                print ("Dic:\(dictionary)")
                

                
                // bring in process data to record
                self.dIn = record.fIn!
                print ("din from  in process\(self.dIn)")
                self.DateIn.text = "Started:  " + self.dIn2
                
            
                
               // self.gpsTag = record.fIndication!
                
                }// end of if let dictionary
        }, withCancel: { (Error) in
            print("error from FB")
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            
            self.thinking2.stopAnimating(self.postStartView())
            
        }
        

    } //end of bring recordround
    
    //normal closure
        func normalClosure () {
        print("recordiscomplete")
        let alertController = UIAlertController(title: (dIn) , message: ("Till: \( mydateFormat2.string(from: mydateFormat5.date(from: dOut)!))"), preferredStyle: .alert)
        let resumeAction = UIAlertAction(title: "Resume", style: .default) { (UIAlertAction) in
        print ("resumeactiveID\(self.activeId)")
        self.recordInProcess = self.activeId
        print ("resumeRecordinprocess\(self.recordInProcess)")

            self.bringRecord()
            self.postStartView()

        } //end of resume
            
        let cancelAction = UIAlertAction(title: "Delete", style: .cancel) { (UIAlertAction) in
            self.preStartView()
            
            self.timeh.text = ""
            self.timem.text = ""
            
            self.dbRef.child(self.activeId).removeValue()
            self.navigationController!.popViewController(animated: true)
            

            self.dbRefEmployee.child(self.employeeIDToS).child("myEmployers").updateChildValues([(self.employerIDToS):5])
            self.dbRefEmployer.child(self.employerIDToS).updateChildValues(["finProcess" : ""])
            //self.employeeCounter = 0
            self.activeId = ""
            self.recordInProcess = self.activeId

        }//end of cancel action
        
            //update action
        let updateDBAction = UIAlertAction(title: "Accept", style: .default) { (UIAlertAction) in
            //
           // self.employeeCounter = 0
            self.timeh.text = ""
            self.timem.text = ""
            
            //rounding
            let calendar = Calendar.current
            let date2 = calendar.dateComponents([.day, .hour,.minute,.second], from: self.mydateFormat5.date(from: self.dIn)!)
            let date1 = calendar.dateComponents([.day, .hour,.minute, .second], from: self.mydateFormat5.date(from: self.dOut)!)
                
            self.roundSecond = date1.second! - date2.second!
            self.roundMinute = date1.minute! - date2.minute!
            self.roundHour = date1.hour! - date2.hour!
            self.roundDay = date1.day! - date2.day!
            print ("second\(self.roundSecond)")
            print ("roundMinute\(self.roundMinute)")
            print ("hour\(self.roundHour)")
            print ("roundDay\(self.roundDay)")

            if self.roundDay == 0 {  self.total = self.roundMinute*60 + self.roundHour*3600}
            else if self.roundDay == 1 {self.total = ((24-date2.hour!+date1.hour!)*3600 + (self.roundMinute*60))}
            else {self.total = 0            }
            let total2 = self.mydateFormat5.date(from: self.dOut)!.timeIntervalSince((self.mydateFormat5.date(from: self.dIn))!)
            self.dbRefEmployee.child(self.employeeIDToS).child("myEmployers").updateChildValues([(self.employerIDToS):5])

            self.dbRefEmployer.child(self.employerIDToS).updateChildValues(["finProcess" : ""])

            print ("total\(self.total)")
            print ("total2\(total2)")

            let record = [ "fOut" : self.dOut, "fTotal" : String((self.total)),"fIndication" : self.gpsTag,"fIndication3" : "⏳","fIndication2" : self.gpsTag2, "fStatus" : "Pre" , "FPoo" : self.poo, "fPee" : self.pee]
            
            print ("active in updating statge:\(self.activeId)")
            

            
            self.dbRef.child(self.activeId).updateChildValues(record)
            self.dbRefEmployer.child(self.employerIDToS).updateChildValues(["finProcess" : ""])
            self.dbRefEmployee.child(self.employeeIDToS).child("fEmployeeRecords").updateChildValues([self.activeId:Int(-(self.mydateFormat5.date(from: self.dIn)?.timeIntervalSince1970)!)])
            
            
            self.dbRefEmployer.child(self.employerIDToS).child("fEmployerRecords").updateChildValues([self.activeId:Int(-(self.mydateFormat5.date(from: self.dIn)?.timeIntervalSince1970)!)])
            
            
            
            
            self.navigationController!.popViewController(animated: true)
            
            self.animationImage.center.x -= self.view.bounds.width
            self.animationImage.isHidden = false
            self.animationImage.alpha = 1

           
            UIView.animate(withDuration: 2.0, animations:{
                self.animationImage.center.x += self.view.bounds.width
            })
            UIView.animate(withDuration: 2.0, delay :2.0 ,options:[],animations: {
                self.animationImage.alpha = 0
                self.preStartView()
                self.startBackground.alpha = 0
                self.addAmanualRecord.alpha = 0
            },completion:nil)
            UIView.animate(withDuration: 1.0, delay :4.0 ,options:[],animations: {
                self.startBackground.alpha = 1
                self.addAmanualRecord.alpha = 1
                self.preStartView()
            },completion:nil)

            self.activeId = ""
            self.recordInProcess = self.activeId

        }//end of update action
            
            print (self.employeeCounter)
            alertController.addAction(cancelAction)
            alertController.addAction(updateDBAction)
            alertController.addAction(resumeAction)
            self.present(alertController, animated: true, completion: nil)
        }//probabaly end of normal closure

    //bring coordinates
        func bringCoordninates() {
        dbRefEmployer.queryOrdered(byChild: "fEmployer").queryEqual(toValue: String(describing:self.employerToS)).observeSingleEvent(of: .childAdded , with: { (snapshot) in
            
            let currentEmployerX = String(describing: snapshot.childSnapshot(forPath: "fLocationX").value!) as String
            print (currentEmployerX)
            let currentEmployery = String(describing: snapshot.childSnapshot(forPath: "fLocationY").value!) as String
            self.employerLocation = CLLocation(latitude: Double(currentEmployerX)!, longitude: Double(currentEmployery)!)
            print (self.employerLocation!)
            print("coordinatessssssssss")
            //self.dbRefEmployer.removeAllObservers()
            //print(self.employerLocation)
        })  {(error) in
            print("error from FB\(error.localizedDescription)")}//end of dbrefemployer
      
        }//end of bringcoordinated
    
    //check if their is who to connect
    func checkConnection() {
        
        
    }

    
    //fetch employer
        func fetchEmployers() {
       
                self.employerIdArray.removeAll()
                self.employerIdArray2.removeAll()
                
                self.pickerData.removeAll()
                self.imageArray.removeAll()
                self.dogData.removeAll()
                self.activeData.removeAll()
                self.pickerIP.removeAll()
            
 
            print ("pickerData\(self.pickerData)")


        
        print("ihkhih\(employeeIDToS)")
            //self.employerList.reloadData()

        
            self.dbRefEmployee.child(self.employeeIDToS).child("myEmployers").observeSingleEvent(of: .value, with:{(snapshot) in
           // self.employerIdRef = String(describing: snapshot.key)
                self.listOfEmployers = snapshot.value as! [String : AnyObject] as! [String : Int]
                func sortFunc   (_ s1: (key: String, value: Int), _ s2: (key: String, value: Int)) -> Bool {
                    return   s2.value > s1.value
                    }
            //self.employerIdArray.append((self.employerIdRef))
            
                print ("ggggg\(self.listOfEmployers)")
                
                self.employerIdArray = (self.listOfEmployers.sorted(by: sortFunc) as [AnyObject]  )
                print ("ggggg2\(self.employerIdArray)")
                
                for j in 0...(self.employerIdArray.count-1){
                    let splitItem = self.employerIdArray[j] as! (String, Int)
                    print (splitItem)
                    
                    let split2    = splitItem.0
                    print (split2)
                    
                    self.employerIdArray2.append(split2 as AnyObject)
                    
                }
                
                print ("employeridarray2\(self.employerIdArray2)")


                for iIndex in 0...(self.employerIdArray2.count-1){
                   

                    self.dbRefEmployer.child(self.employerIdArray2[iIndex] as! String).observeSingleEvent(of: .value, with:{ (snapshot) in
                
                    self.employerItem = String(describing: snapshot.childSnapshot(forPath: "fEmployer").value!) as String!
                    print("i3 \(iIndex)")
                    self.pickerData.append(self.employerItem  )
                    

                   // self.pickerData.insert(self.employerItem, at: i-1)
                    print ("pickerData\(self.pickerData)")

                    self.employerInProcess = String(describing: snapshot.childSnapshot(forPath: "finProcess").value!) as String!
                    self.pickerIP.append((self.employerInProcess))

  
                self.dogItem = String(describing: snapshot.childSnapshot(forPath: "fPetName").value!) as String!
                    self.dogData.append(self.dogItem  )

                self.activeItem = String(describing: snapshot.childSnapshot(forPath: "fActive").value!) as String!
                    self.activeData.append(String(describing: self.activeItem) )
print (snapshot.childSnapshot(forPath: "fImageRef").value!)
                        
                        
                          self.profileImageUrl = snapshot.childSnapshot(forPath: "fImageRef").value as! String!
                          //  self.profileImageUrl = "https://firebasestorage.googleapis.com/v0/b/persession-45987.appspot.com/o/Myprofile.png?alt=media&token=263c8fdb-9cca-4256-9d3b-b794774bf4e1"
                    self.imageArray.append(self.profileImageUrl)
                        
                       // self.employerList.reloadData()

                    if iIndex == (self.employerIdArray2.count-1) {
                     
                        self.thinking2.stopAnimating()

                        self.employerList.isUserInteractionEnabled = true
                        if self.employerIdArray2.count < 5 {self.employerListHeiget.priority = 1000 ;self.employerListBottom.priority = 750;self.employerListTop.constant = 60.0; self.employerListHeiget.constant >= 265;self.employerListBottom.constant = 285} else {self.employerListBottom.priority = 750; self.employerListHeiget.priority = 1000;self.employerListTop.constant = 30.0;self.employerListHeiget.constant >= 315;self.employerListBottom.constant = 285 }
                        self.employerList.reloadData()
                       // print (self.employerIdArray2.count)
                      self.checkSubs()
                        
                        
                        

                        self.employerList.isHidden = false
                        self.dbRefEmployer.removeAllObservers()



                    }

                    self.dbRefEmployee.removeAllObservers()
                }){(error) in
                    print(error.localizedDescription)} // end of dbrefemployer
                
                }//end of i loop

        }){(error) in
        print(error.localizedDescription)}//end of dbref employee
            

            }//end of fetch employer
    
    func preStartView() {
        
        self.stopBackground.isHidden = true
        self.addAmanualRecord.isHidden = false
        self.DateIn.isHidden = true
        self.timeBackground.isHidden = true
        //self.gpsDistance.isHidden = true
        self.pooBackground.isHidden = true
        self.workedFor.isHidden = true
        self.startBackground.isHidden = false
        startBarButtonFadeOut()
        startBarButtonFadeIn()
        
        self.petFile.isEnabled = true; 
        print("qzhhjq")
        //self.dogFileLbl.isHidden = false
       // self.fileLbl.isHidden = false
        self.chooseEmployer.isUserInteractionEnabled = true

        ///
        
        
    }//end of func
    
    func postStartView() {
        self.petFile.isEnabled = true
       // self.dogFileLbl.isHidden = false
        //self.fileLbl.isHidden = false

        self.timeBackground.isHidden = false
        self.animationImage.isHidden = true
        self.startBackground.isHidden = true
        self.DateIn.isHidden = false;
        self.workedFor.isHidden = true
        self.pooBackground.isHidden = true//false
        self.addAmanualRecord.isHidden = true
        self.stopBackground.isHidden = false
        stopBarButtonFadeOut()
        stopBarButtonFadeIn()
        //self.gpsDistance.isHidden = false
        self.chooseEmployer.isUserInteractionEnabled = true
        UIView.animate(withDuration: TimeInterval(4.9),delay: 0, options: [.repeat], animations:{
            self.stopImage.transform = self.stopImage.transform.rotated(by: CGFloat(Double.pi*1))
        })
      //  UIView.animate(withDuration: TimeInterval(3),delay: 3, options: [.repeat], animations:{
        //    self.stopImage.transform = self.stopImage.transform.rotated(by: CGFloat(Double.pi*1))
        //})

    
    }//end of func
    
        func postTimerView() {
        
        DateIn.isHidden = true
        records.isEnabled = false
        petFile.isEnabled = false
       // dogFileLbl.isHidden = true
         //   self.fileLbl.isHidden = true

        chooseEmployer.isHidden = true
        startBackground.isHidden = true
        stopBackground.isHidden = true
        addAmanualRecord.isHidden = true
        timeBackground.isHidden = true
        self.gpsDistance.isHidden = true
        pooBackground.isHidden = true
        animationImage.isHidden = true
        
    }//end of func
    
    func postRoundView() {
        
        self.petFile.isEnabled = true
        // self.dogFileLbl.isHidden = false
        //self.fileLbl.isHidden = false
        

        
        self.timeBackground.isHidden = true
        self.animationImage.isHidden = false
        self.startBackground.isHidden = true
        self.DateIn.isHidden = false;
        self.workedFor.isHidden = true
        self.pooBackground.isHidden = true
        self.addAmanualRecord.isHidden = true
        self.stopBackground.isHidden = true
        //stopBarButtonFadeOut()
       // stopBarButtonFadeIn()
        //self.gpsDistance.isHidden = false
        self.chooseEmployer.isUserInteractionEnabled = true
        
                self.navigationController!.popViewController(animated: true)
        
       
        ///
        self.animationImage.center.x -= self.view.bounds.width
        self.animationImage.isHidden = false
        self.animationImage.alpha = 1
        
        
        UIView.animate(withDuration: 2.0, animations:{
            self.animationImage.center.x += self.view.bounds.width
        })
        UIView.animate(withDuration: 2.0, delay :2.0 ,options:[],animations: {
            self.animationImage.alpha = 0
            //self.preStartView()
            self.startBackground.alpha = 0
            self.addAmanualRecord.alpha = 0
        },completion:nil)
        UIView.animate(withDuration: 1.0, delay :4.0 ,options:[],animations: {
            self.startBackground.alpha = 1
            self.addAmanualRecord.alpha = 1
            self.preStartView()
            self.DateIn.alpha = 0

        },completion:nil)
        
    }//end of func oost round view
    
    //no Firebase connection
    
    func noFB() {
       
                self.thinking2.stopAnimating()
               // self.alert30()
            }
    
    func startBarButtonFadeOut(){
        UIView.animate(withDuration: 0.3, animations: {
            //timeCapDesign is a UIButton
            
            //self.startButton.alpha = 0
            
            self.startButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            
        })
    }
    
    // Fade In Buttons
    func startBarButtonFadeIn(){
        UIView.animate(withDuration: 0.3,delay: 0.3, animations: {
            
            self.startButton.alpha = 1
            
            self.startButton.transform = .identity// CGAffineTransformIdentity
        
            
        })
        
        UIView.animate(withDuration: 0.3, delay: 0.6 ,animations: {
            self.startButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            
        })
        UIView.animate(withDuration: 0.3, delay: 0.9,animations: {
            self.startButton.transform = .identity
        })
        
    }

    func stopBarButtonFadeOut(){
        UIView.animate(withDuration: 0.3, animations: {
            //timeCapDesign is a UIButton
            
           // self.stopButton.alpha = 0
            
            self.stopButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            
        })
    }
    
    //P Fade In Buttons
    func stopBarButtonFadeIn(){
        UIView.animate(withDuration: 0.3,delay: 0.3, animations: {
            
            self.stopButton.alpha = 1
            
            self.stopButton.transform = .identity// CGAffineTransformIdentity
            
            
        })
    }
    
///////////////////////////////////////alerts
    func       alert83(){
    let alertController83 = UIAlertController(title: ("Subscription alert") , message: " Adding more than two dogs requires subscription and we couldn't find one. please subscribe with free trial or log again if you have one.", preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        self.present((storyboard.instantiateViewController(withIdentifier: "subScreen")), animated: true, completion: nil)
     //   self.window?.rootViewController = loginViewController

        
        
    }
    
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            ViewController.checkSubOnce = 0
            self.addDog = 1
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
          self.present((storyboard.instantiateViewController(withIdentifier: "subScreen")), animated: true, completion: nil)
        }
        alertController83.addAction(OKAction)
        alertController83.addAction(cancelAction)

    self.present(alertController83, animated: true, completion: nil)
}

    func alert30(){
        let alertController30 = UIAlertController(title: ("No connection") , message: "Currently there is no connection with database. Please try again.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        }
        
        alertController30.addAction(OKAction)
        self.present(alertController30, animated: true, completion: nil)
    }
    
    //Logic alert
    func logicAlert () {
        
        let alertController4 = UIAlertController(title: "Record's limit", message: "Sorry, but  24 hours is record's limit. This record is deleted . Please update with a manual record.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
           self.preStartView()
            self.timeh.text = ""
            self.timem.text = ""
            
            self.dbRef.child(self.activeId).removeValue()
            
            
            self.dbRefEmployee.child(self.employeeIDToS).child("myEmployers").updateChildValues([(self.employerIDToS):5])
            self.dbRefEmployer.child(self.employerIDToS).updateChildValues(["finProcess" : ""])
            self.navigationController!.popViewController(animated: true)

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
    
}/////////////end!!!!!////////////////////////////////////////////////////////////////////////////////////////////////

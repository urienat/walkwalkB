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
//import AVFoundation
import Google
import GoogleSignIn
import GoogleAPIClientForREST

class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    var window: UIWindow?

    let dbRef = FIRDatabase.database().reference().child("fRecords")
    let dbRefEmployer = FIRDatabase.database().reference().child("fEmployers")
    let dbRefEmployee = FIRDatabase.database().reference().child("fEmployees")
    
    
    static var fixedCurrency:String!
    static var fixedName:String!
    static var fixedLastName:String!
    static var fixedemail:String!
    static var dateTimeFormat:String!
    static var refresh:Bool?

    var RateUpdate = 0.0
    var newRegister = ""
    var alive:Bool?
    static var checkSubOnce: Int?
    var addDog: Int?
    var tableRowHeight:Int?

    var blueColor = UIColor(red :22/255.0, green: 131/255.0, blue: 248/255.0, alpha: 1.0)

    let Vimage = UIImage(named: "vNaked")
    let nonVimage = UIImage(named: "emptyV")
    let dogVimage = UIImage(named: "dogshadow")
    let noSign = UIImage(named:"noSign")
    let sandwtchImageBig = UIImage(named: "sandWatchBig")
    let roundImageBig = UIImage(named: "roundBig")
    let pencilImage = UIImage(named: "pencilImage")
    var ImageFromFirebase : UIImage?
    var menu = UIImage(named: "menu")
    var leashImage = UIImage(named:"Leash")?.withRenderingMode(.alwaysTemplate)
    var meluna = UIImage(named:"meluna")?.withRenderingMode(.alwaysTemplate)
    var billsIcon = UIImage(named:"billsIcon")?.withRenderingMode(.alwaysTemplate)
    var walkerProfile = UIImage(named:"walkerProfile")?.withRenderingMode(.alwaysTemplate)

    let mydateFormat2 = DateFormatter()
    let mydateFormat5 = DateFormatter()
    let mydateFormat7 = DateFormatter()
    
    
    var isSideMenuHidden = true
    var employerItem = ""
    var profileImageUrl = ""
    var dogItem = ""
    var activeItem = ""
    var employerIdRef = ""
    var dOut = ""
    var methood = "Normal"
    var pickerlabel =  UILabel.self
    
    @IBOutlet weak var thinking2: UIActivityIndicatorView!
    @IBOutlet weak var employerList: UITableView!
    @IBOutlet weak var employerListTop: NSLayoutConstraint!
    @IBOutlet weak var emoloyerListBottom: NSLayoutConstraint!
    @IBOutlet weak var employerListHeiget: NSLayoutConstraint!
    @IBOutlet weak var employerListBottom: NSLayoutConstraint!
    
    var pickerData: [String] = [String]()
    var nameData: [String] = [String]()
    var activeData: [String] = [String]()

    var employerIdArray: [AnyObject] = []
    var employerIdArray2: [AnyObject] = []

    var imageArray: [String] = [String]()
    var listOfEmployers = [String:Int]()

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

    
    @IBOutlet weak var menuItem: UIBarButtonItem!
    @IBAction func menuItem(_ sender: Any) {
    sideMenuMovement()
    }//end of menu

    @IBOutlet weak var addAccount: UIBarButtonItem!
    @IBAction func addAccount(_ sender: Any) {
    print ("add")
    arrow.isHidden = true
    employerToS = "Add new dog"
    accountClicked()
    }

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var DateIn: UILabel!
    @IBOutlet weak var workedFor: UILabel!
    @IBOutlet weak var addAmanualRecord: UIView!
    @IBOutlet weak var records: UIBarButtonItem!
    @IBOutlet weak var bills: UIBarButtonItem!
    @IBOutlet weak var account: UIBarButtonItem!
    @IBOutlet weak var chooseEmployer: UIButton!
    @IBOutlet weak var animationImage: UIImageView!
    @IBOutlet weak var textAdd: UITextView!
    @IBOutlet weak var startImage: UIImageView!
    @IBOutlet weak var startBackground: UIView!
    @IBOutlet weak var importImage: UIImageView!
    @IBOutlet weak var importBackground: UIView!
    @IBOutlet weak var importBtn: UIButton!
    @IBAction func importBtn(_ sender: Any) {
    importClicked()
    }
    
    @IBOutlet weak var arrow: UIImageView!
    
    //side Menu
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var sideMenuConstarin: NSLayoutConstraint!
    @IBOutlet weak var sideMenu: UIView!
    @IBAction func billBtn(_ sender: Any) {
    sideMenuMovement()
    performSegue(withIdentifier: "employerForAllBills", sender: employerToS)
    }
    
    @IBAction func taxationBtn(_ sender: Any) {
    sideMenuMovement()
    performSegue(withIdentifier: "employerForTax", sender: employerToS)
    }
    
    @IBAction func importAllBtn(_ sender: Any) {
    sideMenuMovement()
    importAllClicked()
    }
    
    @IBAction func otherBtn(_ sender: Any) {
    sideMenuMovement()
    //do nothing
    }
    
    @IBAction func settingBtn(_ sender: Any) {
    sideMenuMovement()
    profileClicked()
    }
    
    @IBAction func logoutBtn(_ sender: Any) {
    sideMenuMovement()
    LoginFile.logoutchosen = true
    try! FIRAuth.auth()?.signOut()

    self.present((storyboard?.instantiateViewController(withIdentifier: "loginScreen"))!, animated: true, completion: nil)
    }
    
    @IBOutlet weak var toolBar: UIToolbar!
    let btn1 = UIButton(type: .custom)
    let btn2 = UIButton(type: .custom)
    let btn3 = UIButton(type: .custom)
    let btnMenu = UIButton(type: .custom)
 
    
    //start timer action
    @IBAction func Start(_ sender: AnyObject) {
    textAdd.text = "Session added: \r\n\( mydateFormat7.string(from: Date()))"
    self.postRoundView()
        
    self.dbRefEmployee.child(self.employeeIDToS).child("myEmployers").updateChildValues([(self.employerIDToS):1]) //consider chane font color
    dIn =  mydateFormat5.string(from: Date()) //brings the a date as a string
    dIn2 = mydateFormat2.string(from: Date()) //brings the a date as a string
    
    let record = ["fIn" : dIn,"fIndication3": "↺", "fEmployer": String (describing : employerToS),"fEmployeeRef": employeeIDToS,"fEmployerRef": employerIDToS,"fStatus" : "Pre"]
    let fInRef = dbRef.childByAutoId()
    fInRef.setValue(record)
        
    self.dbRefEmployee.child(self.employeeIDToS).child("fEmployeeRecords").updateChildValues([fInRef.key:Int(-(self.mydateFormat5.date(from: self.dIn)?.timeIntervalSince1970)!)])
    self.dbRefEmployer.child(self.employerIDToS).child("fEmployerRecords").updateChildValues([fInRef.key:Int(-(self.mydateFormat5.date(from: self.dIn)?.timeIntervalSince1970)!)])
    }//end of start
    
    override func viewDidLoad() {  //view did load/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    super.viewDidLoad()
        
    checkUserAgainstDatabase { (alive, error3) in}    //check if user not deleted

    employerList.dataSource = self
    employerList.delegate = self
    
    records.isEnabled = false
    bills.isEnabled = false
    account.isEnabled = false
        
    ViewController.checkSubOnce = 1
    DateIn.text = ""
    self.employerList.separatorColor = blueColor



    //connectivity
    if Reachability.isConnectedToNetwork() == true
    {print("Internet Connection Available!")
    }else{
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
    self.fetchEmployers()
    self.dbRefEmployee.removeAllObservers()
    
    //formating the date
    mydateFormat2.dateFormat = DateFormatter.dateFormat(fromTemplate:  " HH:mm", options: 0, locale: nil)!
    mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)",options: 0, locale: nil)!
    mydateFormat7.dateFormat = DateFormatter.dateFormat(fromTemplate: " EEE-dd MMM, (HH:mm)",options: 0, locale: nil)!
       
    self.dbRefEmployee.queryOrderedByKey().queryEqual(toValue: currentUser?.uid).observeSingleEvent(of: .childAdded, with: { (snapshot) in
    ViewController.fixedCurrency = String(describing: snapshot.childSnapshot(forPath: "fCurrency").value!) as String
    ViewController.fixedName =  String(describing: snapshot.childSnapshot(forPath: "fName").value!) as String
    ViewController.fixedLastName =  String(describing: snapshot.childSnapshot(forPath: "fLastName").value!) as String
    ViewController.fixedemail =  String(describing: snapshot.childSnapshot(forPath: "femail").value!) as String
    ViewController.dateTimeFormat =  String(describing: snapshot.childSnapshot(forPath: "fDateTime").value!) as String
    //.dateTimeFormat =  String(describing: snapshot.childSnapshot(forPath: "fLastCalander").value!) as String

    })
    } else {
    print ("newreg\(newRegister)")
    if  newRegister == "YES" {
    self.navigationController? .pushViewController(self.storyboard!.instantiateViewController(withIdentifier: "setting"), animated: false)
    }//end of Yes
    //no user connected
    }//end of else
 
    self.thinking2.hidesWhenStopped = true
    self.thinking2.startAnimating()
    
    btn1.setImage(leashImage, for: .normal)
    btn1.frame = CGRect(x: 0, y: 0, width: 60, height: 100)
    btn1.addTarget(self, action:#selector(recordsClicked), for: UIControlEvents.touchDown)
    records.customView = btn1
    btn2.setImage(meluna, for: .normal)
    btn2.frame = CGRect(x: 0, y: 0, width: 60, height: 100)
    btn2.addTarget(self, action:#selector(accountClicked), for: UIControlEvents.touchDown)
    account.customView = btn2
    btn3.setImage(billsIcon, for: .normal)
    btn3.frame = CGRect(x: 0, y: 0, width: 60, height: 100)
    btn3.addTarget(self, action:#selector(billsClicked), for: UIControlEvents.touchDown)
    bills.customView = btn3
        
    btnMenu.setImage (menu, for: .normal)
    btnMenu.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    btnMenu.addTarget(self, action: #selector(sideMenuMovement), for: .touchUpInside)
    menuItem.customView = btnMenu
     
    
    self.sideMenuConstarin.constant = -140
    self.blackView.isHidden = true
        
    let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
    blackView.addGestureRecognizer(tap)
    blackView.isUserInteractionEnabled = true
        

    }// end of viewdidload//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
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
        
    if ViewController.refresh == true ||  employerToS ==  "Add new dog" {
    chooseEmployer.sendActions(for: .touchUpInside)
    ViewController.refresh = false
    }
        
    }//end of view did appear

   
    //check subscription
    func checkSubs()
    {print(ViewController.checkSubOnce!,self.employerIdArray2.count)
    if ViewController.checkSubOnce == 1 && self.employerIdArray2.count > 3 || self.employerIdArray2.count > 2 && addDog == 1    { RebeloperStore.shared.verifyRenewablePurchase(.autoRenewableSubscription1) { (result, resultString) in
    print( result)
    if result == false { ViewController.checkSubOnce = 1;print ("no subscription"); self.alert83() //uncomment to make sure there is a subbscription check
    }
    else {ViewController.checkSubOnce = 2} //end of else  meaning there is subscription
    }//end of subscription result check
            
    }else {ViewController.checkSubOnce = 2}// alreadu checked checksubonce = 2 or count <2
    ViewController.checkSubOnce = 2//uncomment to enable check
    addDog = 0
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
    self.present((storyboard.instantiateViewController(withIdentifier: "loginScreen")), animated: true, completion: nil)
    } else {
    completion(true, nil)
    }
    }
    }
    
    //did become active procedure
    func applicationDidBecomeActive(notification: NSNotification) {
    thinking2.startAnimating()
    if account.isEnabled == true {
    preStartView()
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
    self.thinking2.stopAnimating()
    }
    }// end of func application did become
    
    //did stop active procedure
    func applicationDidBecomePassive(notification: NSNotification) {
    
    }// end of func application did stop
    
    //chose employer
    @IBAction func chooseEmployerBtn(_ sender: AnyObject) {
    thinking2.startAnimating()
    employerIDToS = ""
    employerToS = ""
    fetchEmployers()
    self.dbRefEmployee.removeAllObservers()
    postTimerView()
    self.animationImage.alpha = 1
    }//end of choose employerbtn
    
    func recordsClicked() {performSegue(withIdentifier: "employerforVC", sender: employerToS)}
    func importClicked() {performSegue(withIdentifier: "employerForCalander", sender: employerToS)}
    func importAllClicked() {performSegue(withIdentifier: "employerForAllCalander", sender: employerToS)}
    func accountClicked() {performSegue(withIdentifier: "employerForDogFile", sender: employerToS)}
    func  billsClicked() {performSegue(withIdentifier: "employerForBills", sender: employerToS)}
    func  profileClicked() {performSegue(withIdentifier: "setting", sender: employerToS)}
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "employerforRecord") {
    let secondView = segue.destination as? datePicker2
    secondView?.employerFromMain = employerToS
    secondView?.employerID = employerIDToS
    secondView?.employeeID = employeeIDToS
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
        
    else if (segue.identifier == "employerForAllBills"){
    let recordsView = segue.destination as? biller
    recordsView?.employerID = ""//employerIDToS
    recordsView?.employerFromMain = ""//employerToS
    recordsView?.employeeID = employeeIDToS
    }//end of else if
    
    else if (segue.identifier == "employerForTax"){
    let recordsView = segue.destination as? taxCalc
    recordsView?.employeeID = employeeIDToS
    }//end of else if
        
    else if (segue.identifier == "employerForCalander"){
    let recordsView = segue.destination as? calander
    recordsView?.employerIdFromMain = employerIDToS
    recordsView?.employerFromMain = employerToS
    //recordsView?.employeeID = employeeIDToS
    }//end of else if
    
    else if (segue.identifier == "employerForAllCalander"){
    let recordsView = segue.destination as? calander
    recordsView?.employerIdFromMain = ""//employerIDToS
    recordsView?.employerFromMain = ""//employerToS
    //recordsView?.employeeID = employeeIDToS
    }//end of else if

    else{let recordsView = segue.destination as? newVCTable
    recordsView?.employerFromMain = employerToS
    recordsView?.employerID = employerIDToS
    recordsView?.employeeID =  employeeIDToS
    }
    }//end of prepare
    

    func fetchEmployers() {
       
    self.employerIdArray.removeAll()
    self.employerIdArray2.removeAll()
    self.pickerData.removeAll()
    self.imageArray.removeAll()
    self.nameData.removeAll()
    self.activeData.removeAll()
        
    self.dbRefEmployee.child(self.employeeIDToS).child("myEmployers").observeSingleEvent(of: .value, with:{(snapshot) in
    self.listOfEmployers = snapshot.value as! [String : AnyObject] as! [String : Int]
    func sortFunc   (_ s1: (key: String, value: Int), _ s2: (key: String, value: Int)) -> Bool {
    return   s2.value > s1.value
    }
        
    self.employerIdArray = (self.listOfEmployers.sorted(by: sortFunc) as [AnyObject]  )

    for j in 0...(self.employerIdArray.count-1){
    let splitItem = self.employerIdArray[j] as! (String, Int)
    print (splitItem)

    let split2    = splitItem.0
    print (split2)

    if split2 != "New Dog" {
        self.employerIdArray2.append(split2 as AnyObject) } else {//do nothing
    }
    }//end of j loop
                

        if self.employerIdArray2.isEmpty == true {self.menuItem.isEnabled = false; self.thinking2.stopAnimating();  self.arrow.isHidden = false; self.arrowMove()

    } else {
    self.menuItem.isEnabled = true
    self.arrow.isHidden = true
    for iIndex in 0...(self.employerIdArray2.count-1){
    self.dbRefEmployer.child(self.employerIdArray2[iIndex] as! String).observeSingleEvent(of: .value, with:{ (snapshot) in
    self.employerItem = String(describing: snapshot.childSnapshot(forPath: "fEmployer").value!) as String!
    self.pickerData.append(self.employerItem  )
    
    
        

    self.dogItem = String(describing: snapshot.childSnapshot(forPath: "fName").value!) as String!
    self.nameData.append(self.dogItem  )

    self.activeItem = String(describing: snapshot.childSnapshot(forPath: "fActive").value!) as String!
    self.activeData.append(String(describing: self.activeItem) )
                        
    self.profileImageUrl = snapshot.childSnapshot(forPath: "fImageRef").value as! String!
    //  self.profileImageUrl = "https://firebasestorage.googleapis.com/v0/b/persession-45987.appspot.com/o/Myprofile.png?alt=media&token=263c8fdb-9cca-4256-9d3b-b794774bf4e1"
    self.imageArray.append(self.profileImageUrl)
                      
    if iIndex == (self.employerIdArray2.count-1) {
     
    self.thinking2.stopAnimating()

    self.employerList.isUserInteractionEnabled = true
    if self.employerIdArray2.count < 5 {self.employerListHeiget.priority = 1000 ;self.employerListBottom.priority = 750;self.employerListTop.constant = 60.0; self.employerListHeiget.constant = 265;self.employerListBottom.constant = 285} else {self.employerListBottom.priority = 750; self.employerListHeiget.priority = 1000;self.employerListTop.constant = 30.0;self.employerListHeiget.constant = 315;self.employerListBottom.constant = 285 }
        self.employerList.reloadData()
      self.checkSubs()
        
    self.employerList.isHidden = false
    self.dbRefEmployer.removeAllObservers()

    }

    self.dbRefEmployee.removeAllObservers()
    }){(error) in
    print(error.localizedDescription)} // end of dbrefemployer

    }//end of i loop
    }//end of idarray2 is empty

    }){(error) in
    print(error.localizedDescription)}//end of dbref employee

    }//end of fetch employer
    
    func preStartView() {
    self.addAmanualRecord.isHidden = false
    self.DateIn.isHidden = true
    self.workedFor.isHidden = true
    self.startBackground.isHidden = false
    self.importBackground.isHidden = false
    
        
    //self.account.isEnabled = true;
    self.chooseEmployer.isUserInteractionEnabled = true
    startBarButtonFadeOut()
    startBarButtonFadeIn()
    }//end of func

    func postTimerView() {
    DateIn.isHidden = true
    records.isEnabled = false
    account.isEnabled = false
    bills.isEnabled = false
    chooseEmployer.isHidden = true
    startBackground.isHidden = true
     self.importBackground.isHidden = true

    addAmanualRecord.isHidden = true
    animationImage.isHidden = true
    }//end of func
    
        func postRoundView() {
        //self.account.isEnabled = true
        self.animationImage.isHidden = false
        self.startBackground.isHidden = true
        self.importBackground.isHidden = true

        self.DateIn.isHidden = false;
        self.workedFor.isHidden = true
        self.addAmanualRecord.isHidden = true
        self.chooseEmployer.isUserInteractionEnabled = true
        self.navigationController!.popViewController(animated: true)
        self.animationImage.center.x -= self.view.bounds.width
        self.animationImage.isHidden = false
        self.animationImage.alpha = 1
       
        UIView.animate(withDuration: 2.0, animations:{
        self.animationImage.center.x += self.view.bounds.width
        })
        UIView.animate(withDuration: 2.0, delay :2.0 ,options:[],animations: {
        self.animationImage.alpha = 0
        self.startBackground.alpha = 0
        self.importBackground.alpha = 0
        self.addAmanualRecord.alpha = 0
        },completion:nil)
        
        UIView.animate(withDuration: 1.0, delay :4.0 ,options:[],animations: {
        self.startBackground.alpha = 1
        self.importBackground.alpha = 1
        self.addAmanualRecord.alpha = 1
            
        DispatchQueue.main.asyncAfter(deadline: .now()){
        UIView.animate(withDuration: 2.0, delay :0.0 ,options:[],animations: {
            self.textAdd.alpha = 1
        },completion:nil)
        UIView.animate(withDuration: 2.0, delay :2.0 ,options:[],animations: {
            self.textAdd.alpha = 0
        },completion:nil)
        }
            
        self.preStartView()
        self.DateIn.alpha = 0
            
        },completion:nil)
        }//end of func oost round view
    
    
    func noFB() {
    self.thinking2.stopAnimating()
   // self.alert30()
    }
    
    func startBarButtonFadeOut(){
    UIView.animate(withDuration: 0.1, animations: {
    self.startButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.85)
    self.importBtn.transform = CGAffineTransform(scaleX: 0.75, y: 0.85)

    })
    }
    
    func startBarButtonFadeIn(){
    UIView.animate(withDuration: 0.7,delay: 0.1, animations: {
    self.startButton.alpha = 1
    self.importBtn.alpha = 1
    self.startButton.transform = .identity// CGAffineTransformIdentity
    self.importBtn.transform = .identity// CGAffineTransformIdentity

    })
      /*
    UIView.animate(withDuration: 0.3, delay: 0.6 ,animations: {
    self.startButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    self.importBtn.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    })
    UIView.animate(withDuration: 0.3, delay: 0.9,animations: {
    self.startButton.transform = .identity
    self.importBtn.transform = .identity
    })
 */
    }
    
    func handleTap(sender: UITapGestureRecognizer? = nil) {
    sideMenuMovement()    }
    
    func sideMenuMovement(){
        print ("fff")
        
        if isSideMenuHidden {
            self.blackView.isHidden = false
            records.isEnabled = false
            bills.isEnabled = false
            account.isEnabled = false
            self.sideMenuConstarin.constant = 0
            UIView.animate(withDuration: 0.4, animations: {
               self.view.layoutIfNeeded()
            })
        }else{
            self.blackView.isHidden = true
            records.isEnabled = true
            bills.isEnabled = true
            account.isEnabled = true

            sideMenuConstarin.constant = -140
            UIView.animate(withDuration:0.4, animations: {
                self.view.layoutIfNeeded()
            })
        }
        isSideMenuHidden = !isSideMenuHidden
        }//end of issidemenuhidden
    
    func arrowMove(){
        UIView.animate(withDuration: 1.3, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.arrow.center.y += 13
        }, completion: nil)

        
        UIView.animate(withDuration: 1.3, delay: 0, options: [.repeat, .autoreverse], animations: {
        self.arrow.center.y -= 20
        }, completion: nil)

        }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////alerts
    func  alert83(){
    let alertController83 = UIAlertController(title: ("Subscription alert") , message: " Adding more than two accounts requires subscription and we couldn't find one. please subscribe with free trial or log again if you have one.", preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.present((storyboard.instantiateViewController(withIdentifier: "subScreen")), animated: true, completion: nil)
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
    }//end of alert83

    func alert30(){
    let alertController30 = UIAlertController(title: ("No connection") , message: "Currently there is no connection with database. Please try again.", preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
    }
    alertController30.addAction(OKAction)
    self.present(alertController30, animated: true, completion: nil)
    }
    
    func alert50(){
    let alertController50 = UIAlertController(title: ("Internet Connection") , message: " There is no internet - Check communication avilability.", preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
    }
    alertController50.addAction(OKAction)
    self.present(alertController50, animated: true, completion: nil)
    }
    
}/////////////end!!!!!////////////////////////////////////////////////////////////////////////////////////////////////

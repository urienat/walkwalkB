//  Created by אורי עינת on 1.9.2016.
//  Copyright © 2016 אורי עינת. All rights reserved.
//

        import UIKit
        import FirebaseDatabase
        import FirebaseAuth
        import Google
        import GoogleSignIn
        import GoogleAPIClientForREST

        class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating{

        var window: UIWindow?

        let dbRef = FIRDatabase.database().reference().child("fRecords")
        let dbRefEmployer = FIRDatabase.database().reference().child("fEmployers")
        let dbRefEmployee = FIRDatabase.database().reference().child("fEmployees")
            
        let font = UIFont.systemFont(ofSize: 17.0)
        var blueColor = UIColor(red :22/255.0, green: 131/255.0, blue: 248/255.0, alpha: 1.0)
        var grayColor = UIColor(red :235/255.0, green: 235/255.0, blue: 235/255.0, alpha: 1)
        var systemBlue = UIColor(red :0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1.0)
            
        let mydateFormat2 = DateFormatter()
        let mydateFormat5 = DateFormatter()
        let mydateFormat7 = DateFormatter()

        let roundImageBig = UIImage(named: "roundBig")
        let pencilImage = UIImage(named: "pencilImage")
        var ImageFromFirebase : UIImage?
        var menu = UIImage(named: "menu")
        var home = UIImage(named: "home")?.withRenderingMode(.alwaysTemplate)
        var backArrow = UIImage(named: "backArrow")
        var file = UIImage(named:"file")?.withRenderingMode(.alwaysTemplate)
        var sessions = UIImage(named:"sessions")?.withRenderingMode(.alwaysTemplate)
        var billsIcon = UIImage(named:"billsIcon")?.withRenderingMode(.alwaysTemplate)
        let importIcon = UIImage(named:"import")?.withRenderingMode(.alwaysTemplate)
        var perSessionImage = UIImage(named:"perSessionImage")?.withRenderingMode(.alwaysTemplate)

            
        static var fixedCurrency:String!
        static var fixedName:String!
        static var fixedLastName:String!
        static var fixedemail:String!
        static var dateTimeFormat:String!
        static var refresh:Bool? = false
        static var sessionPusher:Bool?
        static var billsPusher:Bool?
        static var profilePusher: Bool?
        static var professionControl: String?
        static var calanderOption: String?
        static var taxOption : String?
        static var taxCalc: String?
        static var taxation: String?

        struct employerStruct{
        var accountName : String
        var employerRef : String
        var activeAccount : Bool
        var lastDocAccount :String
        var accountImageUrl : String
        init(accountName:String, employerRef:String, activeAccount:Bool,lastDocAccount:String,accountImageUrl:String) {
        self.accountName = accountName
        self.employerRef = employerRef
        self.activeAccount = activeAccount
        self.lastDocAccount = lastDocAccount
        self.accountImageUrl = accountImageUrl
        }
        }//end of struct
            
        var employerForList : [employerStruct] = []
        var filteredEmployerForList : [employerStruct] = []
        var profileImageUrl = ""
        var sessionModeSegue:Bool? = true
        var isSideMenuHidden = true
        var employerItem = ""
        var dogItem = ""
        var lastDocumentItem = ""
        var employerIdRef = ""
        var methood = "Normal"
        var pickerlabel =  UILabel.self
        var RateUpdate = 0.0
        var newRegister = ""
        var alive:Bool?
        var addDog: Int?
        var tableRowHeight:Int?
        let searchController =  UISearchController.init(searchResultsController: nil)
        var employerIdArray: [AnyObject] = []
        var employerIdArray2: [AnyObject] = []
        var listOfEmployers = [String:Int]()
        var dIn = String (describing: Date())

        //variable for Segue
        var employerToS = ""
        var employerIDToS = ""
        var employeeIDToS = ""

        @IBOutlet weak var menuItem: UIBarButtonItem!
        @IBOutlet weak var addAccount: UIBarButtonItem!
        @IBAction func addAccount(_ sender: Any) {
        print ("add")
        arrow.isHidden = true
        employerToS = "Add Account"
        // if employerIdArray.count > 2 {checkSubs()} else {
        accountClicked()
        //}
        }//end of addaccount
        @IBOutlet weak var special: UIButton!
        @IBAction func special(_ sender: Any) {
        sessionModeSegue = false
        performSegue(withIdentifier: "employerforRecord", sender: employerToS)
        sessionModeSegue = true
        }//end of special
        @IBOutlet weak var thinking2: UIActivityIndicatorView!
        @IBOutlet weak var employerList: UITableView!
        @IBOutlet weak var employerListTop: NSLayoutConstraint!
        @IBOutlet weak var emoloyerListBottom: NSLayoutConstraint!
        @IBOutlet weak var employerListHeiget: NSLayoutConstraint!
        @IBOutlet weak var employerListBottom: NSLayoutConstraint!
        @IBOutlet weak var star: UIImageView!
        @IBOutlet weak var homeTitle: UINavigationItem!
        @IBOutlet weak var nav2: UINavigationBar!
        @IBOutlet weak var startButton: UIButton!
        @IBOutlet weak var DateIn: UILabel!
        @IBOutlet weak var workedFor: UILabel!
        @IBOutlet weak var addAmanualRecord: UIView!
        @IBOutlet weak var records: UIBarButtonItem!
        @IBOutlet weak var bills: UIBarButtonItem!
        @IBOutlet weak var importSpesific: UIBarButtonItem!
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
        if ViewController.calanderOption! == "None" {alert32()} else {
        importClicked()}
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
        if ViewController.taxOption == "No" {self.alert47()} else {
        performSegue(withIdentifier: "employerForTax", sender: employerToS)}
        }
        @IBAction func reports(_ sender: Any) {
        sideMenuMovement()
        reportsClicked()
        }
        @IBAction func importAllBtn(_ sender: Any) {
        sideMenuMovement()
        //print (ViewController.calanderOption!)
        if ViewController.calanderOption! == "None" {alert32()} else {
        importAllClicked()}
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
        print (LoginFile.logoutchosen)
        try! FIRAuth.auth()?.signOut()
        self.present((storyboard?.instantiateViewController(withIdentifier: "loginScreen"))!, animated: true, completion: nil)
        }

        @IBOutlet weak var toolBar: UIToolbar!
        let btn1 = UIButton(type: .custom)
        let btn2 = UIButton(type: .custom)
        let btn3 = UIButton(type: .custom)
        let btn4 = UIButton(type: .custom)
        let btnMenu = UIButton(type: .custom)


        //start timer action
        @IBAction func Start(_ sender: AnyObject) {
        textAdd.text = "Session added: \r\n\( mydateFormat7.string(from: Date()))"
        dIn =  mydateFormat5.string(from: Date()) //brings the a date as a string
    self.dbRefEmployee.child(self.employeeIDToS).child("myEmployers").updateChildValues([(self.employerIDToS):Int((self.mydateFormat5.date(from: mydateFormat5.string(from: Date()))?.timeIntervalSince1970)!)])

        let record = ["fIn" : dIn,"fIndication3": "↺", "fEmployer": String (describing : employerToS),"fEmployeeRef": employeeIDToS,"fEmployerRef": employerIDToS,"fStatus" : "Approved","fSessionCreated":self.mydateFormat5.string(from: Date()) ]
        let fInRef = dbRef.childByAutoId()
        fInRef.setValue(record)

        self.dbRefEmployee.child(self.employeeIDToS).child("fEmployeeRecords").updateChildValues([fInRef.key:Int(-(self.mydateFormat5.date(from: self.dIn)?.timeIntervalSince1970)!)])
        self.dbRefEmployer.child(self.employerIDToS).child("fEmployerRecords").updateChildValues([fInRef.key:Int(-(self.mydateFormat5.date(from: self.dIn)?.timeIntervalSince1970)!)])

        self.recordsClicked()
        }//end of start

        override func viewDidLoad() {  //view did load/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        super.viewDidLoad()

        checkUserAgainstDatabase { (alive, error3) in}    //check if user not deleted


        employerList.dataSource = self
        employerList.delegate = self
        ViewController.sessionPusher = false
        ViewController.billsPusher = false
        ViewController.profilePusher = false

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.barTintColor = grayColor

        DateIn.text = ""
        employerList.backgroundColor = UIColor.clear

        let currentUser = FIRAuth.auth()?.currentUser
        if currentUser != nil {
        self.employeeIDToS = (currentUser!.uid)

        self.dbRefEmployee.queryOrderedByKey().queryEqual(toValue: currentUser?.uid).observeSingleEvent(of: .childAdded, with: { (snapshot) in
        ViewController.fixedCurrency = String(describing: snapshot.childSnapshot(forPath: "fCurrency").value!) as String
        ViewController.fixedName =  String(describing: snapshot.childSnapshot(forPath: "fName").value!) as String
        ViewController.fixedLastName =  String(describing: snapshot.childSnapshot(forPath: "fLastName").value!) as String
        ViewController.fixedemail =  String(describing: snapshot.childSnapshot(forPath: "femail").value!) as String
        ViewController.dateTimeFormat =  String(describing: snapshot.childSnapshot(forPath: "fDateTime").value!) as String
        ViewController.calanderOption =  String(describing: snapshot.childSnapshot(forPath: "fCalander").value!) as String
        ViewController.taxOption = String(describing: snapshot.childSnapshot(forPath: "fSwitcher").value!) as String
        ViewController.taxCalc = String(describing: snapshot.childSnapshot(forPath: "fTaxCalc").value!) as String
        ViewController.taxation = String(describing: snapshot.childSnapshot(forPath: "fTaxPrecentage").value!) as String
        ViewController.professionControl =  String(describing: snapshot.childSnapshot(forPath: "fProfessionControl").value!) as String

        let imageView = UIImageView(image: self.home)
        imageView.contentMode = .scaleAspectFit // set imageview's content mode
        self.homeTitle.titleView = imageView
        // if  ViewController.professionControl! == "Tutor" { self.homeTitle.title = "Students"} else {self.homeTitle.title = "Accounts"}
        }
        , withCancel: { (Error) in
        self.alert30()
        print("error from FB")}
        )
        self.fetchEmployers()
        } else {
        print ("newreg\(newRegister)")
        if  newRegister == "YES" {
        self.navigationController? .pushViewController(self.storyboard!.instantiateViewController(withIdentifier: "setting"), animated: false)
        }//end of Yes
        //no user connected
        }//end of else

        self.thinking2.hidesWhenStopped = true
        self.thinking2.startAnimating()

        btn1.setImage(sessions, for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 60, height: 100)
        btn1.addTarget(self, action:#selector(recordsClicked), for: UIControlEvents.touchDown)
        records.customView = btn1
        btn2.setImage(file, for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 60, height: 100)
        btn2.addTarget(self, action:#selector(accountClicked), for: UIControlEvents.touchDown)
        account.customView = btn2
        btn3.setImage(billsIcon, for: .normal)
        btn3.frame = CGRect(x: 0, y: 0, width: 60, height: 100)
        btn3.addTarget(self, action:#selector(billsClicked), for: UIControlEvents.touchDown)
        bills.customView = btn3
        btn4.setImage(importIcon, for: .normal)
        btn4.frame = CGRect(x: 0, y: 0, width: 60, height: 100)
        btn4.addTarget(self, action:#selector(importClicked), for: UIControlEvents.touchDown)
        importSpesific.customView = btn4

        btnMenu.setImage (menu, for: .normal)
        btnMenu.frame = CGRect(x: 0, y: 0, width: 20, height: 60)
        btnMenu.addTarget(self, action: #selector(sideMenuMovement), for: .touchUpInside)
        menuItem.customView = btnMenu

        records.isEnabled = false
        bills.isEnabled = false
        account.isEnabled = false
        importSpesific.isEnabled = false

        self.sideMenuConstarin.constant = -140
        self.blackView.isHidden = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        blackView.addGestureRecognizer(tap)
        blackView.isUserInteractionEnabled = true

        //application did become active
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.applicationDidBecomeActive(notification:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.applicationDidBecomeActive(notification:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

        self.employerList.separatorColor = blueColor

        //formating the date
        mydateFormat2.dateFormat = DateFormatter.dateFormat(fromTemplate:  " HH:mm", options: 0, locale: nil)!
        mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)",options: 0, locale: nil)!
        mydateFormat7.dateFormat = DateFormatter.dateFormat(fromTemplate: " EEE-dd MMM, (HH:mm)",options: 0, locale: nil)!

        connectivityCheck()

        }// end of viewdidload//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        override func viewDidAppear(_ animated: Bool) {
        if ViewController.refresh == true ||  employerToS ==  "Add Account" {
        chooseEmployer.sendActions(for: .touchUpInside)
        ViewController.refresh = false
        }

        if ViewController.sessionPusher == true {ViewController.sessionPusher = false;
        self.recordsClicked()}
        if ViewController.billsPusher == true {ViewController.billsPusher = false;
        biller.rowMemory = 0
        self.billsClicked()}
        if ViewController.profilePusher == true {ViewController.profilePusher = false;
        self.accountClicked()}
        }//end of view did appear

        //check subscription
        func checkSubs(){
        /*
        RebeloperStore.shared.verifyRenewablePurchase(.autoRenewableSubscription1) { (result, resultString) in
        print( result)
        if result == false {print ("no subscription"); self.alert83()
        }
        else {
        //do nothing
        } //end of else  meaning there is subscription
        }//end of subscription result check
        */
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

                @IBAction func chooseEmployerBtn(_ sender: AnyObject) {
        noAccount()
        }//end of choose employerbtn

        func recordsClicked() {performSegue(withIdentifier: "employerforVC", sender: employerToS)}
        func importClicked() {performSegue(withIdentifier: "employerForCalander", sender: employerToS)}
        func importAllClicked() {performSegue(withIdentifier: "employerForAllCalander", sender: employerToS)}
        func accountClicked() {performSegue(withIdentifier: "employerForDogFile", sender: employerToS)}
        func billsClicked() {performSegue(withIdentifier: "employerForBills", sender: employerToS)}
        func profileClicked() {performSegue(withIdentifier: "setting", sender: employerToS)}
        func reportsClicked(){performSegue(withIdentifier: "reports", sender: employerToS)}
       
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "employerforRecord") {
        let secondView = segue.destination as? datePicker2
        secondView?.employerFromMain = employerToS
        secondView?.employerID = employerIDToS
        secondView?.employeeID = employeeIDToS
        if self.sessionModeSegue! != false {sessionModeSegue = true}
        secondView?.sessionMode = sessionModeSegue
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
        else if (segue.identifier == "reports"){
        let recordsView = segue.destination as? report
        recordsView?.employeeID = employeeIDToS
        }//end of else if
        else if (segue.identifier == "employerForCalander"){
        let recordsView = segue.destination as? calander
        recordsView?.employerIdFromMain = employerIDToS
        recordsView?.employerFromMain = employerToS
        recordsView?.employeeId = employeeIDToS
        }//end of else if
        else if (segue.identifier == "employerForAllCalander"){
        let recordsView = segue.destination as? calander
        recordsView?.employerIdFromMain = ""//employerIDToS
        recordsView?.employerFromMain = ""//employerToS
        recordsView?.employeeId = employeeIDToS
        }//end of else if
        else{let recordsView = segue.destination as? newVCTable
        recordsView?.employerFromMain = employerToS
        recordsView?.employerID = employerIDToS
        recordsView?.employeeID =  employeeIDToS
        }
        }//end of prepare

        func noAccount(){
        self.btnMenu.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
        self.btnMenu.setImage (self.menu, for: .normal)
        self.btnMenu.isHidden = false
        }

        btnMenu.removeTarget(self, action:#selector(noAccount), for: .touchUpInside)
        btnMenu.addTarget(self, action: #selector(sideMenuMovement), for: .touchUpInside)
        //if  ViewController.professionControl! == "Tutor" { homeTitle.title = "Students"} else {homeTitle.title = "Accounts"}
        let imageView = UIImageView(image: self.home)
        imageView.contentMode = .scaleAspectFit // set imageview's content mode
        self.navigationItem.titleView = imageView
        toolBar.isHidden = true
        addAccount.isEnabled = true
        thinking2.startAnimating()
        employerIDToS = ""
        employerToS = ""
        fetchEmployers()
        postTimerView()
        self.animationImage.alpha = 1
        }

        func preStartView() {
        self.addAmanualRecord.isHidden = false
        self.DateIn.isHidden = true
        self.workedFor.isHidden = true
        self.startBackground.isHidden = false
        self.importBackground.isHidden = true//false
        self.special.isHidden = false
        self.star.isHidden = false
        self.chooseEmployer.isUserInteractionEnabled = true
        }//end of func

        func postTimerView() {
        DateIn.isHidden = true
        records.isEnabled = false
        account.isEnabled = false
        bills.isEnabled = false
        importSpesific.isEnabled = false
        chooseEmployer.isHidden = true
        startBackground.isHidden = true
        self.special.isHidden = true
        self.star.isHidden = true
        self.importBackground.isHidden = true
        addAmanualRecord.isHidden = true
        animationImage.isHidden = true
        }//end of func

        

        func handleTap(sender: UITapGestureRecognizer? = nil) {
        sideMenuMovement()    }

        func sideMenuMovement(){
        if isSideMenuHidden {
        if #available(iOS 11.0, *) {
        //searchController.dismiss(animated: false, completion: nil)
        searchController.searchBar.text = ""
        self.navigationItem.searchController = nil
        } else {
        self.searchController.isActive = false
        }
        self.blackView.isHidden = false
        //self.toolBar.isHidden = true
        self.sideMenuConstarin.constant = 0
        UIView.animate(withDuration: 0.4, animations: {
        self.view.layoutIfNeeded()
        })
        }else{
        if self.employerForList.count > 8 {
        if #available(iOS 11.0, *) {
        self.navigationItem.searchController = self.searchController
        } else {
        self.employerList.tableHeaderView = self.searchController.searchBar
        }
        }//end of >4

        sideMenuConstarin.constant = -140
        UIView.animate(withDuration:0.4, animations: {
        self.view.layoutIfNeeded()
        })
        self.blackView.isHidden = true
        // self.toolBar.isHidden = false
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

        func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text! == ""{
        filteredEmployerForList = employerForList
        }else{
        filteredEmployerForList =
        employerForList.filter({ ($0.accountName.lowercased().contains(searchController.searchBar.text!.lowercased())) })
        }
        self.employerList.reloadData()
        }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////alerts
        func  alert83(){
        let alertController83 = UIAlertController(title: ("Subscription alert") , message: " Adding more accounts requires subscription and we couldn't find one. please subscribe with free trial or log again if you have one.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.present((storyboard.instantiateViewController(withIdentifier: "subScreen")), animated: true, completion: nil)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.present((storyboard.instantiateViewController(withIdentifier: "subScreen")), animated: true, completion: nil)
        }
        alertController83.addAction(OKAction)
        alertController83.addAction(cancelAction)
        self.present(alertController83, animated: true, completion: nil)
        }//end of alert83

        func alert670(){
        let alertController67 = UIAlertController(title: ("Not Active alert") , message: "This account isn't active. You can only handle past invoices or you can re-activate the account at 'Profile'.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        }
        alertController67.addAction(OKAction)
        self.present(alertController67, animated: true, completion: nil)
        }

        func alert32(){
        let alertController32 = UIAlertController(title: ("Define calander") , message: " in your 'Setting' no calander is defined for sessions' import. Define one? ", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Sure", style: .default) { (UIAlertAction) in
        self.profileClicked()
        }
        let cancelAction = UIAlertAction(title: "Not now", style: .cancel) { (UIAlertAction) in
        }
        alertController32.addAction(OKAction)
        alertController32.addAction(cancelAction)
        self.present(alertController32, animated: true, completion: nil)
        }

        func alert47(){
        let alertController47 = UIAlertController(title: ("Tax") , message: " Tax defintions are missing in your 'Setting'. Define it? ", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        self.profileClicked()
        }

        let cancelAction = UIAlertAction(title: "Not now", style: .cancel) { (UIAlertAction) in
        }
        alertController47.addAction(OKAction)
        alertController47.addAction(cancelAction)
        self.present(alertController47, animated: true, completion: nil)
        }

}/////////////end!!!!!////////////////////////////////////////////////////////////////////////////////////////////////

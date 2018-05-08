//
//  LoginFile.swift
//  Created by אורי עינת on 27.10.2016.

import UIKit
import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit
import FacebookCore
import Google
import GoogleSignIn
import GoogleAPIClientForREST

class LoginFile: UIViewController, UITextFieldDelegate,FBSDKLoginButtonDelegate,GIDSignInUIDelegate,GIDSignInDelegate{

    var blueColor = UIColor(red :22/255.0, green: 131/255.0, blue: 248/255.0, alpha: 1.0)

    let dbRefEmployees = FIRDatabase.database().reference().child("fEmployees")
    let mydateFormat5 = DateFormatter()
    let Vimage = UIImage(named:"vNaked")
    let nonVimage = UIImage(named: "blank")
    var connectCheck = 0
    
    //facebook & google
    let loginButton =  FBSDKLoginButton()// facebooklogin variables
    let loginButton2 =  GIDSignInButton()    // Googlelogin variables
    static var provider = "normal"
    var fbNname = ""
    var fbLastName = ""
    var fbEmail = ""
    static var userFromGoole : GIDGoogleUser?
    
    // Define identifier
    
  
    static var employeeRef2 = "" {
    didSet {    //called when employeeref2 changed
    print("changed")
    //NotificationCenter.default.addObserver(self, selector: #selector(inFireBase), name: NSNotification.Name(rawValue: "SomeNotification"), object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "SomeNotification"), object: nil)

    }
    }
    
    
    
    
        var pickedImage:UIImage?
        let picture = UIImage(named: "perSessionImage")
    
        //facebook functions
        func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print ("logout from facebook")
        LoginFile.provider = "normal"
        }

        func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        thinking.startAnimating()
        if error != nil { print ("facebook login error:\(error)");thinking.stopAnimating()
        return
        } else { print ("facebook login succesfuly")
        self.ipusKeeper()

        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields" : "id, name, email, last_name, first_name"]).start{
        (connection,result,err) in
        if error != nil {print ("facebook error in request",err as Any)
        return}

        if let result = result as? [String:Any]{
        self.fbEmail = (result["email"] as! String)
        self.fbNname = (result["first_name"] as! String)
        self.fbLastName = (result["last_name"] as! String)
        }//end of if let

        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else {return}
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        FIRAuth.auth()?.signIn(with: credentials , completion: { (user, error) in
        if error != nil {print(" error with Fb FB connection", error as Any); return}
        print ("suucesfully loggoed in with facebook", user!)
        self.employeeRefUpdate = user?.uid

        DispatchQueue.main.asyncAfter(deadline: .now() ) {
        self.dbRefEmployees.child(self.employeeRefUpdate!).observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.hasChild("fCounter"){
        print("exist")
        self.thinking.stopAnimating()
        LoginFile.provider = "facebook"
        self.doSegue()
        }else{
        print("doesn't exist")
        LoginFile.provider = "facebook"
        self.accounCreation()
        self.thinking.stopAnimating()
        self.doSegue()
        }//end of else
        } , withCancel: { (Error) in
            self.alert30()
            print("error from FB")})
        }//end of dispatch
        })//end of firauth
        }//end fbsdkrequest
        }//end of else
        }//end of func login button

        var textForError:String?
        var employeeRefUpdate:String?

    static var logoutchosen = false
    static var userForCreate = ""
    static var passwordForCreate = ""
    var cu = Locale.current.currencySymbol

    @IBOutlet weak var loginBarImage: UIImageView!
    //regulaer login
    @IBOutlet weak var dog: UIImageView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    //Keeper variables
    let keeper = UserDefaults.standard
    var checkBox : Bool?
    var rememberMe:Int?
    var userEmail:String?
    var userPassword:String! = nil
    var nofirstTimer:Bool?


    @IBOutlet weak var check: UIButton! // section for rememberme check
    @IBAction func checkBox(_ sender: Any) {
    if checkBox! == true {check.setImage(Vimage, for: .normal)
    checkBox = false
    keeper.set(1, forKey: "remember")
    rememberMe = 1
    //UserDefaults.standard.synchronize()
    } else  {
    self.ipusKeeper()
    //UserDefaults.standard.synchronize()
    }//end of else
    }//end of action checkbox
    
   
    
    @IBAction func forgot(_ sender: Any) {  //section for forgot or change password
    userEmail = email.text
    FIRAuth.auth()?.sendPasswordReset(withEmail: userEmail!) { (error) in
    if error != nil { print ("erorrr!!!!")
    if self.email.text == "" {self.textForError = "Sorry. Missing email - please fill email."} else {self.textForError = "Sorry. This email is not registered as valid in our records"};self.alert2()
    } else {
    self.alert1()}
    }
    }//end of forgot action
    
    
    @IBOutlet weak var thinking: UIActivityIndicatorView!
    @IBOutlet weak var signIn: UIButton! // section for signin
    @IBAction func signin(_ sender: Any) {
    signIn.isEnabled = false
    signIn.alpha = 0.5
    LoginFile.provider = "normal"
    self.keeper.set(self.email.text!, forKey: "userKept")
    self.keeper.set(self.password.text!, forKey: "passwordKept")
    signInProcess()
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
    self.signIn.isEnabled = true
    self.signIn.alpha = 1
    }
    }//end of sigin
    
    @IBOutlet weak var forgot: UIButton!
    @IBOutlet weak var create: UIButton! //section for create
    @IBAction func createAccount(_ sender: AnyObject) {
    print ("back in town")
    try! FIRAuth.auth()?.signOut() // why signout?
    self.performSegue(withIdentifier: "create", sender: Any?.self)
    }//end of create action
    
    @IBOutlet weak var welcomeScreen: UIView!
    @IBOutlet weak var letsGo: UIButton!
    @IBAction func letsGo(_ sender: Any) {
        keeper.set(true, forKey: "nofirstTimer")
        welcomeScreen.isHidden = true
    }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    override func viewDidLoad() {
        print ("rrrr",connectCheck)
        
        if connectCheck == 0{
        //connectivityCheck()
        connectCheck = 1
        }
        
        
        
        dog.clipsToBounds = true
        dog.layer.cornerRadius = 50
        mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)",options: 0, locale: nil)!
        NotificationCenter.default.addObserver(self, selector: #selector(inFireBase), name: NSNotification.Name(rawValue: "SomeNotification"), object: nil)
        //delgate to hide keyboard
        self.email.delegate = self
        self.password.delegate = self
        
        logoutGeneral()
        
        //set the buttons
        signIn.layer.cornerRadius =  5
        signIn.layoutIfNeeded()

         GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
       ///GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeCalendar]

        
       
        
        view.addSubview(loginButton2)
        loginButton2.frame = CGRect(x: view.frame.width/2-104, y: 50, width: 208, height: 45)
        
        
        view.addSubview(loginButton)
        loginButton.frame = CGRect(x: view.frame.width/2-100, y: 107, width: 200, height: 45)
        loginButton.delegate = self 
        loginButton.readPermissions = ["email","public_profile"]
        print("khkjhj", FBSDKAccessToken.current())
        
        //quick facebook
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
        if FBSDKAccessToken.current() != nil {
                LoginFile.provider = "facebook"
                print ("ggg",LoginFile.provider)
                self.doSegue()
            }//end of if
        }//end of dispatch
        
        
        if keeper.integer(forKey: "remember") != 1 {rememberMe = 0 } else { rememberMe = keeper.integer(forKey: "remember")}
        if rememberMe == 1 {
            LoginFile.provider = "normal"
            check.setImage(Vimage, for: .normal)
            checkBox = false
            let savedUser = keeper.string(forKey: "userKept")
            let savedPassword = keeper.string(forKey: "passwordKept")
            //if savedUser == nil || savedUser == "" {ipusKeeper()
            // }//end of if
            email.text = savedUser
            password.text = savedPassword
            print ("sss",LoginFile.logoutchosen)
            if LoginFile.logoutchosen == true {
                //do nothing
            } else  {signInProcess() }
        } else{check.setImage(nonVimage, for: .normal)
            checkBox = true}
        print("ttt",FBSDKAccessToken.current())
        
        if FBSDKAccessToken.current() == nil {
            
            print ("kkk",GIDSignIn.sharedInstance().currentUser)
            
            if GIDSignIn.sharedInstance().currentUser != nil  {
                thinking.startAnimating()
                print ("aas",GIDSignIn.sharedInstance().currentUser)
               inFireBase()
            } else {
                print ("DSDS",GIDSignIn.sharedInstance().currentUser)
            }
        }// end of else if
       
        
        
        if LoginFile.userForCreate != ""{ email.text = LoginFile.userForCreate; password.text = LoginFile.passwordForCreate; LoginFile.userForCreate = "";LoginFile.passwordForCreate = ""} else {LoginFile.userForCreate = "";LoginFile.passwordForCreate = ""}
        
       
      
        
        thinking.hidesWhenStopped = true
        
        check.layer.borderWidth = 0.5;
        check.layer.borderColor =  blueColor.cgColor
        check.layer.cornerRadius =  10
        
        loginBarImage.clipsToBounds = true
        loginBarImage.layer.cornerRadius = 15
        
        self.view.bringSubview(toFront: welcomeScreen)
        welcomeScreen.layer.cornerRadius = 15
        welcomeScreen.layer.borderWidth = 0.5
        welcomeScreen.layer.borderColor = blueColor.cgColor
        welcomeScreen.layoutIfNeeded()
        letsGo.layer.borderWidth = 0.5
        letsGo.layer.borderColor = blueColor.cgColor
        letsGo.layer.cornerRadius =  15//CGFloat(25)
        letsGo.layoutIfNeeded()
        print (keeper.bool(forKey: "nofirstTimer"))
        if keeper.bool(forKey: "nofirstTimer") == false { welcomeScreen.isHidden = false}

        } ///end of view did load//////////////////////////////////////////////////////////////////////////////////////////////////////
   
        //keyboard hide
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        email.resignFirstResponder()
        password.resignFirstResponder()
        return true}
    
    
        func signInProcess() {
        userEmail = email.text!
        userPassword = password.text!
        if userEmail == ""  {self.textForError = ("Missing mail. Please fill in" )
        alert2()
        }//end of if useremail
        
        FIRAuth.auth()?.signIn(withEmail: userEmail!, password: userPassword, completion: { (user, error) in
            
        if error != nil
        {print ("something went wrong")
        print("111",error!)
        if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
        switch errCode {
        case .errorCodeInvalidEmail:
        self.textForError = ("This is invalid mail.Please correct. or set a 'New Account' if its your first time with us." )
        case .errorCodeUserNotFound:
        self.textForError = ("We could not find you in our records. Please check that you used this mail as your account user name or set a 'New Account' if its your first time with us." )
        case .errorCodeNetworkError:
        self.textForError = ("There is no connection. Please try later." )
        case .errorCodeWrongPassword:
        if self.password.text != "" {
        self.textForError = ("This is a wrong Password. Please try again or use 'Forgot password'." ) } else {self.textForError = ("Missing Password. Please try again or use 'Forgot password'." ) }
        case .errorCodeUserDisabled:
        self.textForError = ("This user is disabled. Please check with our WalkWalk support at wwww.homeployer.com." )
        default:
        self.textForError = ("There is a login error . Pleasr try again" )
        print("Create User Error: \(String(describing: error))")
        }
        self.alert2()
        }//end of if let
        }//end of if error
        
        else {
        print("rememberMe:\(self.rememberMe!)")

        if self.rememberMe == 1{
        self.keeper.set(self.email.text!, forKey: "userKept")
        self.keeper.set(self.password.text!, forKey: "passwordKept")
        self.keeper.set(1, forKey: "remember")
        print ("uid\(String(describing: user?.uid))")
        self.doSegue()

        }//end of if
        else {
            self.doSegue()
            self.ipusKeeper()}//end of else
        
        }//end of else
        })//end of auth
        }//end of func
    
        func ipusKeeper(){
        self.keeper.set("", forKey: "userKept")
        self.keeper.set("", forKey: "passwordKept")
        self.keeper.set(0, forKey: "remember")
        email.text = nil
        password.text = nil
        rememberMe = 0
        check.setImage(nonVimage, for: .normal)
        self.checkBox = true
        rememberMe = 0
        }
    
        //google signin
        func inFireBase(){
        print ("in fire base starts")
            
        ipusKeeper()
        LoginFile.provider = "Google"
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
        self.dbRefEmployees.child(LoginFile.employeeRef2).observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.hasChild("fCounter"){
        print("exist")
        self.doSegue()
        }else{
        print("doesn't exist")
        if LoginFile.userFromGoole?.profile.givenName == nil {self.fbNname = ""}else { self.fbNname = (LoginFile.userFromGoole?.profile.givenName!)!}
        if LoginFile.userFromGoole?.profile.familyName == nil {self.fbLastName = ""} else { self.fbLastName = (LoginFile.userFromGoole?.profile.familyName!)! }
        if LoginFile.userFromGoole?.profile.email == nil {self.fbEmail = ""} else { self.fbEmail = (LoginFile.userFromGoole?.profile.email!)!}
        self.accounCreation()
        self.doSegue()
        }//end of else
        } , withCancel: { (Error) in
            self.alert30()
            print("error from FB")})
        }//end of dispatch
        }//end of infirebase

    
        func accounCreation() {
        if let user = FIRAuth.auth()?.currentUser {
        self.employeeRefUpdate =  user.uid}
        self.dbRefEmployees.child(employeeRefUpdate!).child("myEmployers").setValue(["New Dog":0])//add employer to my employers of employee
            self.dbRefEmployees.child((employeeRefUpdate)!).updateChildValues([ "fImageRef":"","fCounter": "1000","fCreated"  : self.mydateFormat5.string(from: Date()),"fName" : fbNname, "fLastName": fbLastName, "femail" : fbEmail, "fCurrency": Locale.current.currencySymbol!, "fProgram":"0","fTaxPrecentage":"0" ,"fTaxId":"",  "fSwitcher": "No","fTaxCalc" : "Over", "fDateTime": "DateTime","fLogin":LoginFile.provider,"fLastCalander":"New","fAddress":"","fPaypal" : "", "fBillinfo" :"","fCalander" : "None","fProfessionControl":"Dog walker","fTaxName":""])

        //storage of pictures //in cache under employeeID
        MyImageCache.sharedCache.setObject(self.pickedImage as AnyObject, forKey: self.employeeRefUpdate as AnyObject)

        //in firebase under url
        let dbStorageRef = FIRStorage.storage().reference().child("employeeImages").child(self.employeeRefUpdate!)
        if let uploadTask = UIImageJPEGRepresentation(self.picture!, CGFloat(0.1)){
        dbStorageRef.put(uploadTask, metadata: nil, completion: { (metadata, error) in
        if error != nil {
        print ("111",error as Any)
        return
        }
        self.dbRefEmployees.child(self.employeeRefUpdate!).updateChildValues(["fImageRef":(metadata?.downloadURL()?.absoluteString)! as Any ])
        }) //end of dbref
        }//end of uploadtask
        }//end of account creation

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let middle =  segue.destination as! UINavigationController
        let third = middle.topViewController as! ViewController
        print ("prepare")
        if (segue.identifier == "create"){
        setting.newEmployee = "YES"
        third.newRegister = "YES"}
            
        else if (segue.identifier == "signIn2") {third.newRegister = "NO"}
        else {//do nothing}
        print ("nothing")}
        }// end of prepare
    
        func doSegue(){
            if LoginFile.provider == "facebook" || LoginFile.provider == "Google"  {  ipusKeeper()}
        self.performSegue(withIdentifier: "signIn2", sender: Any?.self)
        }
    
        //logout from face book & Google
        func logoutGeneral(){
        if LoginFile.logoutchosen == true{let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        print ("logout from facebook")
           // GIDSignIn.sharedInstance().scopes = []
            print (GIDSignIn.sharedInstance().scopes)
            

        let firebaseAuth = FIRAuth.auth()
        do {try firebaseAuth?.signOut();            print ("logout from firebase")
        } catch let signOutError as NSError {
        print ("Error signing out: %@", signOutError)
        }
            GIDSignIn.sharedInstance().signOut();  print ("logout from google")
           

            //LoginFile.logoutchosen = false
        }//end of if
        }
    //alerts/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func alert2 () {
    let alertController2 = UIAlertController(title: ("Login alert") , message: textForError, preferredStyle: .alert)
    let okAction2 = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
    }
    alertController2.addAction(okAction2)
    present(alertController2, animated: true, completion: nil)
    }//alert2 end

    func alert1 () {
    let alertCotroller1 = UIAlertController(title: ("Password alert") , message: ("An email with password's instructions was sent to your email adrress"), preferredStyle: .alert)
    let okAction1 = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in}
    alertCotroller1.addAction(okAction1)
    present(alertCotroller1, animated: true, completion: nil)
    }//alert end

    
    
    // alerts end//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    func sign(_ signIn: GIDSignIn!, didSignInFor user2: GIDGoogleUser!, withError error: Error?) {
        if GIDSignIn.sharedInstance().hasAuthInKeychain() == true{
            print ("has auth key chain")
        }else{
            print ("no auth key chain")
        }
        
        if let error = error {
            print ("not 1234")
            return
        }
        
        print ("1234")
        guard let authentication = user2.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let error = error {
                print ("ggg",error)
                return
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController  =  storyboard.instantiateViewController(withIdentifier: "loginScreen")
            let homeViewController  =  storyboard.instantiateViewController(withIdentifier: "homeScreen")
            
            LoginFile.userFromGoole = user2
            LoginFile.employeeRef2 = (user?.uid)!
            // self.window?.rootViewController = loginViewController // before the app
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SomeNotification"), object: nil)
            
            return
        }//end of if
        
        func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
            // Perform any operations when the user disconnects from app here.
            // ...
            print ("ggg",GIDGoogleUser.self)
            
        }
        
        
    }
   
    
   }

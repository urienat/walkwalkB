//
//  LoginFile.swift
//  
//
//  Created by אורי עינת on 27.10.2016.
//
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit
import FacebookCore
import Google
import GoogleSignIn



class LoginFile: UIViewController, UITextFieldDelegate,FBSDKLoginButtonDelegate ,GIDSignInUIDelegate{

    let dbRefEmployees = FIRDatabase.database().reference().child("fEmployees")

    let mydateFormat = DateFormatter()
    let mydateFormat5 = DateFormatter()
    
    // facebooklogin variables
    let loginButton =  FBSDKLoginButton()
    static var provider = "normal"
    
    //cebook & google
    var fbNname = ""
    var fbLastName = ""
    var fbEmail = ""
    static var userFromGoole : GIDGoogleUser?
    static var employeeRef2 = "" {
        
        didSet {    //called when employeeref2 changed
            print("changed")
            
        }
    }
    
    
    var pickedImage:UIImage?
    let picture = UIImage(named: "perSessionImage")
    
    //facebook functions

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print ("logout from face book")
        LoginFile.provider = "normal"
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        thinking.startAnimating()
        if error != nil { print ("facebook login error:\(error)");thinking.stopAnimating()
        return
            
    } else { print ("facebook login succesfuly")
        rememberMe = 0
        keeper.set(0, forKey: "remember")
        keeper.set("", forKey: "userKept")
        keeper.set("", forKey: "passwordKept")

        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields" : "id, name, email, last_name, first_name"]).start{
        (connection,result,err) in
        print ("123")
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
        })
        }//end of dispatch
        })//end of firauth
        }//end fbsdkrequest
        }//end of else

    }//end of func login button
    
    var textForError:String?
    var employeeRefUpdate:String?

    let Vimage = UIImage(named: "V")
    let nonVimage = UIImage(named: "emptyV")
    
    var cu = Locale.current.currencySymbol
    static var logoutchosen:Bool = false
    static var userForCreate = ""
    static var passwordForCreate = ""
    
    //regulaer login

    //Keeper variables
    let keeper = UserDefaults.standard
    var checkBox : Bool?
    var rememberMe:Int?
    var userEmail:String! = nil
    var userPassword:String! = nil

    @IBOutlet weak var check: UIButton! // section for rememberme check
    @IBAction func checkBox(_ sender: Any) {
        
    if checkBox! == true {check.setImage(Vimage, for: .normal)
    checkBox = false
    keeper.set(1, forKey: "remember")
    rememberMe = 1
    UserDefaults.standard.synchronize()
    } else  {check.setImage(nonVimage, for: .normal)
    self.checkBox = true
    rememberMe = 0
    keeper.set(0, forKey: "remember")
    keeper.set("", forKey: "userKept")
    keeper.set("", forKey: "passwordKept")

    UserDefaults.standard.synchronize()
    }//end of else
    }//end of action checkbox
    
    @IBOutlet weak var dog: UIImageView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func forgot(_ sender: Any) {  //section for forgot or change password
    FIRAuth.auth()?.sendPasswordReset(withEmail: userEmail) { (error) in
        if error != nil { print ("erorrr!!!!")
        self.alert4()
        } else {
        self.alert1()}
        }
    }//end of forgot action
    
    
    @IBOutlet weak var thinking: UIActivityIndicatorView!
    @IBOutlet weak var signIn: UIButton! // section for signin
    @IBAction func signin(_ sender: Any) {
        signIn.isEnabled = false
        signIn.alpha = 0.5
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
       // inFireBase()


        try! FIRAuth.auth()?.signOut() // why signout?
       self.performSegue(withIdentifier: "create", sender: Any?.self)
    }//end of create action
    
   
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
       
        dog.clipsToBounds = true
        dog.layer.cornerRadius = 50
        
        
        mydateFormat.dateFormat = DateFormatter.dateFormat(fromTemplate: " EEE-dd-MMM-yyyy, (HH:mm)", options: 0, locale: nil)!
        mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)"
            ,options: 0, locale: nil)!
        
        //delgate to hide keyboard
        self.email.delegate = self
        self.password.delegate = self

        logoutGeneral()
        
        //google login setting
        let loginButton2 =  GIDSignInButton()
        GIDSignIn.sharedInstance().uiDelegate = self
        // GIDSignIn.sharedInstance().signIn()
        view.addSubview(loginButton2)
        loginButton2.frame = CGRect(x: view.frame.width/2-104, y: 30, width: 208, height: 45)
        
        //add observer
        if GIDSignIn.sharedInstance().currentUser != nil  {
        thinking.startAnimating()

        print (GIDSignIn.sharedInstance().currentUser)
        inFireBase()
            print ("after infirebase")
        } else {
        print (GIDSignIn.sharedInstance().currentUser)
        }

       
        //Facebook login setting
        view.addSubview(loginButton)
        loginButton.frame = CGRect(x: view.frame.width/2-100, y: 95, width: 200, height: 45)
        loginButton.delegate = self
        loginButton.readPermissions = ["email","public_profile"]

        super.viewDidLoad()

        if Reachability.isConnectedToNetwork() == true
        {print("Internet Connection Available!")}
        else{print("Internet Connection not Available!")
            alert50() }
       
        if keeper.integer(forKey: "remember") != 1 {rememberMe = 0 } else { rememberMe = keeper.integer(forKey: "remember")}
        print("rememberMe:\(rememberMe!)")
      
        
        //connectivity 
        if rememberMe == 1 {
        signIn.isHidden = false
        signIn.isEnabled = true
        check.setImage(Vimage, for: .normal)
        checkBox = false
        let savedUser = keeper.string(forKey: "userKept")
        let savedPassword = keeper.string(forKey: "passwordKept")
        if savedUser == nil || savedUser == "" {check.setImage(nonVimage, for: .normal)
                rememberMe = 0
                self.checkBox = true
                signIn.isEnabled = false
                forgot.isEnabled = false
        }//end of if
        email.text = savedUser
        password.text = savedPassword
        if LoginFile.logoutchosen == true {
        LoginFile.provider = "normal"
        print ("quickin")
        }
        } else {
        check.setImage(nonVimage, for: .normal)
        rememberMe = 0
        self.checkBox = true
        signIn.isEnabled = false
        forgot.isEnabled = false
        }//end of else
        
        if email.text == "" { forgot.isEnabled = false} else {forgot.isEnabled = true}
        print("rememberMe:\(rememberMe!)")
        
        if LoginFile.userForCreate != ""{ email.text = LoginFile.userForCreate; password.text = LoginFile.passwordForCreate; LoginFile.userForCreate = "";LoginFile.passwordForCreate = "";signIn.isEnabled = true;signIn.isHidden = false} else {LoginFile.userForCreate = "";LoginFile.passwordForCreate = ""}
        
        
        self.email.addTarget(self, action: #selector(checkIntial), for: .allEditingEvents )
        self.password.addTarget(self, action: #selector(checkIntial), for: .allEditingEvents)

        
        
        logoutGeneral()
       
        thinking.hidesWhenStopped = true
       
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
        if FBSDKAccessToken.current() != nil {        LoginFile.provider = "facebook"
            self.doSegue()
            }//end of if
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
            print (AccessToken.current as Any)
            
            if AccessToken.current != nil {        LoginFile.provider = "Google"
                self.doSegue()
            }//end of if
        }
        thinking.hidesWhenStopped = true
        
        
       
        } ///end of view did load//////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
        //keyboard hide
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            email.resignFirstResponder()
            password.resignFirstResponder()
            return true}
    
    
    
        func checkIntial() {
        if  email.text != "" && password.text != "" { signIn.isHidden = false;signIn.isEnabled = true}
        if email.text != ""  {forgot.isEnabled = true}}
    
        func signInProcess() {
        userEmail = email.text!
        userPassword = password.text!
        print("loginInfo:\(userEmail!)")
        print("loginInfo:\(email.text!)")
        if userEmail == ""  {self.textForError = ("Missing mail. Please fill in" )
            alert2()
        }//end of if useremail
        
        FIRAuth.auth()?.signIn(withEmail: userEmail, password: userPassword, completion: { (user, error) in
            
        if error != nil
        {print ("something went wrong")
        print(error!)
        if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                    
            switch errCode {
            case .errorCodeInvalidEmail:
            self.textForError = ("This is invalid mail.Please correct. or set a 'New Account' if its your first time with us." )
            self.alert2()
            print("invalid email")
            case .errorCodeUserNotFound:
            self.textForError = ("We could not find you in our records. Please check that you used this mail as your account user name or set a 'New Account' if its your first time with us." )
            self.alert2()
            print("in use")
            case .errorCodeNetworkError:
            self.textForError = ("There is no connection. Please try later." )
            self.alert2()
            case .errorCodeWrongPassword:
            self.textForError = ("This is a wrong Password. Please try again or use 'Forgot password'." )
            self.alert2()
            case .errorCodeUserDisabled:
            self.textForError = ("This user is disabled. Please check with our PerSession support at wwww.homeployer.com." )
            self.alert2()
            default:
            self.textForError = ("There is a login error . Pleasr try again" )
            self.alert2()
            print("Create User Error: \(String(describing: error))")
            }
            }//end of if let
            }//end of if error
        
            else {
            print("rememberMe:\(self.rememberMe!)")

            if self.rememberMe == 1{
                        self.keeper.set(self.email.text!, forKey: "userKept")
                        self.keeper.set(self.password.text!, forKey: "passwordKept")
                        self.keeper.set(1, forKey: "remember")
                        print ("uid\(String(describing: user?.uid))")
            }//end of if
            else {
                        self.keeper.set("", forKey: "userKept")
                        self.keeper.set("", forKey: "passwordKept")
                        self.keeper.set(0, forKey: "remember")
            }//end of else
            
            self.doSegue()
            print (self.userEmail)
            print (self.userPassword)
            }//end of else
            })//end of auth
            }//end of func
    
    
        //google signin
        func inFireBase(){
            
            LoginFile.provider = "Google"

            print (self.employeeRefUpdate as Any)
        
            DispatchQueue.main.asyncAfter(deadline: .now() ) {
                self.dbRefEmployees.child(LoginFile.employeeRef2).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("fCounter"){
            print("exist")
            //  self.thinking.stopAnimating()

                self.doSegue()
            }else{
            print("doesn't exist")
                
                if LoginFile.userFromGoole?.profile.givenName == nil {self.fbNname = ""}else {    self.fbNname = (LoginFile.userFromGoole?.profile.givenName!)!}
                if LoginFile.userFromGoole?.profile.familyName == nil {self.fbLastName = ""} else { self.fbLastName = (LoginFile.userFromGoole?.profile.familyName!)! }
                if LoginFile.userFromGoole?.profile.email == nil {self.fbEmail = ""} else { self.fbEmail = (LoginFile.userFromGoole?.profile.email!)!}
                
            self.accounCreation()
            //  self.thinking.stopAnimating()

            self.doSegue()
            }//end of else
            })
            }//end of dispatch
            }//end of infirebase

    
        func accounCreation() {
            if let user = FIRAuth.auth()?.currentUser {
            self.employeeRefUpdate =  user.uid}
            print (employeeRefUpdate as Any)
        
     
            self.dbRefEmployees.child((employeeRefUpdate)!).updateChildValues([ "fImageRef":"","fCounter": "1000","fCreated"  : self.mydateFormat5.string(from: Date()),"fName" : fbNname, "fLastName": fbLastName, "femail" : fbEmail, "fCurrency": Locale.current.currencySymbol!, "fProgram":"0","fTaxPrecentage":"0" ,"fTaxName":"",  "fSwitcher": "No","fTaxCalc" : "Over", "fDateTime": "DateTime","fConnect": "Off","fLogin":LoginFile.provider,"fLastCalander":"New","fAddress":"" ])
        
            self.dbRefEmployees.child(employeeRefUpdate!).child("myEmployers").setValue(["New Dog":0])//add employer to my employers of employee
                
            //storage of pictures //in cache under employeeID
            MyImageCache.sharedCache.setObject(self.pickedImage as AnyObject, forKey: self.employeeRefUpdate as AnyObject)
        
            //in firebase under url
            let dbStorageRef = FIRStorage.storage().reference().child("employeeImages").child(self.employeeRefUpdate!)
            if let uploadTask = UIImageJPEGRepresentation(self.picture!, CGFloat(0.1)){
            dbStorageRef.put(uploadTask, metadata: nil, completion: { (metadata, error) in
            if error != nil {
            print (error as Any)
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
        self.performSegue(withIdentifier: "signIn2", sender: Any?.self)
    }
    
    //logout from face book & Google
    func logoutGeneral(){
    if LoginFile.logoutchosen == true{let loginManager = FBSDKLoginManager()
    loginManager.logOut()
    print ("logout from facebook")
    let firebaseAuth = FIRAuth.auth()
    do {try firebaseAuth?.signOut();            print ("logout from Google")
    } catch let signOutError as NSError {
    print ("Error signing out: %@", signOutError)
    }
    GIDSignIn.sharedInstance().signOut()
        LoginFile.logoutchosen = false
    }//end of if
    }
    //alerts/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func alert () {
        let alertController3 = UIAlertController(title: ("Login alert") , message: ("Valid mail and password requiered. Please correct accordingly."), preferredStyle: .alert)
        let okAction3 = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in}
        alertController3.addAction(okAction3)
        present(alertController3, animated: true, completion: nil)
        }//alert end

    func alert2 () {
        let alertController2 = UIAlertController(title: ("Login alert") , message: textForError, preferredStyle: .alert)
        let okAction2 = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
        }
        alertController2.addAction(okAction2)
        present(alertController2, animated: true, completion: nil)
        }//alert2 end

    func alert1 () {
        let alertCotroller1 = UIAlertController(title: ("Password alert") , message: ("An email with password instructions was sent to your email adrress"), preferredStyle: .alert)
        let okAction1 = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in}
        alertCotroller1.addAction(okAction1)
        present(alertCotroller1, animated: true, completion: nil)
        }//alert end
    
    func alert4 () {
        let alertCotroller4 = UIAlertController(title: ("email alert") , message: ("Sorry. This email is not registered as valid in our records"), preferredStyle: .alert)
        let okAction1 = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in}
        alertCotroller4.addAction(okAction1)
        present(alertCotroller4, animated: true, completion: nil)
        }//alert end
    
    func alert50(){
        let alertController50 = UIAlertController(title: ("Internet Connection") , message: " There is no internet - Check communication avilability.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        }
        alertController50.addAction(OKAction)
        self.present(alertController50, animated: true, completion: nil)}
    
    // alerts end//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   }

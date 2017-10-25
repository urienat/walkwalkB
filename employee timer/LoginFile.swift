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



class LoginFile: UIViewController, UITextFieldDelegate {

    let dbRef = FIRDatabase.database().reference()
    let dbRefUser = FIRDatabase.database().reference().child("fEmployees")
    
    let mydateFormat = DateFormatter()
    let mydateFormat5 = DateFormatter()

  //  let loginButton =  FBSDKLoginButton()


    var textForError:String?

    let Vimage = UIImage(named: "V")
    let nonVimage = UIImage(named: "emptyV")
    var cu = Locale.current.currencySymbol
    let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
    static var logoutchosen:Bool = false
    static var userForCreate = ""
    static var passwordForCreate = ""

//keepקר variables
    let keeper = UserDefaults.standard
    
    
    var checkBox : Bool?
    var rememberMe:Int?
    var userEmail:String! = nil
    var userPassword:String! = nil

    
    @IBOutlet weak var check: UIButton! // section for rememberme check
    @IBAction func checkBox(_ sender: Any) {
        
    if checkBox! == true {check.setImage(Vimage, for: .normal)
    checkBox = false
    print ("checkBOX\(String(describing: checkBox))")
    keeper.set(1, forKey: "remember")
        rememberMe = 1
    UserDefaults.standard.synchronize()
    }
    else  {check.setImage(nonVimage, for: .normal)
    self.checkBox = true
           rememberMe = 0
    keeper.set(0, forKey: "remember")
    keeper.set("", forKey: "userKept")
    keeper.set("", forKey: "passwordKept")

        
    print ("checkBOX\(String(describing: checkBox))")
    UserDefaults.standard.synchronize()
        }
    }
    
    @IBOutlet weak var dog: UIImageView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func forgot(_ sender: Any) {  //section for forgot or change password
    userEmail = email.text!
    
    FIRAuth.auth()?.sendPasswordReset(withEmail: userEmail) { (error) in
        
        if error != nil { print ("erorrr!!!!")
        self.alert4()
        
        }
        else {
        self.alert1()}
        }
    }//end of forgot action
    
    
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
        try! FIRAuth.auth()?.signOut()

        self.performSegue(withIdentifier: "create", sender: Any?.self)
   
     /*


 
    */
    }//end of create action
    
   

 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        
        backgroundImage.image = UIImage(named: "Grass5")
        self.view.insertSubview(backgroundImage, at: 0)
        
        dog.clipsToBounds = true
        dog.layer.cornerRadius = 110
        

        //self.loginButton.delegate = self

    
        super.viewDidLoad()
        print ("remember\(keeper.integer(forKey: "remember"))")

        if Reachability.isConnectedToNetwork() == true
        {
            print("Internet Connection Available!")
        }
        else
        {
            print("Internet Connection not Available!")
            alert50()
        }
        print(keeper.integer(forKey: "remember"))
        
        if keeper.integer(forKey: "remember") != 1 {rememberMe = 0 } else { rememberMe = keeper.integer(forKey: "remember")}
        print("rememberMe:\(rememberMe!)")
      
        
        //connectivity 
        //FIRDatabase.database().persistenceEnabled = true
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
                // create.isEnabled = false
                forgot.isEnabled = false
            }
        email.text = savedUser
        password.text = savedPassword
        if LoginFile.logoutchosen == false {
            print ("quickin")


        }
        }
        else {
        check.setImage(nonVimage, for: .normal)
        rememberMe = 0
        self.checkBox = true
        signIn.isEnabled = false
        // create.isEnabled = false
        forgot.isEnabled = false
        }
        if email.text == "" { forgot.isEnabled = false} else {forgot.isEnabled = true}

        print("rememberMe:\(rememberMe!)")

        if LoginFile.userForCreate != ""{ email.text = LoginFile.userForCreate; password.text = LoginFile.passwordForCreate; LoginFile.userForCreate = "";LoginFile.passwordForCreate = "";signIn.isEnabled = true;signIn.isHidden = false} else {LoginFile.userForCreate = "";LoginFile.passwordForCreate = ""}
        
        mydateFormat.dateFormat = DateFormatter.dateFormat(fromTemplate: " EEE-dd-MMM-yyyy, (HH:mm)", options: 0, locale: nil)!
        mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)"
            ,options: 0, locale: nil)!
        
        self.email.addTarget(self, action: #selector(checkIntial), for: .allEditingEvents )
        self.password.addTarget(self, action: #selector(checkIntial), for: .allEditingEvents)

        
        //delgate to hide keyboard
        self.email.delegate = self
        self.password.delegate = self



    } ///end of view did load//////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
    
    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    }
    
    //keyboard hide
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    email.resignFirstResponder()
    password.resignFirstResponder()
    return true
    }
    
    //
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let middle =  segue.destination as! UINavigationController
        let third = middle.topViewController as! ViewController
        print ("prepare")
        if (segue.identifier == "create"){
        setting.newEmployee = "YES"
        third.newRegister = "YES"}
            
            
        else if  (segue.identifier == "signIn") {third.newRegister = "NO"}
        else {//do nothing}
        }
        print("reg\(third.newRegister)")
        }
    
    //image background rotation
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if(UIApplication.shared.statusBarOrientation.isLandscape)
        {backgroundImage.frame = self.view.bounds} else   {backgroundImage.frame = self.view.bounds}
        }
    
    func checkIntial() {
        if  email.text != "" && password.text != "" { signIn.isHidden = false;signIn.isEnabled = true}
        if email.text != ""  {forgot.isEnabled = true}

    }
    


    func signInProcess() {
        userEmail = email.text!
        userPassword = password.text!
        print("loginInfo:\(userEmail!)")
        print("loginInfo:\(email.text!)")
        if userEmail == ""  {self.textForError = ("Missing mail. Please fill in" )
            
            alert2()
        }
        

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
                        self.textForError = ("This user is disabled. Please check with our walkwalk support at wwww.homeployer.com." )
                        self.alert2()
                        
                    default:
                        self.textForError = ("There is a login error . Pleasr try again" )
                        self.alert2()
                        print("Create User Error: \(String(describing: error))")
                    }    
                }//end of if let
                
            }
        

            
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
                    }
                
                    
                    self.performSegue(withIdentifier: "signIn", sender: Any?.self)
                    
                    print (self.userEmail)
                    print (self.userPassword)
                }//end of else
            })//end of auth
        //}//end of else
    }//end of func
    
   

  
   // alerts///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // alert
    // ("Valid mail and password requiered. Please correct accordingly.")
    func alert () {
        let alertController3 = UIAlertController(title: ("Login alert") , message: ("Valid mail and password requiered. Please correct accordingly."), preferredStyle: .alert)
        let okAction3 = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
            //
        }
        alertController3.addAction(okAction3)
        present(alertController3, animated: true, completion: nil)
    }//alert end

    

    // alert2
    func alert2 () {
        let alertController2 = UIAlertController(title: ("Login alert") , message: textForError, preferredStyle: .alert)
        let okAction2 = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
        //
        }
        alertController2.addAction(okAction2)
        present(alertController2, animated: true, completion: nil)
    }//alert2 end

    // alert1
    func alert1 () {
        let alertCotroller1 = UIAlertController(title: ("Password alert") , message: ("An email with password instructions was sent to your email adrress"), preferredStyle: .alert)
        let okAction1 = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
            //
        }
        alertCotroller1.addAction(okAction1)
        present(alertCotroller1, animated: true, completion: nil)
    }//alert end
    
    
    // alert4
    func alert4 () {
        let alertCotroller4 = UIAlertController(title: ("email alert") , message: ("Sorry. This email is not registered as valid in our records"), preferredStyle: .alert)
        let okAction1 = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
            //
        }
        alertCotroller4.addAction(okAction1)
        present(alertCotroller4, animated: true, completion: nil)
    }//alert end
    
    func alert50(){
        let alertController50 = UIAlertController(title: ("Internet Connection") , message: " There is no internet - Check communication avilability.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        }
        
        alertController50.addAction(OKAction)
        self.present(alertController50, animated: true, completion: nil)
    }
    
        

    
    // alerts end///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   }

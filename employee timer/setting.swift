//
//  setting.swift
//  employee timer
//
//  Created by אורי עינת on 6.11.2016.
//  Copyright © 2016 אורי עינת. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import MessageUI

class setting: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate, MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    
    
    var blueColor = UIColor(red :22/255.0, green: 131/255.0, blue: 248/255.0, alpha: 1.0)
    var home = UIImage(named: "home")
    //keepקר variables
    let keeper = UserDefaults.standard
    
    var window: UIWindow?
    static var newEmployee:String?
    var wrongField: String?
    var profileImageUrl:String?
    
    var created: String?
    
    let mydateFormat5 = DateFormatter()

    var textForError:String?
    var emailForPasscode = ""
    let outBtn = UIButton(type: .custom)
    let outBarIten = UIBarButtonItem()

    @IBOutlet weak var pDogImage: UIImageView!

    let professions = ["Tutor","Psychologist","Therapist","Other"]
    
     var taxNameUpdate:String?
    @IBOutlet weak var taxNames: UISegmentedControl!
    @IBAction func taxNames(_ sender: Any) {
        switch taxNames.selectedSegmentIndex {
        case 0:
            taxNameUpdate = "VAT"
        case 1:
            taxNameUpdate = "GST"
            print (taxNameUpdate)
            
        case 2:
            taxNameUpdate = "Sales tax"
        default:
            taxNameUpdate = "Tax"
        }//end of switch
    }
    
    
    @IBOutlet weak var obligatory: UILabel!
    @IBOutlet weak var passwordTitle: UILabel!
    @IBOutlet weak var thinking: UIActivityIndicatorView!
    @IBOutlet weak var settingScroller: UIScrollView!
    
    let dbRef = FIRDatabase.database().reference()
    let dbRefEmployees = FIRDatabase.database().reference().child("fEmployees")

    var pickedImage:UIImage?
    
    @IBOutlet var viewForMove: UIView!
    @IBOutlet weak var name: UITextField!
    var nameUpdate = ""
    
    @IBOutlet weak var lastName: UITextField!
    var lastNameUpdate = ""
   
    @IBOutlet weak var email: UITextField!
    var emailUpdate = ""

    @IBOutlet weak var addressConstrain: NSLayoutConstraint!
    @IBOutlet weak var address: UITextField!
    var addressUpdate = ""
    
    
    @IBOutlet weak var reset: UIButton!
    
    @IBOutlet weak var passWord: UITextField!
    var passwordUpdate = ""

    var employeeRefUpdate = ""
    
    @IBOutlet weak var picture: UIImageView!
    var imagePicker2: UIImagePickerController!

    @IBOutlet weak var currencyTitle: UILabel!
    @IBOutlet weak var currency: UITextField!
    var currencyUpdate = ""
    
    @IBOutlet weak var signer: UITextField!
    @IBOutlet weak var precentage: UITextField!
    var taxPrecentageUpdate = "0"
    
    var dateTimeUpdate:String?
    @IBOutlet weak var dateTimeFormat: UISegmentedControl!
    @IBAction func dateTimeFormat(_ sender: Any) {
        switch dateTimeFormat.selectedSegmentIndex {
        case 0:
            dateTimeUpdate = "DateTime"
           
        case 1:
            dateTimeUpdate = "Date"
            
        default:
            print("nothing")
        }//end of switch
    }
    
    
    var calanderUpdate:String?
    @IBOutlet weak var calander: UISegmentedControl!
    @IBAction func calander(_ sender: Any) {
        switch calander.selectedSegmentIndex {
        case 0:
            calanderUpdate = "Google"
        case 1:
            calanderUpdate = "IOS"
        default:
            calanderUpdate = "None"
            print("None")
        }//end of switch
    }
    
    var taxCalacUpdate:String?
    @IBOutlet weak var taxCalac: UISegmentedControl!
    @IBAction func taxCalc(_ sender: Any) {
        switch taxCalac.selectedSegmentIndex {
        case 0:
            taxCalacUpdate = "Included"
            
            
        case 1:
            taxCalacUpdate = "Over"
            
            
        default:
            print("nothing")
        }//end of switch
    }
    
    @IBOutlet weak var taxinfoSign: UIButton!
    @IBOutlet weak var taxerTitle: UILabel!
    var taxSwitcherUpdate = "No"
    var taxSwitchTemp = "No"
    

    @IBAction func professionBtn(_ sender: Any) {
        professionalPicker.isHidden = false

    }
    @IBOutlet weak var professionBtn: UIButton!
    @IBOutlet weak var professionalPicker: UIView!
    @IBAction func donePicker(_ sender: Any) {
        professionalPicker.isHidden = true
    }
    
    @IBAction func startProfessionEdit(_ sender: Any) {
    
        professionalPicker.isHidden = false

    }
    
    
    @IBOutlet weak var taxId: UITextField!
    var taxIdUpdate = ""
    
    @IBOutlet weak var taxSwitch: UISwitch!
    @IBAction func taxSwitch(_ sender: Any) {
        if self.taxSwitchTemp == "No" {taxCalac.isHidden = true; self.taxSwitch.setOn(false, animated: true);self.precentage.isHidden = true;taxNames.isHidden = true ;signer.isHidden = true;taxSwitchTemp = "Yes";taxSwitcherUpdate = "No";taxPrecentageUpdate = "0";precentage.text = taxPrecentageUpdate; taxIdUpdate = ""; taxId.text = taxIdUpdate
        
    } else {
            self.taxSwitch.setOn(true, animated: true);taxCalac.isHidden = false;self.precentage.isHidden = false;taxNames.isHidden = false; signer.isHidden = false;taxSwitchTemp = "No";taxSwitcherUpdate = "Yes";alert17();if self.taxCalacUpdate == "Over"{self.taxCalac.selectedSegmentIndex = 1} else {self.taxCalac.selectedSegmentIndex = 0}}   }
    
    
    @IBAction func taxationInfo(_ sender: Any) {
        alert17()
    }
    
    @IBOutlet weak var paypal: UITextField!
    var paypalUpdate = ""
    
    @IBOutlet weak var billInfo: UITextField!
    var billInfoUpdate = ""
    
    
    @IBOutlet weak var subscriptionLbl: UILabel!
    @IBOutlet weak var subscriptionBtn: UIButton!
    
    @IBAction func takePhoto(_ sender: Any) {
        imagePicker2 = UIImagePickerController()
        imagePicker2.delegate = self
        sourcePicPicker()
        present(imagePicker2, animated:  true, completion: nil)
    }

    @IBAction func help(_ sender: Any) {
        alert4()
    }
    
    @IBOutlet weak var bark: UIButton!
    @IBAction func bark(_ sender: Any) {
        bark.isEnabled = false
        bark.alpha = 0.5
        RebeloperStore.shared.purchaseRenewable(.autoRenewableSubscription1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.bark.isEnabled = true
            self.bark.alpha = 1
        }
    }
    
    @IBOutlet weak var bark2: UIButton!
    @IBAction func bark2(_ sender: Any) {
        bark2.isEnabled = false
        bark2.alpha = 0.5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.bark2.isEnabled = true
            self.bark2.alpha = 1
        }
    }
   
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    override func viewDidLoad() {
        super.viewDidLoad()

        picture.clipsToBounds = true
        picture.layer.cornerRadius = 15
        
        
         //   let yourBackImage = UIImage(named: "home")
           // self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
           // self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        
        
            let currentUser = FIRAuth.auth()?.currentUser
            if (currentUser != nil) {
                
                self.emailUpdate = (currentUser?.email!)!
                self.emailForPasscode = (currentUser?.email!)!
                self.email.text = self.emailUpdate
                self.employeeRefUpdate = (currentUser?.uid)!

        if let user = currentUser{
        self.emailUpdate = user.email!
        self.email.text = self.emailUpdate
        self.employeeRefUpdate = user.uid
            
            
            if LoginFile.provider == "facebook" || LoginFile.provider == "Google" {passwordTitle.isHidden = true; reset.isHidden=true; addressConstrain.constant = 8} else {addressConstrain.constant = 46
            passwordTitle.isHidden = false;  reset.isHidden = false}
            passWord.isHidden = true

            navigationItem.hidesBackButton = false // set pet list as enable

        
            passWord.delegate = self
            
        //user is signed in
        print ("user\(user)!")
        print ("email\(user.email!)!")
            
            let saveRecord = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(finChangeHappend))
            navigationItem.rightBarButtonItem = saveRecord
                
            self.dbRefEmployees.queryOrderedByKey().queryEqual(toValue: user.uid).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            self.nameUpdate = String(describing: snapshot.childSnapshot(forPath: "fName").value!) as String!
            self.name.text = self.nameUpdate
                    
            self.lastNameUpdate = snapshot.childSnapshot(forPath: "fLastName").value! as! String
            self.lastName.text = self.lastNameUpdate
                
            self.addressUpdate = snapshot.childSnapshot(forPath: "fAddress").value! as! String
            self.address.text = self.addressUpdate
                
            self.professionBtn.setTitle(snapshot.childSnapshot(forPath: "fProfessionControl").value! as! String, for: .normal)

            
            self .currencyUpdate = snapshot.childSnapshot(forPath: "fCurrency").value as! String
            self.currency.text = self.currencyUpdate
            
            
            self.created = (snapshot.childSnapshot(forPath: "fCreated").value as! String)
                
            self.dateTimeUpdate = (snapshot.childSnapshot(forPath: "fDateTime").value as! String)
            if self.dateTimeUpdate == "Date"{self.dateTimeFormat.selectedSegmentIndex = 1} else {self.dateTimeFormat.selectedSegmentIndex = 0}


            self.calanderUpdate = (snapshot.childSnapshot(forPath: "fCalander").value as! String)
            if self.calanderUpdate == "Google" {self.calander.selectedSegmentIndex = 0} else if self.calanderUpdate == "IOS" {self.calander.selectedSegmentIndex = 1} else {self.calander.selectedSegmentIndex = 2}

            self.taxCalacUpdate = (snapshot.childSnapshot(forPath: "fTaxCalc").value as! String)
            self.taxNameUpdate  = snapshot.childSnapshot(forPath: "fTaxName").value as! String
            if self.taxNameUpdate! == "VAT"{self.taxNames.selectedSegmentIndex = 0} else if self.taxNameUpdate! == "GST" {self.taxNames.selectedSegmentIndex = 1} else if self.taxNameUpdate! == "Sales tax" {self.taxNames.selectedSegmentIndex = 2}
                
                print (self.taxNameUpdate)
                
            self.taxSwitchTemp = snapshot.childSnapshot(forPath: "fSwitcher").value as! String
                if self.taxSwitchTemp == "No" {self.taxSwitch.setOn(false, animated: true);self.precentage.isHidden = true;self.taxNames.isHidden = true; self.taxCalac.isHidden = true; self.signer.isHidden = true;self.taxSwitchTemp = "Yes";

            } else {
                    self.taxSwitch.setOn(true, animated: true);self.taxCalac.isHidden = false; self.precentage.isHidden = false; self.taxNames.isHidden = false; self.signer.isHidden = false;self.taxSwitchTemp = "No";self.taxSwitcherUpdate = "Yes"; if self.taxCalacUpdate == "Over"{self.taxCalac.selectedSegmentIndex = 1} else {self.taxCalac.selectedSegmentIndex = 0} }

            self.taxPrecentageUpdate  = snapshot.childSnapshot(forPath: "fTaxPrecentage").value as! String
            self.precentage.text = self.taxPrecentageUpdate
                
            
            self.taxIdUpdate  =  snapshot.childSnapshot(forPath: "fTaxId").value as! String
            self.taxId.text = self.taxIdUpdate
                
            self.paypalUpdate = snapshot.childSnapshot(forPath: "fPaypal").value! as! String
            self.paypal.text = self.paypalUpdate
            
            self.billInfoUpdate = snapshot.childSnapshot(forPath: "fBillinfo").value! as! String
            self.billInfo.text = self.billInfoUpdate
                    
        //bring image
        print("employeeref\(self.employeeRefUpdate)")
        if let cachedImage = MyImageCache.sharedCache.object(forKey: self.employeeRefUpdate as AnyObject) as? UIImage//bring from cache
          
        {
        DispatchQueue.main.async {
        print("employeeref\(String(describing: self.picture.image))")
        self.picture.image = cachedImage
        print("employeeref\(String(describing: self.picture.image))")
        }
        }//end of bring image from cache
        
        else{
        //bring from firebase
        if let profileImageUrl = snapshot.childSnapshot(forPath: "fImageRef").value as! String! {
        print (profileImageUrl)
        if let url = URL(string: profileImageUrl){
        URLSession.shared.dataTask(with: url, completionHandler: { (Data, response, error) in
        if error != nil {
        print (error as Any)
        self.picture.image = self.pDogImage.image //I added to avoid teufut. if not stop cancel
            
            
        }
        DispatchQueue.main.async {
            if self.picture.image == nil {self.picture.image = self.pDogImage.image } else{
                self.picture.image = UIImage(data: Data!)!}
        }
        //  upload to cache
        MyImageCache.sharedCache.setObject(UIImage(data: Data!)!, forKey: self.employeeRefUpdate as AnyObject , cost: (Data?.count)!) // upload to cache
        })
        .resume()
        }//end of if let url
        //end of bring from firebase
        } //end of if lf let profile
        }//end of else
            } , withCancel: { (Error) in
                self.alert30()
                print("error from FB")})//end of dbref
        }//end of if let current user
        }//end of if current user !=nil
        
        // end of firauth
        
        
        print("ughghjg\(employeeRefUpdate)")
        if setting.newEmployee == "YES"{
            //deletekeeper
            keeper.set(0, forKey: "remember")
            keeper.set("", forKey: "userKept")
            keeper.set("", forKey: "passwordKept")
            UserDefaults.standard.synchronize()

            passWord.isHidden = false
            reset.isHidden = true
            
            obligatoryIn()
            obligatoryOut()
            
            let cancelLogin = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(logout))
            navigationItem.leftBarButtonItem = cancelLogin
           
            let saveRecord = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(accounCreation))
            navigationItem.rightBarButtonItem = saveRecord

            setting.newEmployee = "NO"
        }else {
            
            
        }
        
        mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)"
            ,options: 0, locale: nil)!
        
        
        //keyboard adjustment
        NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardNotificationwillShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardNotificationwillHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: self.view.window)
   
        NotificationCenter.default.addObserver(forName: NSNotification.Name(iAPStatusChanged), object: nil, queue:OperationQueue.main) { (Notification) in
            //{(note)-> void in
            }

        professionalPicker.layer.borderWidth = 0.5
        professionalPicker.layer.borderColor = blueColor.cgColor
        professionalPicker.layer.cornerRadius =  15//CGFloat(25)
        professionalPicker.layoutIfNeeded()
        
       // professionBtn.backgroundColor = .clear
        professionBtn.layer.cornerRadius = 5
        professionBtn.layer.borderWidth = 1
        professionBtn.layer.borderColor = blueColor.cgColor
        
        }//end of viewdid load    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        }
    
        @IBAction func reset(_ sender: Any) {
        reset.isEnabled = false
        reset.alpha = 0.5
        FIRAuth.auth()?.sendPasswordReset(withEmail:emailForPasscode ) { (error) in
            if error != nil { print ("erorrr!!!!")
            self.alert40()
            }
            else {
            self.alert1()}
            }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.reset.isEnabled = true
            self.reset.alpha = 1
        }
        }
    
    func accounCreation() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        emailUpdate = self.email.text!
        passwordUpdate = self.passWord.text!
        if emailUpdate == ""  {self.textForError = ("Missing mail. Please fill in" )
            alert2()
        }
        FIRAuth.auth()?.createUser(withEmail: emailUpdate, password: passwordUpdate, completion: { (user, error ) in
        if error != nil
        {print ("something went wrong")
        print(error!)
        if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                    
        switch errCode {
        case .errorCodeInvalidEmail:
        self.textForError = ("This is invalid mail. please correct." )
        self.alert2()
        print("invalid email")
        case .errorCodeEmailAlreadyInUse:
        self.textForError = ("This is mail is alrady in use. Use sign-In or create a different email to create new account." )
        self.alert2()
        print("in use")
        case .errorCodeWeakPassword:
        self.textForError = ("6-10 characters password  requiered. Please correct accordingly." )
        self.alert2()
        default:
        print("Create User Error: \(String(describing: error))")
                    }
                }//end of if let
                
            }
            else {
                LoginFile.userForCreate = self.email.text!
                LoginFile.passwordForCreate = self.passWord.text!
                
                self.employeeRefUpdate = (user?.uid)!
                
            self.dbRefEmployees.child((user?.uid)!).updateChildValues([ "fImageRef":"","fCounter": "1000","fCreated"  : self.mydateFormat5.string(from: Date()),"fName" : self.name.text!, "fLastName": self.lastName.text!, "femail" : self.email.text!, "fCurrency": Locale.current.currencySymbol!, "fProgram":"0","fTaxPrecentage": self.taxPrecentageUpdate,"fTaxId": self.taxIdUpdate,  "fSwitcher": self.taxSwitcherUpdate,"fTaxCalc" : "Over", "fDateTime": "DateTime","fLogin":"Normal", "fLastCalander":"New","fAddress":self.addressUpdate, "fPaypal" : self.paypalUpdate, "fBillinfo" :self.billInfoUpdate,"fCalander" : "None","fProfessionControl":"Profession","fTaxName":""
                ])

                ViewController.dateTimeFormat = self.dateTimeUpdate

                self.dbRefEmployees.child(user!.uid).child("myEmployers").setValue(["New Dog":0])//add employer to my employers of employee
                
                //storage of pictures 
                //in cache under employeeID
                MyImageCache.sharedCache.setObject(self.pickedImage as AnyObject, forKey: self.employeeRefUpdate as AnyObject)
                
                
                //in firebase under url
                let dbStorageRef = FIRStorage.storage().reference().child("employeeImages").child(self.employeeRefUpdate)
                if let uploadTask = UIImageJPEGRepresentation(self.picture.image!, CGFloat(0.1)){
                    dbStorageRef.put(uploadTask, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            print (error as Any)
                            return
                        }
                        self.dbRefEmployees.child(self.employeeRefUpdate).updateChildValues(["fImageRef":(metadata?.downloadURL()?.absoluteString)! as Any ])
                    }) //end of dbref
                }//end of uploadtask
                ViewController.fixedCurrency = self.currency.text!
                
                //add users update passcode and mail
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                
                self.alert70()
                }
                
  
            }//end of else
        }) // end of auth
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){

            
       self.navigationItem.rightBarButtonItem?.isEnabled = true
        }

    }//end of account creation
    
    func finChangeHappend(){
        
        self.dbRefEmployees.queryOrderedByKey().queryEqual(toValue: self.employeeRefUpdate).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            
            print ((snapshot.childSnapshot(forPath: "fTaxCalc").value as! String),snapshot.childSnapshot(forPath: "fSwitcher").value as! String,snapshot.childSnapshot(forPath: "fTaxPrecentage").value as! String,snapshot.childSnapshot(forPath: "fTaxId").value as! String )
            
            if  (snapshot.childSnapshot(forPath: "fTaxCalc").value as! String) != self.taxCalacUpdate!  ||
           snapshot.childSnapshot(forPath: "fSwitcher").value as! String !=  self.taxSwitcherUpdate ||
            snapshot.childSnapshot(forPath: "fTaxPrecentage").value as! String  != self.precentage.text!  ||
            snapshot.childSnapshot(forPath: "fTaxId").value as! String != self.taxId.text!
            {self.alert6() } else {self.saveToDB()}
        } , withCancel: { (Error) in
            self.alert30()
            print("error from FB")})
    }

        func saveToDB() {
        ViewController.dateTimeFormat = self.dateTimeUpdate
            
        ViewController.calanderOption = self.calanderUpdate

        let alertController = UIAlertController(title: ("Save Setting") , message: ("Are You Sure?"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        }
        let updateDBAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
       
            print ("jhgdjhg\(String(describing: self.dateTimeUpdate))")
        
            self.dbRefEmployees.child(self.employeeRefUpdate).updateChildValues(["fName" : self.name.text!, "fLastName": self.lastName.text!, "femail" : self.email.text!, "fCurrency": self.currency.text!, "fProgram": "0","fTaxPrecentage": self.precentage.text!,"fTaxId": self.taxId.text!, "fSwitcher": self.taxSwitcherUpdate,"fTaxCalc" : self.taxCalacUpdate, "fDateTime": self.dateTimeUpdate, "fCalander" : self.calanderUpdate,"fAddress":self.address.text,"fPaypal" : self.paypal.text,"ftaxName":self.taxNameUpdate, "fBillinfo" :self.billInfo.text, "fProfessionControl":self.professionBtn.titleLabel?.text ]) //check email update with regard to auth
           
            
          self.updateEmail()
            
        
            //storage of pictures
            //in cache under employeeID
            MyImageCache.sharedCache.setObject(self.pickedImage as AnyObject, forKey: self.employeeRefUpdate as AnyObject)
            
            
            //in firebase under url
            let dbStorageRef = FIRStorage.storage().reference().child("employeeImages").child(self.employeeRefUpdate)
            if let uploadTask = UIImageJPEGRepresentation(self.picture.image!, CGFloat(0.1)){
                dbStorageRef.put(uploadTask, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print (error as Any)
                        return
                    }
                    self.dbRefEmployees.child(self.employeeRefUpdate).updateChildValues(["fImageRef":(metadata?.downloadURL()?.absoluteString)! as Any ])
                }) //end of dbref
            }//end of uploadtask   
            
        ViewController.fixedCurrency = self.currency.text!
        ViewController.taxOption = self.taxSwitcherUpdate
            if self.precentage.text != nil {ViewController.taxation = self.precentage.text!}
            ViewController.taxCalc = self.taxCalacUpdate
           

            
        self.navigationController!.popViewController(animated: true)

       
        }//end of let update
        alertController.addAction(cancelAction)
        alertController.addAction(updateDBAction)
        self.present(alertController, animated: true, completion: nil)
        }
    
    //photo handling
    
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            
        if let pickedImage: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
        picture.image =  pickedImage
 

            }//end of if let picked image
            imagePicker2.dismiss(animated: true, completion: nil )
            }//end of imagepicked controller

            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                dismiss(animated: true, completion: nil)
            }
    
    //sourcePicker
            func sourcePicPicker(){
            let picSource = UIAlertController(title: ("Add your Picture") , message: (""), preferredStyle: .alert)
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (UIAlertAction) in
            self.imagePicker2.sourceType = UIImagePickerControllerSourceType.camera
            self.present(self.imagePicker2, animated:  true, completion: nil)
                }
            let AlbumAction = UIAlertAction(title: "Album", style: .default) { (UIAlertAction) in
            self.imagePicker2.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(self.imagePicker2, animated:  true, completion: nil)
            }
            picSource.addAction(AlbumAction)
            picSource.addAction(cameraAction)
            self.present(picSource, animated: true, completion: nil)
            }
    
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result.rawValue{
        
        case MessageComposeResult.cancelled.rawValue :
            print ("message cancelled")
        case MessageComposeResult.failed.rawValue :
            print ("message failed")
        case MessageComposeResult.sent.rawValue :
            print ("message sent")
        default: break
        }//end of switch
        controller.dismiss(animated: true, completion: nil)
        }//end of func  message compose
    
        //validation
        //email
        func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
        }
    
        //phone Validation
        func validate(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
        }
    
        func updateEmail(){
            FIRAuth.auth()?.currentUser?.updateEmail(email.text! , completion: { (error) in
   
                if error != nil {
                print("There was an error processing the request")
                } else {
    
                print("Email changed successfully")
                }
            })
        }//end of func

        //adjustkeyboard
        func KeyboardNotificationwillShow(notification: NSNotification){
        if precentage.isEditing || taxId.isEditing || currency.isEditing
        {
            UIView.animate(withDuration: 0.8, animations: {Void in
            //   scroller
                self.settingScroller.contentOffset.y = 150
            })
        }
        
        }//end of func keyboard notification
    
        func KeyboardNotificationwillHide(notification: NSNotification){
        UIView.animate(withDuration: 0.4, animations: {Void in
            self.settingScroller.contentOffset.y = 0
        })
        }//end of willhide
    
    func obligatoryIn(){
        UIView.animate(withDuration: 0.3, animations: {
            self.obligatory.transform = CGAffineTransform(scaleX: 0.5, y: 0.9)
        })
    }
    
    // Fade In Buttons
    func obligatoryOut(){
        UIView.animate(withDuration: 2.3,delay: 0.3, animations: {
            self.obligatory.transform = .identity// CGAffineTransformIdentity
        })
    }
    func logout(){
        print(logout)
        self.present((storyboard?.instantiateViewController(withIdentifier: "loginScreen"))!, animated: true, completion: nil)

    }
    
    //picker methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return professions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return professions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        professionBtn.setTitle(professions[row], for: .normal)
        ViewController.professionControl = professions[row]
    }
    
    ///alerts///////////////////////////////////////////////////////////////////////////////////
    
    func alert20(){
    let alertController2 = UIAlertController(title: ("Missing fields ") , message: ("Name and last name is a requiered field."), preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
    }
    alertController2.addAction(OKAction)
    self.present(alertController2, animated: true, completion: nil)
    }
    
    func alert4(){
        let alertController4 = UIAlertController(title: ("email") , message: "email is also your user name. ", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            if self.reset.isHidden == true {
            self.passWord.becomeFirstResponder()  }  else {self.email.becomeFirstResponder()   }
        }
        alertController4.addAction(OKAction)
        self.present(alertController4, animated: true, completion: nil)
        }
    
    func alert16(){
    let alertController16 = UIAlertController(title: ("Program") , message: "Intially you would enroll into a month of free trial program. Then you can choose to enroll into a monthly subscription of $2.99 per month.", preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
    }
    alertController16.addAction(OKAction)
    self.present(alertController16, animated: true, completion: nil)
    }
    
    func alert17(){
    let alertController17 = UIAlertController(title: ("Taxation") , message: "The precentage of tax you chose would be added on top of your Invoice for 'Excluded' or would be included in this rate for 'Included' option. ", preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
    }
    alertController17.addAction(OKAction)
    self.present(alertController17, animated: true, completion: nil)
    }
    
    
    // alert2
    func alert2 () {
        let alertController2 = UIAlertController(title: ("Login alert") , message: textForError, preferredStyle: .alert)
        let okAction2 = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
        }
        alertController2.addAction(okAction2)
        present(alertController2, animated: true, completion: nil)
    }//alert2 end
    
    // alert1
    func alert1 () {
    let alertCotroller1 = UIAlertController(title: ("Password alert") , message: ("An email with password instructions was sent to the email you signed into PerSession"), preferredStyle: .alert)
    let okAction1 = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
    }
    alertCotroller1.addAction(okAction1)
    present(alertCotroller1, animated: true, completion: nil)
    }//alert end
    
    // alert4
    func alert40 () {
    let alertCotroller4 = UIAlertController(title: ("email alert") , message: ("Sorry. This email is not registered as valid in our records"), preferredStyle: .alert)
    let okAction1 = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
    }
    alertCotroller4.addAction(okAction1)
    present(alertCotroller4, animated: true, completion: nil)
    }//alert end
    
    // alert6
    func alert6 () {
        let alertCotroller6 = UIAlertController(title: ("Financial effect change") , message: ("Changes made in tax fields are effective from now on, to sessions not yet billed."), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK. I am aware.", style: .default) { (UIAlertAction) in
            self.saveToDB()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            self.navigationController!.popViewController(animated: true)
        }
        alertCotroller6.addAction(okAction)
        alertCotroller6.addAction(cancelAction)

        present(alertCotroller6, animated: true, completion: nil)
    }//alert end
    
    // alert70
    func alert70 () {
        let alertCotroller70 = UIAlertController(title: ("Welcome on Board") , message: ("You can login and add your first account."), preferredStyle: .alert)
        let okAction1 = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.present((storyboard.instantiateViewController(withIdentifier: "loginScreen")), animated: true, completion: nil)
        //send welcome email with video
        }
        alertCotroller70.addAction(okAction1)
        present(alertCotroller70, animated: true, completion: nil)
    }//alert end


}////////////////////////////end!!!

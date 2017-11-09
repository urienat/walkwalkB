//
//  dogFile.swift
//  employee timer
//
//  Created by אורי עינת on 9.11.2016.
//  Copyright © 2016 אורי עינת. All rights reserved.
//

import UIKit
import Firebase
import MessageUI
import CoreLocation
import FirebaseAuth


class dogFile: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate ,MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate {

    let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
    let Vimage = UIImage(named: "V")
    let emptyVimage = UIImage(named: "emptyV")
    
    
    let greenColor = UIColor(red :32.0/255.0, green: 150.0/255.0, blue: 24.0/255.0, alpha: 1.0)
    let blackColor = UIColor(red :24.0/255.0, green: 25.0/255.0, blue: 27.0/255.0, alpha: 1.0)
    var blueColor = UIColor(red :22/255.0, green: 131/255.0, blue: 248/255.0, alpha: 1.0)


    @IBOutlet weak var scrollerView: UIScrollView!
    
    @IBOutlet weak var bills: UIBarButtonItem!
    @IBOutlet weak var leash: UIBarButtonItem!
    @IBOutlet weak var trash: UIBarButtonItem!
    
    var messageInstruction = ""
    var titleInstruction = ""

    let locationManager = CLLocationManager()
    var location: CLLocation?
    var locationXUpdate: String? = ""
    var cLocationXUpdate: String? = ""
    var locationYUpdate:  String? = ""
    var cLocationYUpdate: String? = ""
    var connectSetter: String? = ""
    
    var adjuster = 0
    
    var paymentchanged: Bool?
    
    
    //var cProfileImage: String?
    
    var wrongField:String?
    
    var message :String?
    var message2 :String?
    var message3 :String?

    
    var activeEmployerSwitch: Bool?
    var activeGpsSwitch: Bool?

    
    var employerID = ""
    var EmployerRef = ""
    var lbl = ""
    var employeeID = ""
    var employerFromMain = ""
    
    var cEmployerRef = ""

    let dbRef = FIRDatabase.database().reference()
    let dbRefEmployers = FIRDatabase.database().reference().child("fEmployers")
    let dbRefcEmployers = FIRDatabase.database().reference().child("cEmployers")
    let dbRefEmployees = FIRDatabase.database().reference().child("fEmployees")


    @IBOutlet weak var obligatory: UILabel!
    @IBAction func deleteAdog(_ sender: Any) {dogDeleteAlert()}  //for deleting an employer
    
    @IBOutlet weak var activeButton: UIButton!
    @IBAction func activeButton(_ sender: Any) {
            if activeEmployerSwitch == true { activeEmployer.image = Vimage
            activeButton.setTitle("", for: .normal)
            activeEmployerSwitch = false} else {activeEmployer.image = emptyVimage
            activeButton.setTitle("Inactive", for: .normal)
            activeEmployerSwitch = true}
            }
    @IBOutlet weak var activeEmployer: UIImageView!
    
    @IBOutlet weak var pName: UITextField!
    var nameUpdate = ""
    var cNameUpdate = ""
    
    @IBOutlet weak var pLastName: UITextField!
    var lastNameUpdate = ""
    var cLastNameUpdate = ""
    
    @IBOutlet weak var pEmail: UITextField!
    var emailUpdate = ""
    
    @IBOutlet weak var pCell: UITextField!
    var cellUpdate = ""
    var cCellUpdate = ""

    
    @IBOutlet weak var pAddress: UITextField!
    var addressUpdate = ""
    var cAddressUpdate = ""

    
    @IBOutlet weak var imageGps: UIImageView!
    
    @IBAction func setGPS(_ sender: Any) {
        print (activeGpsSwitch!)
        if activeGpsSwitch == true {
            if self.location != nil { alert9()
                locationXUpdate = String(describing: location!.coordinate.latitude)
                locationYUpdate =  String(describing: location!.coordinate.longitude)
            imageGps.image = Vimage
                
                activeGpsSwitch = false
            
            }
            else {
                print ("location\(String(describing: self.location))")
          alert20()
            }
        
        }else {
            
                locationXUpdate = "0"
                locationYUpdate =  "0"
            imageGps.image = emptyVimage
                activeGpsSwitch = true}
    

        //locationManager.stopUpdatingLocation()
        }//end of set GPS
    @IBOutlet weak var GPStitle: UIButton!
    
    @IBOutlet weak var rateTitle: UILabel!
    @IBOutlet weak var pRate: UITextField!
    var RateUpdate = 0.0
    
    var paymentUpdate = ""

    
    @IBOutlet weak var currencySign: UILabel!
    @IBOutlet weak var pPayment: UISegmentedControl!
    
    
    @IBAction func pPayment(_ sender: Any) {
        
        switch pPayment.selectedSegmentIndex {
        case 0:
        paymentUpdate = "Normal"
        rateTitle.text = "Hour rate"
        if paymentchanged == false {} else { alert512()}
        paymentchanged = true
            
        case 1:
        paymentUpdate = "Round"
        rateTitle.text = "Session rate"

        infoPayment.isHidden = false
        if paymentchanged == false {} else { alert512()}
        paymentchanged = true
   

        default:
        print("nothing")
        }//end of switch
        }
    
    
    @IBOutlet weak var infoPayment: UIButton!
    @IBAction func infoPayment(_ sender: Any) {
        alert8()
    }
    
    @IBAction func infoGps(_ sender: Any) {
        alert9()
        
    }
    
    @IBOutlet weak var pPetName: UITextField!
    var petNameUpdate = ""
    var cPetNameUpdate = ""
    
    @IBOutlet weak var connectTitle: UILabel!
    @IBOutlet weak var connect: UISwitch!
    @IBAction func connect(_ sender: Any) {
        if connect.isOn == true {connectSetter = "Yes"; alert5(); self.dbRefEmployers.child(self.employerID).child("myEmployees").child(self.employeeID).updateChildValues(["fConnect": self.connectSetter!]);
        bringEmployerData()
        }
        
        else {connectSetter = "No"
        self.dbRefEmployers.child(self.employerID).child("myEmployees").child(self.employeeID).updateChildValues(["fConnect": self.connectSetter!]);
            bringEmployerData()
        }
        
    }
    
    @IBAction func infoConnect(_ sender: Any) {
        alert5()
    }

    @IBOutlet weak var invite: UIButton!
    @IBAction func invite(_ sender: Any) {
        alert15()
           }//end of invite
    
    @IBOutlet weak var pRem: UITextField!
    var remUpdate = ""
    
    @IBOutlet weak var pDogImage: UIImageView!
    var imagePicker: UIImagePickerController!
    var ImageForFirebase : UIImage?
    
    @IBOutlet weak var takePic: UIButton!
    @IBAction func takePhoto(_ sender: Any) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        sourcePicPicker()
        present(imagePicker, animated:  true, completion: nil)
    }
    
    @IBAction func sendMail(_ sender: Any) {
        alert()
    }
    
    override func viewDidLoad() { ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        super.viewDidLoad()
        
        

        connect.onTintColor =  blueColor

    
        
        ViewController.refresh = false
        
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
        
        self.dbRef.removeAllObservers()
        
        paymentchanged = false
        
        //GPS
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()// thi smean that it won't work when app in the background - consider change it accordingly.
        self.locationManager.startUpdatingLocation()

        //keyboard adjustment
        NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardNotificationwillShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardNotificationwillHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: self.view.window)
        
        if self.employerFromMain == "Add new dog" {
            
            
            self.pName.text = ""
            self.pLastName.text = ""
            self.pEmail.text = ""
            self.pCell.text = ""
            self.pAddress.text = ""
            self.locationXUpdate = "0"
            self.locationYUpdate = "0"
            self.paymentUpdate = "Round"
            self.pRate .text = ""
            self.pPetName.text = ""
            self .pRem.text = ""
            activeEmployer.image = Vimage
            activeButton.setTitle("", for: .normal)
            activeEmployerSwitch = false
            activeGpsSwitch = true
            imageGps.image = emptyVimage
            connect.setOn(false, animated: true)
            
            bills.isEnabled = false
            trash.isEnabled = false
            leash.isEnabled = false
            obligatory .isHidden = false
            obligatoryIn()
            obligatoryOut()
            
        } else {        bringEmployerData()
            
            bills.isEnabled = true
            trash.isEnabled = true
            leash.isEnabled = true
            obligatory .isHidden = true

        }


        lbl = "Family file"
        self.title = lbl

        
        
        
        pDogImage.clipsToBounds = true
        pDogImage.layer.cornerRadius = 32
        
        
       // self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Grass12")!)
       // self.view.insertSubview(backgroundImage, at: 0)
        
      
        
            let saveRecord = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(saveToDB(_:)))
            navigationItem.rightBarButtonItem = saveRecord
        
        if self.paymentUpdate == "Normal" {rateTitle.text = "Hour rate"} else if self.paymentUpdate == "Round" {  rateTitle.text = "Session rate"}
        if ViewController.fixedCurrency != nil {currencySign.text = (ViewController.fixedCurrency!)} else {currencySign.text = ""}
        self.pEmail.addTarget(self, action: #selector(canInvite), for: .editingDidEnd)
        
        

        
    }//end of view did load ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
        override func viewDidDisappear(_ animated: Bool) {
        self.locationManager.stopUpdatingLocation()}
    
        deinit {NotificationCenter.default.removeObserver(self) }

        override func viewDidAppear(_ animated: Bool) {
            self.locationManager.startUpdatingLocation()

        //bringEmployerData()
        }//view did appear end
 
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        }
    
    
    
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print ("GPS ERORR!!!!!!")
        }
    
        func saveToDB(_ sender: AnyObject) {
            if pRate.text == "" {pRate.text = "0.0"}
        print("rateeeee\(RateUpdate)")
       
        if self.imageGps.image == self.emptyVimage { messageInstruction = " If you would set pet's home GPS location, you would enjoy validation of In/Out records.";}
        if self.paymentUpdate == "" { messageInstruction = " If you would set rate per Session/hour , you would enjoy records' bill calculation."}
        if self.imageGps.image == self.emptyVimage || self.paymentUpdate == "" {titleInstruction = "Save Anyway"} else {titleInstruction = "Yes"}
            
        if self.pLastName.text != "" { // this check that last name is filled and it is filled
            if connectSetter == "Yes" { message2 = "As 'connect' is on, you would save in your app the presented current fields. Are You Sure?"} else {
            if self.imageGps.image == self.emptyVimage || self.paymentUpdate == ""  {message2 = messageInstruction} else
            { message2 = "Are You Sure?"}}
       
        let alertController = UIAlertController(title: ("Save Setting") , message: self.message2, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        }
        
        let updateDBAction = UIAlertAction(title: titleInstruction, style: .default) { (UIAlertAction) in
        ViewController.refresh = true
        if self.employerFromMain != "Add new dog" {
            
        print ("id in update \(self.employerID)")
            
        if self.activeEmployerSwitch == true {self.activeEmployerSwitch = false} else {self.activeEmployerSwitch = true}
            
        self.dbRefEmployers.child(self.employerID).updateChildValues(["fName" : self.pName.text!, "fLastName": self.pLastName.text!,"fMail": self.pEmail.text!, "fCell": self.pCell.text!, "fAddress": self.pAddress.text!,"fPetName": self.pPetName.text!, "fRem" : self.pRem.text!, "fLocationX": self.locationXUpdate!, "fLocationY": self.locationYUpdate!, "fEmployer":self.pLastName.text!,"fActive" : self.activeEmployerSwitch!])
           
            //in firebase under url
            print ("employerId to store cache and FB:\(self.employerID)")
            let dbStorageRef = FIRStorage.storage().reference().child("employerImages").child(self.employerID)
            if let uploadTask = UIImageJPEGRepresentation(self.pDogImage.image!, CGFloat(0.1)){
            dbStorageRef.put(uploadTask, metadata: nil, completion: { (metadata, error) in
            if error != nil {
            print (error as Any)
            return
            }
            
            self.dbRefEmployers.child(self.employerID).updateChildValues(["fImageRef":(metadata?.downloadURL()?.absoluteString)! as Any ])
            }) //end of dbref
            }//end of storage of pictures
           
            //update pic in chache for old employee
            MyImageCache.sharedCache.setObject(self.pDogImage.image as AnyObject, forKey: self.employerID as AnyObject)
            
            self.dbRefEmployers.child(self.employerID).child("myEmployees").child(self.employeeID).updateChildValues(["fConnect": self.connectSetter!,"fPayment": self.paymentUpdate , "fEmployerRate": Double( self.pRate.text!)!])//add employer rate per employee
            
            if self.activeEmployerSwitch == false {  self.dbRefEmployees.child(self.employeeID).child("myEmployers").updateChildValues([self.employerID:10])}
            else {self.dbRefEmployees.child(self.employeeID).child("myEmployers").updateChildValues([self.employerID:5])}
            
            

        self.navigationController!.popViewController(animated: true)
        } // end of update of an old employer
                
        else{
        let employerRefence = self.dbRefEmployers.childByAutoId()
            employerRefence.setValue(["fName" : self.pName.text!, "fLastName": self.pLastName.text!,"fMail": self.pEmail.text!, "fCell": self.pCell.text!, "fAddress": self.pAddress.text!,"fPetName": self.pPetName.text!, "fRem" : self.pRem.text!, "fLocationX": self.locationXUpdate!, "fLocationY": self.locationYUpdate!, "fEmployer":self.pLastName.text!, "finProcess" : "", "fEmployerReg":employerRefence.key, "fActive" : true, "fImageRef":"https://firebasestorage.googleapis.com/v0/b/employeetimer.appspot.com/o/employerImages%2F47574737_s.jpg?alt=media&token=48983dc3-ca8d-4d9f-9b6d-3df6d756c480"
        ])//end of set value
       
            
            //update pic in chache for new employee
        MyImageCache.sharedCache.setObject(self.pDogImage.image as AnyObject, forKey: employerRefence.key as AnyObject)

            //in firebase under url

            let dbStorageRef = FIRStorage.storage().reference().child("employerImages").child(employerRefence.key)
            if let uploadTask = UIImageJPEGRepresentation(self.pDogImage.image!, CGFloat(0.1))
            
            {
                dbStorageRef.put(uploadTask, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print (error as Any)
                        
                        return
                    }
                    else {
                        print (metadata!)
                        
                        self.dbRefEmployers.child(employerRefence.key).updateChildValues(["fImageRef":(metadata?.downloadURL()?.absoluteString)! as Any ])}
                }) //end of dbref
                
            }//end of storage of pictures
            
        self.employerID = employerRefence.key
        self.dbRefEmployees.child(self.employeeID).child("myEmployers").updateChildValues([self.employerID:5])//add employer to my employers of employee
        self.dbRefEmployers.child(self.employerID).child("myEmployees").child(self.employeeID).setValue(["fPayment": self.paymentUpdate, "fConnect": "No", "fEmployerRate": Double( self.pRate.text!)!])//add employer rate per employee
                
        self.navigationController!.popViewController(animated: true)
            
            
        } // end of adding a new user /else
            
        }//end of Yes option
        
        alertController.addAction(cancelAction)
        alertController.addAction(updateDBAction)
        self.present(alertController, animated: true, completion: nil)
        } // end of last name is filled
            
    
        else { //last name is not filled
        let alertController2 = UIAlertController(title: ("Save Setting") , message: ("Last name is a requiered field"), preferredStyle: .alert)
        let cancelAction2 = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
        }
        alertController2.addAction(cancelAction2)
        self.present(alertController2, animated: true, completion: nil)
        } // end of last name is not filled
        }//end of savetoDB
   
        //photo handling
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            if let pickedImage: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pDogImage.image =  pickedImage

            //storage of pictures
            //in cache under employerID
                //if employerFromMain != "Add new dog" { MyImageCache.sharedCache.setObject(pickedImage as AnyObject, forKey: employerID as AnyObject)}


                
            }//end of if let picked image
            imagePicker.dismiss(animated: true, completion: nil )
            }//end of imagepicked controller
    
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.dismiss(animated: true, completion: nil)
            }
    
    
    
        //sourcePicker
            func sourcePicPicker(){
            let picSource = UIAlertController(title: ("Add Pet's Picture") , message: (""), preferredStyle: .alert)
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (UIAlertAction) in
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(self.imagePicker, animated:  true, completion: nil)
            }
            let AlbumAction = UIAlertAction(title: "Album", style: .default) { (UIAlertAction) in
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(self.imagePicker, animated:  true, completion: nil)
            }
    
            picSource.addAction(AlbumAction)
            picSource.addAction(cameraAction)
            self.present(picSource, animated: true, completion: nil)
            }//end of source picker
    
    
        @IBAction func call(_ sender: Any) {
        print (pCell)
        print(cellUpdate)
        let    url:NSURL = NSURL(string: "tel://\(cellUpdate)")!
        UIApplication.shared.open(url as URL, options: [:], completionHandler:nil)
        }
    
        //mail export
        func alert () {
        print("export")
        let alertController = UIAlertController(title: "Preapre client a mail ", message: "Are You Sure?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        //nothing
        }//end of cancel
        
        let exportAction = UIAlertAction(title: "Yes, compose it.", style: .default) { (UIAlertAction) in
        let mailComposeViewController = self.configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
        self.present(mailComposeViewController, animated: true, completion: nil)
        }
        else{
        self.showSendmailErrorAlert()
        }
        }//end of yes
        
        alertController.addAction(cancelAction)
        alertController.addAction(exportAction)
        present(alertController, animated: true, completion: nil)
        }
    
        func  configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setSubject("PerSession mail")
        mailComposerVC.setMessageBody("Hello", isHTML: false)
        mailComposerVC.setToRecipients([emailUpdate])
        return mailComposerVC
        }//end of configure
    
        func  invitationMail() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setSubject("Invitation to connect through my pet care app.")
        mailComposerVC.setMessageBody("Hello,\r\n I am using PerSession app to support my pet care activity . You are invited to use it as well, so we can connect and see the same picture. Currently , it is avilable in Apple app-store and soon it would be avilable in Android as well. I attached a download link. .\r\n Bye\(ViewController.fixedName!) \(ViewController.fixedLastName!).", isHTML: false)
        mailComposerVC.setToRecipients([pEmail.text!])
        return mailComposerVC
    }//end of configure
    
        func showSendmailErrorAlert() {
        let sendMailErorrAlert = UIAlertController(title:"Could Not Send Email", message: "Your device could not send e-mail. Please check e-mail configuration and try again.",preferredStyle: .alert)
        sendMailErorrAlert.message = "jhsgajshgj"
        //seems that it does not work check!!!!
        }//end of error alert
    
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        }
    
    
        //sms
        func sendMessage() {
        let messageVC = MFMessageComposeViewController()
        messageVC.body = "Hi,\r\n I am using PerSession app to manage my pet care activity . \r\n You are invited to use it as well, so we can connect and see the same picture. \r\n Currently , it is avilable in Apple app-store and soon it would be avilable in Android as well. I am sending a download link . Bye. \(ViewController.fixedName!) \(ViewController.fixedLastName!) "
        messageVC.recipients = [pCell.text!]
        messageVC.messageComposeDelegate = self
        present(messageVC, animated: true, completion: nil)
        }//end of send message
    
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
        }//end of func message compose
    
    
    
    func bringEmployerData() {
        print ("employerfrom main:\(employerFromMain)")
        if employerFromMain != "Add new dog" {
            dbRefEmployers.child(self.employerID).child("myEmployees").queryOrderedByKey().queryEqual(toValue: employeeID).observeSingleEvent(of:.childAdded, with: { (snapshot) in
                self.paymentUpdate = String(describing: snapshot.childSnapshot(forPath: "fPayment").value!) as String!
                print(self.paymentUpdate)

                if self.paymentUpdate == "Normal" {
                    self.pPayment.selectedSegmentIndex = 0
                    self.pPayment.sendActions(for: .valueChanged)
                    
                } else if self.paymentUpdate == "Round" { self.pPayment.selectedSegmentIndex = 1
                    self.pPayment.sendActions(for: .valueChanged)}
                
                print (self.RateUpdate)
                self.RateUpdate = Double(snapshot.childSnapshot(forPath: "fEmployerRate").value! as! Double)
                if self.RateUpdate != 0.0 { self.pRate.text = String(self.RateUpdate)} else {self.pRate.text = ""}
                
                self.connectSetter = String(describing: snapshot.childSnapshot(forPath: "fConnect").value! as! String)
                if self.connectSetter == "Yes"{ self.connect.setOn(true, animated: true)} else { self.connect.setOn(false, animated: true)}
                print ("dwdsd4\(self.connectSetter!)")
                
            })//end of dbrefemployers
            
           
            
            dbRefEmployers.queryOrderedByKey().queryEqual(toValue: employerID).observeSingleEvent(of: .childAdded, with: { (snapshot) in
                self.nameUpdate = String(describing: snapshot.childSnapshot(forPath: "fName").value!) as String!
                self.lastNameUpdate = snapshot.childSnapshot(forPath: "fLastName").value! as! String
                self.addressUpdate = String(describing: snapshot.childSnapshot(forPath: "fAddress").value!) as String!
                self.petNameUpdate = String(describing: snapshot.childSnapshot(forPath: "fPetName").value!) as String!
                self.cellUpdate = String(describing: snapshot.childSnapshot(forPath: "fCell").value!) as String!
                self.locationXUpdate = String(describing: snapshot.childSnapshot(forPath: "fLocationX").value!) as String!
                self.locationYUpdate = String(describing: snapshot.childSnapshot(forPath: "fLocationY").value!) as String!

                
                self.activeEmployerSwitch =  snapshot.childSnapshot(forPath: "fActive").value! as? Bool
                if self.activeEmployerSwitch == true { self.activeEmployer.image = self.Vimage
                    self.activeButton.setTitle("", for: .normal)
                    self.activeEmployerSwitch = false} else {self.activeEmployer.image = self.emptyVimage
                    self.activeButton.setTitle("Inactive", for: .normal)
                    self.activeEmployerSwitch = true}
                
                
                
                self.emailUpdate = snapshot.childSnapshot(forPath: "fMail").value! as! String //probelm when set on connect it i sdeleted
                self.pEmail.text = self.emailUpdate
                print("hfghgfh0\(self.cEmployerRef)")

                //connection to the employers app
                self.dbRefcEmployers.queryOrdered(byChild: "cMail").queryEqual(toValue: self.emailUpdate).observeSingleEvent(of: .childAdded, with: { (snapshot) in
                    self.cEmployerRef = String(describing: snapshot.key) as String!
                    
                    
                    print("hfghgfh\(self.cEmployerRef)")
                    self.dbRefcEmployers.queryOrderedByKey().queryEqual(toValue:self.cEmployerRef).observeSingleEvent(of: .childAdded, with: { (snapshot) in
                    
                    self.cNameUpdate = String(describing: snapshot.childSnapshot(forPath: "cName").value!) as String!
                    if self.connectSetter == "Yes" && self.cNameUpdate != "" {self.pName.text = self.cNameUpdate;self.pName.isEnabled = false}
                    else {  self.pName.text = self.nameUpdate; self.pName.isEnabled = true}
                        
                        self.isConnected()
                    
                    self.cLastNameUpdate = String(describing: snapshot.childSnapshot(forPath: "cLastName").value!) as String!
                    if self.connectSetter == "Yes" && self.cLastNameUpdate != "" {self.pLastName.text = self.cLastNameUpdate;self.pLastName.isEnabled = false}
                    else {  self.pLastName.text = self.lastNameUpdate; self.pLastName.isEnabled = true}
                    
                    self.cAddressUpdate = String(describing: snapshot.childSnapshot(forPath: "cAddress").value!) as String!
                    if self.connectSetter == "Yes" && self.cAddressUpdate != "" {self.pAddress.text = self.cAddressUpdate;self.pAddress.isEnabled = false}
                    else {  self.pAddress.text = self.addressUpdate; self.pAddress.isEnabled = true}
                    
                    self.cPetNameUpdate = String(describing: snapshot.childSnapshot(forPath: "cPetName").value!) as String!
                    if self.connectSetter == "Yes" && self.cPetNameUpdate != "" {self.pPetName.text = self.cPetNameUpdate; self.pPetName.isEnabled = false}
                    else {  self.pPetName.text = self.cPetNameUpdate; self.pPetName.isEnabled = true}
                    
                    self.cCellUpdate = String(describing: snapshot.childSnapshot(forPath: "cCell").value!) as String!
                    if self.connectSetter == "Yes" && self.cCellUpdate != "" {self.pCell.text = self.cCellUpdate; self.pCell.isEnabled = false}
                    else {  self.pCell.text = self.cCellUpdate; self.pCell.isEnabled = true}
                    
                    self.cLocationXUpdate = String(describing: snapshot.childSnapshot(forPath: "cLocationX").value!) as String!
                        if self.connectSetter == "Yes" && self.cLocationXUpdate != "0" {self.locationXUpdate = self.cLocationXUpdate; self.GPStitle.isEnabled = false;self.imageGps.alpha = 0.5}
                        else { self.GPStitle.isEnabled = true;self.imageGps.alpha = 1 }
                    self.cLocationYUpdate = String(describing: snapshot.childSnapshot(forPath: "cLocationY").value!) as String!
                    //if self.connectSetter == "Yes" && self.cLocationYUpdate != "0" {self.locationYUpdate = self.cLocationYUpdate; self.GPStitle.isEnabled = false; self.GPStitle.alpha = 0.5}
                   // else { self.GPStitle.isEnabled = true;self.GPStitle.alpha = 1}
                    
                    if self.locationXUpdate == "0" {self.imageGps.image = self.emptyVimage} else {self.imageGps.image = self.Vimage}
                
                        //  if self.connectSetter == "Yes" && self.cProfileImage != "" {let profileImageUrl = cProfileImage;  self.takePic.isEnabled = false}
                    //else { self.takePic.isEnabled = true}
                    
                    
                
                })//end of dbref from dbRefcEmployers.queryOrdered(byChild: "cMail").queryEqual(toValue: "mikaenat@gmail.com")
                })//end of    self.dbRefcEmployers.queryOrderedByKey().queryEqual(toValue:self.cEmployerRef)
                
                 if self.cEmployerRef == "" {self.pName.text = self.nameUpdate; self.pName.isEnabled = true
                    self.pLastName.text = self.lastNameUpdate; self.pLastName.isEnabled = true
                    self.pAddress.text = self.addressUpdate;self.pAddress.isEnabled = true
                    self.pPetName.text = self.petNameUpdate;self.pPetName.isEnabled = true
                    self.pCell.text = self.cellUpdate; self.pCell.isEnabled = true
                    
                    self.canInvite()
                    

                }
            
                
                if self.locationXUpdate != "0"  { self.imageGps.image = self.Vimage; self.activeGpsSwitch = false } else { self.imageGps.image = self.emptyVimage; self.activeGpsSwitch = true }
                
                
                
                
                self.remUpdate = snapshot.childSnapshot(forPath: "fRem").value as! String
                self.pRem.text = self.remUpdate
                
               // self.EmployerRef = String(describing: snapshot.childSnapshot(forPath: "fEmployer").value!) as String!
                self.EmployerRef = self.lastNameUpdate

                
                
                //bring image
                if let cachedImage = MyImageCache.sharedCache.object(forKey: self.employerID as AnyObject) as? UIImage //bring from cache
                { DispatchQueue.main.async {
                    self.pDogImage.image = cachedImage
                    }
                }//end of bring image from cache
                else{
                    //bring from firebase
                    if let profileImageUrl = snapshot.childSnapshot(forPath: "fImageRef").value as! String! {
                        print (profileImageUrl)
                        let url = URL(string: profileImageUrl)!
                        URLSession.shared.dataTask(with: url, completionHandler: { (Data, response, error) in
                            if error != nil {
                                print (error as Any)
                            }
                            DispatchQueue.main.async {
                                self.pDogImage.image = UIImage(data: Data!)!
                            }
                            
                            //  upload to cache
                            MyImageCache.sharedCache.setObject(UIImage(data: Data!)!, forKey: self.employerID as AnyObject , cost: (Data?.count)!) // upload to cache
                        }) .resume()
                    }//end of if let
                }//end of else
            })  {(error) in //end of dbref
                print(error.localizedDescription)}//end of second dbrefemployers
        }//end of if employers is not new
    }//end of bring employer data
    
    //func for invite
    func canInvite() {
        print("cemployerref\(self.cEmployerRef)")
        
        if pEmail.text == "" {connect.isEnabled = false;connectSetter = "No" ;connect.setOn(false, animated: true); connectTitle.alpha = 0.5; message3 = "Connect requiered pet's family email adrress."; self.invite.isEnabled = false;invite.isHidden = true;  self.invite.alpha = 0.5}// change hinvite is hidden upon connect.
        else {connect.isEnabled = true;  connectTitle.alpha = 1;
            message3 = "When Pet's family join the app - 'Connect' enables you share information. Left fields above, would be updated (if filled by pet's family). In addition , Pet's records would be seen but not updated by pet's family.";
            self.invite.isHidden = true;invite.setTitleColor(blackColor, for: .normal);self.invite.isEnabled = true; self.invite.alpha = 1; //change invite is hidden upon connect.
            isConnected()
            print("cemployerref\(self.cEmployerRef)")
            
       
        }//end of else
        
    
    }//end of caninvite
    
    func isConnected() {
        if connectSetter == "Yes" && cEmployerRef != "" {print("connection is OK");invite.setTitleColor(blueColor, for: .normal); invite.setTitle("Paired", for: .normal);invite.isHidden = true;//change hinvite is hidden upon connect.
            invite.isEnabled = false;message3 = "'Connect' enables you share information. Left fields above,  updated (if filled by pet's family). In addition , Pet's records can be seen but not updated by pet's family."} else {print ("no connection"); invite.setTitle("(Invite)", for: .normal); invite.isEnabled = true}
        if connectSetter == "No" && cEmployerRef != "" {print ("paired but not connected"); invite.isHidden = true;message3 = "When you would set 'connect' to 'On' -  Left fields above, would be updated (if filled by pet's family). In addition , Pet's records would be seen but not updated by pet's family."}

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "billsFromDogFile") {
            let secondView = segue.destination as? biller
            secondView?.employerFromMain = employerFromMain
            secondView?.employerID = self.employerID
            secondView?.employeeID = self.employeeID
        }
         else if (segue.identifier == "recordsFromDogFile"){
            
            let recordsView = segue.destination as? newVCTable
            recordsView?.employerFromMain = employerFromMain
            recordsView?.employerID = employerID
            recordsView?.employeeID =  employeeID
        }

            
        }
    

    
    
    
        //adjustkeyboard
        func KeyboardNotificationwillShow(notification: NSNotification){
                if pRate .isEditing || pRem.isEditing
            { 
            UIView.animate(withDuration: 0.8, animations: {Void in
                
          //   scroller
               self.scrollerView.contentOffset.y = 150
            })
            }
            
        }//end of func keyboard notification
    
        func KeyboardNotificationwillHide(notification: NSNotification){
            UIView.animate(withDuration: 0.4, animations: {Void in
            self.scrollerView.contentOffset.y = 0
                })
        }//end of willhide
    


        //delete a dog alert
        func dogDeleteAlert () {
        let alertController3 = UIAlertController(title: ("Delete") , message: ("This would delete your access to  this client's information including  master data and records. Are You sure?"), preferredStyle: .alert)
        let cancelAction3 = UIAlertAction(title: "NO", style: .cancel) { (UIAlertAction) in
        }
        let deleteAction3 = UIAlertAction(title: "YES", style: .default) { (UIAlertAction) in
        ViewController.refresh = true
        self.dbRefEmployees.child(self.employeeID).child("myEmployers").child(self.employerID).removeValue()
        self.dbRefEmployers.child(self.employerID).updateChildValues(["fActive" : "Deleted"])//chamge status to deleted
        self.navigationController!.popViewController(animated: true)

        print ("delete")
        }
        alertController3.addAction(cancelAction3)
        alertController3.addAction(deleteAction3)
        present(alertController3, animated: true, completion: nil)
        }//delete dog alert end
    
    
  
    
    
    //locTION DELEGTE METHODS
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        }
    
    
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
    
    
       
    func noFB() {
        let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                print("Connected1")
            } else {
                print("Not connected1")
                self.alert30()
            }
        })
    }
    
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
    
    ///////////////////////////////////////alerts
    
    func alert30(){
        let alertController30 = UIAlertController(title: ("No connection") , message: "Currently there is no connection with database. Please try later.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        }
        
        alertController30.addAction(OKAction)
        self.present(alertController30, animated: true, completion: nil)
    }
    
    func alert8(){
        let alertController4 = UIAlertController(title: ("Payment methood") , message: "Set per hour/Session to affect calculation.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        }
        
        alertController4.addAction(OKAction)
        self.present(alertController4, animated: true, completion: nil)
    }
    func alert9(){
        let alertController4 = UIAlertController(title: ("GPS") , message: "Set pet's GPS home location to current location  to enable GPS validation for In/Out.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        }
        
        alertController4.addAction(OKAction)
        self.present(alertController4, animated: true, completion: nil)
    }
    func alert20(){
        let alertController20 = UIAlertController(title: ("GPS") , message: "There is no GPS connection, Check GPS setting turned on or try in a different location.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        }
        
        alertController20.addAction(OKAction)
        self.present(alertController20, animated: true, completion: nil)
    }
    func alert5(){
        let alertController5 = UIAlertController(title: ("Connect") , message: self.message3, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        }
        
        alertController5.addAction(OKAction)
        self.present(alertController5, animated: true, completion: nil)
    }
    
    func alert512(){
        let alertController512 = UIAlertController(title: ("Change payment methood") , message: "Important! Did you check that there are no unbilled sessions for that dog before you change payment methood? ", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
        }
        let noAction = UIAlertAction(title: "No", style: .default) { (UIAlertAction) in
            if self.pPayment.selectedSegmentIndex == 1{ self.pPayment.selectedSegmentIndex = 0 } else {self.pPayment.selectedSegmentIndex = 1}
            
            
        }
        
        alertController512.addAction(yesAction)
        alertController512.addAction(noAction)

        self.present(alertController512, animated: true, completion: nil)
    }
    
    func alert50(){
        let alertController50 = UIAlertController(title: ("Internet Connection") , message: " There is no internet - Check communication avilability.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        }
        
        alertController50.addAction(OKAction)
        self.present(alertController50, animated: true, completion: nil)
    }
    //invitation
    func invitation() {
        let alertController2 = UIAlertController(title: ("Invitation") , message: ("Prepare app invitation SMS for your pet family?"), preferredStyle: .alert)
        let cancelAction2 = UIAlertAction(title: "No", style: .cancel) { (UIAlertAction2) in
           // self.navigationController!.popViewController(animated: true)
        }//end of cancel
        let updateDBAction2 = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction2) in
            self.sendMessage()
            //self.navigationController!.popViewController(animated: true)
        }//end of update DBA
        
        alertController2.addAction(cancelAction2)
        alertController2.addAction(updateDBAction2)
        self.present(alertController2, animated: true, completion: nil)
    }
    
    //choice of invitation
    func alert15(){
        let alertController15 = UIAlertController(title: ("Send Invitation") , message: "", preferredStyle: .alert)
         let OKAction = UIAlertAction(title: "SMS Invitation", style: .default) { (UIAlertAction) in
               self.invitation() }
        
        let OKAction2 = UIAlertAction(title: "Mail Invitation", style: .default) { (UIAlertAction) in
           let mailComposeViewController = self.invitationMail()
                if MFMailComposeViewController.canSendMail() {
                    self.present(mailComposeViewController, animated: true, completion: nil)
                }
                else{
                    self.showSendmailErrorAlert()
                }} //end of okaction2 
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            }

        

        if self.pCell.text != "" {  alertController15.addAction(OKAction)}
        if self.pEmail.text != "" {alertController15.addAction(OKAction2)}
        alertController15.addAction(cancelAction)
        self.present(alertController15, animated: true, completion: nil)
    
    }

        

    
        

    

        }//end!!!////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


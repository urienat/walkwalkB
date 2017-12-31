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
import FirebaseAuth

class dogFile: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate ,MFMessageComposeViewControllerDelegate {

    let Vimage = UIImage(named: "V")
    let emptyVimage = UIImage(named: "emptyV")
    var perSessionImage = UIImage(named:"perSessionImage")?.withRenderingMode(.alwaysTemplate)

    var blueColor = UIColor(red :22/255.0, green: 131/255.0, blue: 248/255.0, alpha: 1.0)


    var messageInstruction = ""
    var titleInstruction = ""

    var adjuster = 0
    
    
    var wrongField:String?
    
    var message :String?
    var message2 :String?
    var message3 :String?
    
    var activeEmployerSwitch: Bool?
    
    var employerID = ""
    var EmployerRef = ""
    var lbl = ""
    var employeeID = ""
    var employerFromMain = ""
    
    var cEmployerRef = ""
    
    var employerArray: [String:Int] = [:]
    var employerArray2: [String] = []
    var employerArray3: [String] = []

    let dbRef = FIRDatabase.database().reference()
    let dbRefEmployers = FIRDatabase.database().reference().child("fEmployers")
    let dbRefcEmployers = FIRDatabase.database().reference().child("cEmployers")
    let dbRefEmployees = FIRDatabase.database().reference().child("fEmployees")


    @IBOutlet weak var scrollerView: UIScrollView!
    
    @IBOutlet weak var trash: UIBarButtonItem!
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
    
    @IBOutlet weak var pLastName: UITextField!
    var lastNameUpdate = ""
    
    @IBOutlet weak var pEmail: UITextField!
    var emailUpdate = ""
    
    @IBOutlet weak var pCell: UITextField!
    var cellUpdate = ""
    
    @IBOutlet weak var pAddress: UITextField!
    var addressUpdate = ""
    
    @IBOutlet weak var rateTitle: UILabel!
    @IBOutlet weak var pRate: UITextField!
    var RateUpdate = 0.0
    @IBOutlet weak var currencySign: UILabel!
    
    

    

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
    
    @IBAction func sendMail(_ sender: Any) {alert()}
    
    override func viewDidLoad() { ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        super.viewDidLoad()
        ViewController.refresh = false
        
        //connectivity
        if Reachability.isConnectedToNetwork() == true
        {print("Internet Connection Available!")
        }else{
        print("Internet Connection not Available!")
        alert50()
        }
        
        self.dbRef.removeAllObservers()
        
        
        //keyboard adjustment
        NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardNotificationwillShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardNotificationwillHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: self.view.window)
        
        if self.employerFromMain == "Add new dog" {
            self.lbl = "New Account"
            self.title = lbl

            self.pName.text = ""
            self.pLastName.text = ""
            self.pEmail.text = ""
            self.pCell.text = ""
            self.pAddress.text = ""
            self.pRate .text = ""
            self .pRem.text = ""
            activeEmployer.image = Vimage
            activeButton.setTitle("", for: .normal)
            activeEmployerSwitch = false
            
            trash.isEnabled = false
            obligatory .isHidden = false
            obligatoryIn()
            obligatoryOut()
            
        } else {
            self.lbl = ("\(employerFromMain)")
            self.title = lbl
                
            bringEmployerData()
            trash.isEnabled = true
            obligatory .isHidden = true
        }


        pDogImage.clipsToBounds = true
        pDogImage.layer.cornerRadius = 30
        
        let saveRecord = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(checkDuplicate))
        //let saveRecord = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(functionQ(handleComplete:saveToDB)))

        
        navigationItem.rightBarButtonItem = saveRecord
        
        rateTitle.text = "Rate"
        if ViewController.fixedCurrency != nil {currencySign.text = (ViewController.fixedCurrency!)} else {currencySign.text = ""}
        
    }//end of view did load ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
        deinit {NotificationCenter.default.removeObserver(self) }

        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        }
    
    func checkDuplicate(){

        if pRate.text == "" {pRate.text = "0.0"}
        
        if self.pLastName.text == "" || self.pName.text == "" {
        message2 =  "Name & Last name are requiered fields"
        alert54()
        } // end of name or  last name is not filled
            
        self.dbRefEmployees.child(employeeID).queryOrderedByValue().observeSingleEvent(of: .value, with: { (snapshot) in
        self.employerArray = snapshot.childSnapshot(forPath: "myEmployers").value! as! [String:Int]
        self.employerArray2 = Array(self.employerArray.keys) // for Dictionary
            print (self.employerArray)
            print (self.employerArray2)
            

        for eachEmployer in 0...(self.employerArray2.count-1){
            self.dbRefEmployers.child(self.employerArray2[eachEmployer]).observeSingleEvent(of: .value, with: { (snapshot) in
        let employerNameforCheck = String(describing: snapshot.childSnapshot(forPath: "fName").value!) as String!
        let employerLastNameForCheck = String(describing: snapshot.childSnapshot(forPath: "fEmployer").value!) as String!
                
        self.employerArray3.append("\(employerNameforCheck!) \(employerLastNameForCheck!)")
                print ("1")

                
        if self.employerArray3.contains("\(self.pName.text!) \(self.pLastName.text!)") {
            self.message2 = " Can't save account as \(self.pName.text!) \(self.pLastName.text!) account is already set."
            print("contatain"); self.alert54()
        
                }//if contaons
        else {
            if eachEmployer == self.employerArray2.count-1 {self.saveToDB()}
                }
        })
        }//end of loop
        })

        }//end of func

    
        
    
    
        func saveToDB() {
            
        print ("in savetodb)")
            
        let alertController = UIAlertController(title: ("Save Setting") , message: "Are you Sure?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        }
        
        let updateDBAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
        ViewController.refresh = true
        if self.employerFromMain != "Add new dog" {
        if self.activeEmployerSwitch == true {self.activeEmployerSwitch = false} else {self.activeEmployerSwitch = true}
            
        self.dbRefEmployers.child(self.employerID).updateChildValues(["fName" : self.pName.text!,"fMail": self.pEmail.text!, "fCell": self.pCell.text!, "fAddress": self.pAddress.text!, "fRem" : self.pRem.text!, "fEmployer":self.pLastName.text!,"fActive" : self.activeEmployerSwitch!])
           
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
            
            self.dbRefEmployers.child(self.employerID).child("myEmployees").child(self.employeeID).updateChildValues(["fEmployerRate": Double( self.pRate.text!)!])//add employer rate per employee
            
            if self.activeEmployerSwitch == false {  self.dbRefEmployees.child(self.employeeID).child("myEmployers").updateChildValues([self.employerID:10])}
            else {self.dbRefEmployees.child(self.employeeID).child("myEmployers").updateChildValues([self.employerID:5])}
        
        self.navigationController!.popViewController(animated: true)
        } // end of update of an existed employer
        else{
        let employerRefence = self.dbRefEmployers.childByAutoId()
        employerRefence.setValue(["fName" : self.pName.text!,"fMail": self.pEmail.text!, "fCell": self.pCell.text!, "fAddress": self.pAddress.text!, "fRem" : self.pRem.text!,  "fEmployer":self.pLastName.text!, "fEmployerReg":employerRefence.key, "fActive" : true, "fImageRef":"https://firebasestorage.googleapis.com/v0/b/employeetimer.appspot.com/o/employerImages%2F47574737_s.jpg?alt=media&token=48983dc3-ca8d-4d9f-9b6d-3df6d756c480"
        ])//end of set value
            
        //update pic in chache for new employee
        MyImageCache.sharedCache.setObject(self.pDogImage.image as AnyObject, forKey: employerRefence.key as AnyObject)

        //in firebase under url
        let dbStorageRef = FIRStorage.storage().reference().child("employerImages").child(employerRefence.key)
        if let uploadTask = UIImageJPEGRepresentation(self.pDogImage.image!, CGFloat(0.1))
        {dbStorageRef.put(uploadTask, metadata: nil, completion: { (metadata, error) in
        if error != nil {print (error as Any)
        return
        }else {
        print (metadata!)
        self.dbRefEmployers.child(employerRefence.key).updateChildValues(["fImageRef":(metadata?.downloadURL()?.absoluteString)! as Any ])}
        }) //end of dbref
                
        }//end of storage of pictures
            
        self.employerID = employerRefence.key
        self.dbRefEmployees.child(self.employeeID).child("myEmployers").updateChildValues([self.employerID:5])//add employer to my employers of employee
        self.dbRefEmployers.child(self.employerID).child("myEmployees").child(self.employeeID).setValue(["fEmployerRate": Double( self.pRate.text!)!])//add employer rate per employee
                
        self.navigationController!.popViewController(animated: true)
            
        } // end of adding a new user /else
        }//end of Yes option
        
        alertController.addAction(cancelAction)
        alertController.addAction(updateDBAction)
        self.present(alertController, animated: true, completion: nil)
        
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
    
        func sendMessage() {
        let messageVC = MFMessageComposeViewController()
        messageVC.body = "Hi,\r\n I am using PerSession app to manage my activity . \r\n You are invited to use it as well, so we can connect and see the same picture. \r\n Currently , it is avilable in Apple Appstore and soon it would be avilable in Android as well. I am sending a download link . Bye. \(ViewController.fixedName!) \(ViewController.fixedLastName!) "
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
        if employerFromMain != "Add new dog" {
        dbRefEmployers.child(self.employerID).child("myEmployees").queryOrderedByKey().queryEqual(toValue: employeeID).observeSingleEvent(of:.childAdded, with: { (snapshot) in
            
        self.RateUpdate = Double(snapshot.childSnapshot(forPath: "fEmployerRate").value! as! Double)
        if self.RateUpdate != 0.0 { self.pRate.text = String(self.RateUpdate)} else {self.pRate.text = ""}
                
        })//end of dbrefemployers
            
        dbRefEmployers.queryOrderedByKey().queryEqual(toValue: employerID).observeSingleEvent(of: .childAdded, with: { (snapshot) in
        self.nameUpdate = String(describing: snapshot.childSnapshot(forPath: "fName").value!) as String!
        self.lastNameUpdate = String(describing: snapshot.childSnapshot(forPath: "fEmployer").value!) as String!

        self.addressUpdate = String(describing: snapshot.childSnapshot(forPath: "fAddress").value!) as String!
        self.cellUpdate = String(describing: snapshot.childSnapshot(forPath: "fCell").value!) as String!
        
        self.activeEmployerSwitch =  snapshot.childSnapshot(forPath: "fActive").value! as? Bool
        if self.activeEmployerSwitch == true { self.activeEmployer.image = self.Vimage
        self.activeButton.setTitle("", for: .normal)
        self.activeEmployerSwitch = false} else {self.activeEmployer.image = self.emptyVimage
        self.activeButton.setTitle("Inactive", for: .normal)
        self.activeEmployerSwitch = true}
    
        self.emailUpdate = snapshot.childSnapshot(forPath: "fMail").value! as! String //probelm when set on connect it i sdeleted
        self.pEmail.text = self.emailUpdate
        print("hfghgfh0\(self.cEmployerRef)")

      
    
        self.dbRefcEmployers.queryOrderedByKey().queryEqual(toValue:self.cEmployerRef).observeSingleEvent(of: .childAdded, with: { (snapshot) in
        
        self.pName.text = self.nameUpdate; self.pName.isEnabled = true
            
        
        self.pLastName.text = self.lastNameUpdate; self.pLastName.isEnabled = true
        
        self.pAddress.text = self.addressUpdate; self.pAddress.isEnabled = true
        
       self.pCell.text = self.cellUpdate; self.pCell.isEnabled = true
            
        //})//end of dbref from dbRefcEmployers.queryOrdered(byChild: "cMail").queryEqual(toValue: "mikaenat@gmail.com")
        })//end of    self.dbRefcEmployers.queryOrderedByKey().queryEqual(toValue:self.cEmployerRef)
                
        self.pName.text = self.nameUpdate; self.pName.isEnabled = true
        self.pLastName.text = self.lastNameUpdate; self.pLastName.isEnabled = true
        self.pAddress.text = self.addressUpdate;self.pAddress.isEnabled = true
        self.pCell.text = self.cellUpdate; self.pCell.isEnabled = true
        
        
            
            
        self.remUpdate = snapshot.childSnapshot(forPath: "fRem").value as! String
        self.pRem.text = self.remUpdate
        
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
        self.pDogImage.image = self.perSessionImage //I added to avoid teufut. if not stop cancel
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
    
        //adjustkeyboard
        func KeyboardNotificationwillShow(notification: NSNotification){
        if pRate .isEditing || pRem.isEditing
        {UIView.animate(withDuration: 0.8, animations: {Void in

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
        let alertController3 = UIAlertController(title: ("Delete") , message: ("This would delete your access to this account's information including master data and sessions. Are You sure?"), preferredStyle: .alert)
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
    
    
        //validation
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
    
    
    
        ///////////////////////////////////////////////////////////////////////////////////////////////////alerts
    
        func alert30(){
        let alertController30 = UIAlertController(title: ("No connection") , message: "Currently there is no connection with database. Please try later.", preferredStyle: .alert)
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
    
        func alert54(){
        let alertController54 = UIAlertController(title: ("Save error") , message: message2, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            
        }
        alertController54.addAction(OKAction)
        self.present(alertController54, animated: true, completion: nil)
        }


        //mail export
        func alert () {
        print("export")
        let alertController = UIAlertController(title: "Mail ", message: "Prepare a mail?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        //nothing
        }//end of cancel
        let exportAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        let mailComposeViewController = self.configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
        self.present(mailComposeViewController, animated: true, completion: nil)
        }else{
        self.showSendmailErrorAlert()
        }
        }//end of yes
        
        alertController.addAction(cancelAction)
        alertController.addAction(exportAction)
        present(alertController, animated: true, completion: nil)
        }

        }//end!!!////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


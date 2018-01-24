//
//  billerTable.swift
//  employee timer
//
//  Created by אורי עינת on 19.2.2017.
//  Copyright © 2017 אורי עינת. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import MessageUI

class biller: UIViewController, UITableViewDelegate,UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    let billDocument = UIImage(named: "billDocument")
    //let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
    let Vimage = UIImage(named: "due")
    let nonVimage = UIImage(named: "emptyV")
    let paidImage = UIImage(named: "paid")
    let canceledImage = UIImage(named: "cancelled")
    //let greenFilter = UIImage(named: "sandWatchGreen")
    let greenFilter = UIImage(named: "filterBlack")
    let redFilter = UIImage(named: "filterRed")
    var blueColor = UIColor(red :22/255.0, green: 131/255.0, blue: 248/255.0, alpha: 1.0)
    
    var counterForpresent:String?
    var lastPrevious = ""

    var accountAdress = ""
    var accountName = ""
    var accountLastName = ""
    var accountParnet = ""
    var balance:String?

    var seprator = "⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯"
    var seprator2 = "⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶⎶"


    var monthToHandle : Int = 0
    var yearToHandle : Int = 0
    var taxBillsToHandle:Bool = false
    var reportMode:Bool = false
    
    var paymentSys: String? = ""
    var paymentReference: String? = ""
    var recieptDate: String? = ""
    var billStatus:String? = "Billed"
    var documentName:String?
    var segmentedPressed:Int?
    
    var monthMMM: String?

    var billItems = [billStruct]()
    static var checkBoxBiller:Int = 0
    var BillArrayStatus = [String]()
    var BillArray = [String]()
    var statusTemp = "Billed"
    var StatusChoice = "Not Paid"
    var buttonRow = 0
    var recoveredBill:String?
    var recoveredreciept: String?
    var titleLbl = ""
    var cellId = "billerId"
    var billCounter = 0
    var taxCounter = 0.0
    var AmountCounter = 0.0
    var isFilterHidden = true
    var filterDecided :Int = 0
    
    //payment
    var recieptMailSaver : String?
    var refernceBlock :String?
    var taxForBlock : String?
    var taxationBlock :String?
    var paymentBlock :String?
    var billInfo :String?
    var taxId: String?
    var address :String?
    var midCalc:String?
    var midCalc2 :String?
    var  midCalc3 :String?
    var account :String?

    @IBOutlet weak var paymentTitle: UITextField!
    @IBOutlet weak var paymentView: UIView!
    @IBOutlet weak var paymentMethood: UISegmentedControl!
    
    @IBAction func paymentMethood(_ sender: Any) {
        print("payment pressed")
        //paymentMethood.isEnabled = false
        switch paymentMethood.selectedSegmentIndex {
        case 0: paymentSys = "cash"; referenceTxt.isHidden = true
        case 1: paymentSys = "check"; referenceTxt.isHidden = false
        case 2: paymentSys = "other"; referenceTxt.isHidden = false
        default: paymentSys = "None"; referenceTxt.isHidden = true
        } //end of switch
        
    }
    
    
    @IBOutlet weak var referenceTxt: UITextField!
    
    @IBAction func savePayment(_ sender: Any) {
        self.thinking.startAnimating()
        paymentReference = referenceTxt.text
        billStatus = "Paid"
        print (paymentSys,paymentReference)
        BillArrayStatus[buttonRow] = statusTemp
        paymentView.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            print ("alert19")
            
          self.recieptProcess() // self.alert19()
            
        }
        
    }
    
    @IBAction func cancelPayment(_ sender: Any) {
        paymentView.isHidden = true
        paymentReference = ""
        paymentSys = ""
        recieptDate = ""
        billStatus = "Billed"
    
        print (paymentSys,paymentReference)
      refresh(presser: 0)
        
    }
        
        
    var calendar = Calendar.current
    var recordMonth : Int = 0
    var recordYear : Int = 0
    var recordMonthCancelled : Int = 0
    var recordYearCancelled : Int = 0
    var currentMonth : Int = 0
    var currentYear : Int = 0

    @IBOutlet weak var billerConnect: UITableView!
    @IBOutlet weak var thinking: UIActivityIndicatorView!
    @IBOutlet weak var StatusChosen: UISegmentedControl!
    @IBOutlet weak var totalBills: UITextField!
    @IBOutlet weak var totalTax: UITextField!
    @IBOutlet weak var totalAmount: UITextField!
    @IBOutlet weak var noSign: UIImageView!
    
    //filter
    let btnFilter = UIButton(type: .custom)
    let filterItem = UIBarButtonItem()
    @IBOutlet weak var filterChoiceImage: UIImageView!
    @IBOutlet weak var filterImageConstrain: NSLayoutConstraint!
    @IBOutlet weak var filterConstrain: NSLayoutConstraint!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var filterBG: UIView!
    @IBAction func noneBtn(_ sender: Any) {
    filterDecided = 0
    fetchBills()
    filterImageConstrain.constant = 20
    btnFilter.setImage (greenFilter, for: .normal)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
        self.filterMovement(delay: 1.3)
    }
    }
    
    @IBAction func currentMonthBtn(_ sender: Any) {
    filterDecided = 1
        fetchBills()
    filterImageConstrain.constant = 60
    filterChoiceImage.reloadInputViews()

    btnFilter.setImage (redFilter, for: .normal)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
    self.filterMovement(delay: 1.3)
    }
    }
    
    @IBAction func lastMonthBtn(_ sender: Any) {
    filterImageConstrain.constant = 100
    filterDecided = 2
        fetchBills()
        btnFilter.setImage (redFilter, for: .normal)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
    self.filterMovement(delay: 1.3)
    }
    }
    
    @IBAction func currentYearBtn(_ sender: Any) {
    filterImageConstrain.constant = 140
    filterDecided = 3
        fetchBills()
        btnFilter.setImage (redFilter, for: .normal)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
    self.filterMovement(delay: 1.3)
    }
    }
    
    @IBAction func lastYearBtn(_ sender: Any) {
    filterImageConstrain.constant = 180
    filterDecided = 4
        fetchBills()
        btnFilter.setImage (redFilter, for: .normal)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
    self.filterMovement(delay: 1.3)
    }
    }
    
    //variablesfrom main
    var employerID = ""
    var employerFromMain = ""
    var employeeID = ""

    let mydateFormat5 = DateFormatter()
    let mydateFormat10 = DateFormatter()
    let mydateFormat12 = DateFormatter()
    
    let dbRef = FIRDatabase.database().reference().child("fRecords")
    let dbRefEmployers = FIRDatabase.database().reference().child("fEmployers")
    let dbRefEmployees = FIRDatabase.database().reference().child("fEmployees")
    
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        noSign.isHidden = true
                filterConstrain.constant = -240
        blackView.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        blackView.addGestureRecognizer(tap)
        blackView.isUserInteractionEnabled = true
        filterDecided = 0
        
        billerConnect.backgroundColor = UIColor.clear
        if employerID != "" {  titleLbl = "Bills" } else {titleLbl = "All Bills"}
        
        self.title = titleLbl
        //self.view.insertSubview(backgroundImage, at: 0)
        
        connectivityCheck()
        
        //formatting decimal
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.roundingMode = .up
        
        
        btnFilter.setImage (greenFilter, for: .normal)
        btnFilter.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        btnFilter.addTarget(self, action: #selector(filterMovement(delay:)), for: .touchUpInside)
        filterItem.customView = btnFilter
        navigationItem.rightBarButtonItem = filterItem
        
        //Date
        mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)",options: 0, locale: nil)!
        mydateFormat10.dateFormat = DateFormatter.dateFormat(fromTemplate: " MMM d, yyyy", options: 0, locale: Locale.autoupdatingCurrent)!
        mydateFormat12.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy", options: 0, locale: Locale.autoupdatingCurrent)!

        let today = calendar.dateComponents([.year, .month, .day, .weekOfYear, .yearForWeekOfYear], from: Date())
        currentMonth = today.month!
        currentYear = today.year!

        self.StatusChoice = "All"
        self.billerConnect.separatorColor = blueColor
        
        if employerID != "" {
        dbRefEmployers.child(self.employerID).observeSingleEvent(of:.value, with: {(snapshot) in
        self.lastPrevious = String(describing: snapshot.childSnapshot(forPath: "fLast").value!) as String!
        self.accountAdress = String(describing: snapshot.childSnapshot(forPath: "fAddress").value!) as String!
        self.accountName = String(describing: snapshot.childSnapshot(forPath: "fName").value!) as String!
        self.accountLastName = String(describing: snapshot.childSnapshot(forPath: "fEmployer").value!) as String!
        self.accountParnet = String(describing: snapshot.childSnapshot(forPath: "fParent").value!) as String!
            
        })
        }//end of if
        billerConnect.delegate = self
        billerConnect.dataSource = self
        thinking.hidesWhenStopped = true
        
        paymentView.layer.borderWidth = 0.5
        paymentView.layer.borderColor = blueColor.cgColor
        paymentView.layer.cornerRadius =  10//CGFloat(25)
        paymentView.layoutIfNeeded()
    }//end of view did load////////////////////////////////////////////////////////////////////////////////////////////
    
        override func viewDidAppear(_ animated: Bool) {
        firebaseConnectivity()
            
            if taxBillsToHandle == false {
                
                fetchBills(); StatusChosen.isHidden = false} else {filterDecided = 7 ;monther(monthNumber: monthToHandle);
                
                billsForTaxMonth();StatusChosen.isHidden = true;titleLbl = "\(monthMMM!)-\(yearToHandle)";self.title = titleLbl}
        print (billItems.count)
        billerConnect.reloadData()
        }//view did appear end
    
        func tableView(_ billerConnect: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
        }
    
        func tableView(_ billerConnect: UITableView, numberOfRowsInSection section: Int) -> Int {
        print (billItems.count)
        return billItems.count
        }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = billerConnect.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! billerCell
        let billItem = billItems[indexPath.row]
        cell.backgroundColor = UIColor.clear
            if taxBillsToHandle == false || reportMode  == true {cell.l1.text = ("\(billItem.fBillEmployerName!) - \(billItem.fBillEvents!) ses. ") } else {
            cell.l1.text = ("#\(billItem.fBill!) - \(billItem.fBillEmployerName!)")}
        print ("fuf\(billItem.fBillTotalTotal!)" )
        print ("fuf2\(billItem.fBillTotalTotal!)" )
            if taxBillsToHandle == false || reportMode  == true {
                if billItem.fBillTotalTotal != "" {cell.l3.text = billItem.fBillTotalTotal} else {cell.l3.text = billItem.fBillSum} } else{
                
       
        if billItem.fBillStatus == "Cancelled"{
        let components3 = self.calendar.dateComponents([.year, .month], from: self.mydateFormat5.date(from: billItem.fBillDate!)!)
        self.recordMonth = components3.month!
        self.recordYear = components3.year!
        let components2 = self.calendar.dateComponents([.year, .month], from: self.mydateFormat5.date(from: billItem.fBillStatusDate!)!)
        self.recordMonthCancelled = components2.month!
        self.recordYearCancelled = components2.year!
        if self.recordMonthCancelled == self.recordMonth && self.recordYearCancelled == self.recordYear {
        cell.l3.text = "0"
        } else  if self.recordMonth == self.monthToHandle && self.recordYear == self.yearToHandle {
        cell.l3.text = (billItem.fBillTax!)
        } else {cell.l3.text = "-\(billItem.fBillTax!)"}
        }//end of cancelled
        else { cell.l3.text = billItem.fBillTax}
        }// end of else tax bil to handle
            
                cell.l4.text  = billItem.fBillCurrency!
           
            if taxBillsToHandle == false || reportMode  == true {cell.l6.text = "#\(billItem.fBill!) - \(mydateFormat10.string(from: mydateFormat5.date(from: billItem.fBillDate!)!))"} else {
                if billItem.fBillStatus == "Cancelled" {cell.l6.text = "\(mydateFormat12.string(from: mydateFormat5.date(from: billItem.fBillDate!)!))- cancelled:\(mydateFormat12.string(from: mydateFormat5.date(from: billItem.fBillStatusDate!)!))"} else {cell.l6.text = "\(mydateFormat12.string(from: self.mydateFormat5.date(from: billItem.fBillDate!)!))" }}

        print("fbillstatus\(billItem.fBillStatus!)")
        
        if billItem.fBillStatus! == "Billed" { cell.approval.setImage(billDocument, for: .normal);cell.l1.alpha = 1;cell.l3.alpha = 1;cell.l4.alpha = 1;cell.l6.alpha = 1;cell.approval.alpha = 1}
        if  billItem.fBillStatus!  == "Paid" { cell.approval.setImage(paidImage, for: .normal);cell.l1.alpha = 1;cell.l3.alpha = 1;cell.l4.alpha = 1;cell.l6.alpha = 1;cell.approval.alpha = 1}
        if billItem.fBillStatus! ==  "Cancelled" { cell.approval.setImage(canceledImage,for: .normal);cell.l1.alpha = 0.5;cell.l3.alpha = 0.5;cell.l4.alpha = 0.5;cell.l6.alpha = 0.5}
        
        if taxBillsToHandle == false || reportMode  == true{ cell.approval.isEnabled = true} else {cell.approval.isEnabled=false}
        cell.approval.tag = indexPath.row
        print ("gggggg\(cell.approval.tag)")
        
        cell.approval.removeTarget(self, action:#selector(self.approvalClicked), for: UIControlEvents.touchDown)
        cell.approval.addTarget(self, action:#selector(self.approvalClicked), for: UIControlEvents.touchDown)
        
        return cell
        }
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
            
            
        if (segue.identifier == "billHandler")
        {
        var billRow : IndexPath = self.billerConnect.indexPathForSelectedRow!
        print (billRow.row)
        print (BillArray)
            
        let billManager = segue.destination as? billView
        print ("presparesegue")
        billManager?.billToHandle = "-"+String(BillArray[billRow.row])
        billManager?.employeeID = employeeID
        billManager?.rebillprocess = true
        if  ViewController.professionControl! == "Tutor" && accountParnet != "" {billManager?.contactForMail = "(\(self.accountParnet) \(self.accountLastName) - \(self.accountName)"} else {
                billManager?.contactForMail = "(\(self.accountName) \(self.accountLastName)"
        }

        }//end of if (segue...
        
        if (segue.identifier == "presentReciept")
        { let billManager = segue.destination as? billView
        print ("presparesegue")
        billManager?.recoveredReciept = recoveredreciept!
        billManager?.rebillprocess = false
        billManager?.document = documentName!
        billManager?.documentCounter = counterForpresent!
        billManager?.employeeID = employeeID
        billManager?.employerID = employerID
        billManager?.lastPrevious = lastPrevious
        if  ViewController.professionControl! == "Tutor" && accountParnet != "" {billManager?.contactForMail = "(\(self.accountParnet) \(self.accountLastName) - \(self.accountName)"} else {
        billManager?.contactForMail = "(\(self.accountName) \(self.accountLastName)"}

        

        }//end of if (segue...
            
        }//end of prepare
    
        func fetchBills(){
        billItems.removeAll()
        BillArray.removeAll()
        BillArrayStatus.removeAll()
        self.billCounter = 0
        self.taxCounter = 0
        self.AmountCounter = 0

        self.dbRefEmployees.child(employeeID).child("myBills").observe(.childAdded, with: { (snapshot) in
        if let dictionary =  snapshot.value as? [String: AnyObject] {
        print ("snappp\(snapshot.value!)")
        let billItem = billStruct()
        billItem.setValuesForKeys(dictionary)
            
            let components = self.calendar.dateComponents([.year, .month], from: self.mydateFormat5.date(from: billItem.fBillDate!)!)
            self.recordMonth = components.month!
            self.recordYear = components.year!
            print (self.recordMonth-1,self.recordYear-1)
            
            func inFilter() {
                
                if self .employerID != ""{
                if self.StatusChoice == "Not Paid" && billItem.fBillStatus == "Billed" && billItem.fBillEmployer == self.employerID {
                self.billItems.append(billItem); self.billCounter+=1 ;self.AmountCounter += Double(billItem.fBillTotalTotal!)!;self.taxCounter += Double(billItem.fBillTax!)!
                ; self.BillArray.append(billItem.fBill!); self.BillArrayStatus.append(billItem.fBillStatus!)
                }
                else  if self.StatusChoice == "All" && billItem.fBillEmployer == self.employerID  {self.billItems.append(billItem);if billItem.fBillStatus != "Cancelled" {self.billCounter+=1; self.AmountCounter += Double(billItem.fBillTotalTotal!)!;
                self.taxCounter += Double(billItem.fBillTax!)!}
                ;self.BillArray.append(billItem.fBill!);self.BillArrayStatus.append(billItem.fBillStatus!)}
                }//end of spesic employer

                if self .employerID == "" {
                if self.StatusChoice == "All"  {self.billItems.append(billItem);if billItem.fBillStatus != "Cancelled" {self.billCounter+=1; self.AmountCounter += (Double(billItem.fBillTotalTotal!)!);  self.taxCounter += Double(billItem.fBillTax!)!};    self.BillArray.append(billItem.fBill!);self.BillArrayStatus.append(billItem.fBillStatus!)}
                else if self.StatusChoice == "Not Paid" &&  billItem.fBillStatus == "Billed"  {self.billItems.append(billItem);self.billCounter+=1; self.AmountCounter += Double(billItem.fBillTotalTotal!)!;self.taxCounter += Double(billItem.fBillTax!)!;self.BillArray.append(billItem.fBill!);self.BillArrayStatus.append(billItem.fBillStatus!)}
                }//end of  if self .employerID != ""
                
            }//end of in filter
            
            switch self.filterDecided {
            case 0:inFilter()
            case 1:if self.currentMonth == self.recordMonth && self.currentYear == self.recordYear{inFilter()}
            case 2:if self.currentMonth-1 == self.recordMonth && self.currentYear == self.recordYear{inFilter()} else if self.currentMonth == 1 && self.recordMonth == 12 && self.currentYear-1 == self.recordYear{inFilter()}
            case 3:if self.currentYear == self.recordYear{inFilter()}
            case 4:if self.currentYear-1 == self.recordYear {inFilter()}
            default: inFilter()
            } //end of switch
            
            
print (self.billItems.count)
            
        if self.billItems.count == 0 {self.noSign.isHidden = false} else {self.noSign.isHidden = true}
            
        self.totalBills.text = "\(String(describing: self.billCounter)) Bills"
        self.totalAmount.text = "\(ViewController.fixedCurrency!)\(String(describing: self.AmountCounter))"
        if ViewController.taxOption == "Yes"{ self.totalTax.text = "* Total included tax"} else { self.totalTax.text = "* Cancelled bills excluded"}
            
        self.billerConnect.reloadData()
        }//end of if let dic
        })//end of dbref
            


        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
        if self.billItems.count != self.BillArray.count {
        print ("Stop")
        }

        self.thinking.isHidden = true
        self.thinking.stopAnimating()
        if self.billItems.count == 0 {self.noSign.isHidden = false} else {self.noSign.isHidden = true}

        self.StatusChosen.isEnabled = true
        }

        }//end of fetch
    
            func billsForTaxMonth(){
            billItems.removeAll()
            BillArray.removeAll()
            BillArrayStatus.removeAll()
            filterItem.isEnabled = false
                
            self.billCounter = 0
            self.taxCounter = 0
            self.AmountCounter = 0

            self.dbRefEmployees.child(employeeID).child("myBills").observe(.childAdded, with: { (snapshot) in
            if let dictionary =  snapshot.value as? [String: AnyObject] {
            print ("snappp\(snapshot.value!)")
            let billItem = billStruct()
            billItem.setValuesForKeys(dictionary)

           
            let components = self.calendar.dateComponents([.year, .month], from: self.mydateFormat5.date(from: billItem.fBillDate!)!)
            self.recordMonth = components.month!
            self.recordYear = components.year!
                
                if billItem.fBillStatusDate != nil {
                    print (billItem.fBillStatusDate!)
                    
             let components2 = self.calendar.dateComponents([.year, .month], from: self.mydateFormat5.date(from: billItem.fBillStatusDate!)!)
                self.recordMonthCancelled = components2.month!
                self.recordYearCancelled = components2.year! }
                
                func inFilter(){
                if billItem.fBillStatus != "Cancelled" {
                    if self.recordMonth == self.monthToHandle && self.recordYear == self.yearToHandle {self.BillArray.append(billItem.fBill!);
                self.billItems.append(billItem);self.billCounter+=1; self.AmountCounter += (Double(billItem.fBillTotalTotal!)!); self.taxCounter += Double(billItem.fBillTax!)! ;self.BillArrayStatus.append(billItem.fBillStatus!)}
            }// end of != cancelled
                else {
                    
                    
                    if self.recordMonthCancelled == self.monthToHandle && self.recordYearCancelled == self.yearToHandle  {
                        self.billItems.append(billItem); self.BillArray.append(billItem.fBill!);self.BillArrayStatus.append(billItem.fBillStatus!)
                        if self.recordMonthCancelled == self.recordMonth && self.recordYearCancelled == self.recordYear {
                         //do nothing
                        } else {//
                        //self.AmountCounter -= (Double(billItem.fBillTotalTotal!)!);
                            self.taxCounter -= Double(billItem.fBillTax!)!//self.billCounter+=1;
                        }} else if self.recordMonth == self.monthToHandle && self.recordYear == self.yearToHandle { if  self.recordMonth != self.recordMonthCancelled  || self.recordYear != self.recordYearCancelled{
                        self.billItems.append(billItem); self.BillArray.append(billItem.fBill!);self.BillArrayStatus.append(billItem.fBillStatus!)
                       // self.AmountCounter += (Double(billItem.fBillTotalTotal!)!);
                        self.taxCounter += Double(billItem.fBillTax!)!}//self.billCounter+=1;
                        }
                
                }//end of else
                }//end of infilter
               
                switch self.filterDecided {
                case 7: if self.monthToHandle == self.recordMonth && self.yearToHandle == self.recordYear  || self.monthToHandle == self.recordMonthCancelled && self.yearToHandle == self.recordYearCancelled {inFilter()}

                default: inFilter()
                } //end of switch
                
                
            if self.billItems.count == 0 {self.noSign.isHidden = false} else {self.noSign.isHidden = true}
                if self.reportMode != true {
                    self.totalAmount.text = "Total Tax: \(ViewController.fixedCurrency!)\(String (describing: self.taxCounter))"}
                else {
                    self.totalAmount.text = "Total: \(ViewController.fixedCurrency!)\(String(describing: self.AmountCounter))"
                    self.totalBills.text = "\(String(describing: self.billCounter)) Bills"
                    if ViewController.taxOption == "Yes"{ self.totalTax.text = "* Total included tax"} else { self.totalTax.text = "* Cancelled bills excluded"}
                }
            //self.totalTax.text = "Tax \(ViewController.fixedCurrency!)\(String (describing: self.taxCounter))"
            self.billerConnect.reloadData()
            }//end of if let dic
            })//end of dbref

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            if self.billItems.count != self.BillArray.count {
            print ("Stop")
            }
            self.thinking.isHidden = true
            self.thinking.stopAnimating()
            self.StatusChosen.isEnabled = true
            }
            }//end of bills for tax month
    
        @IBAction func StatusChosen(_ sender: Any) {
        print("pressed")
        //noSign.isHidden = true
        //saveToFB() //check why is it here?
        self.thinking.isHidden = false
        self.thinking.startAnimating()
        StatusChosen.isEnabled = false
        switch StatusChosen.selectedSegmentIndex {
        case 0: StatusChoice = "Not Paid"
        case 1: StatusChoice = "All"
        default: break
        } //end of switch
                fetchBills()
        }
    
        // button on table clicked
        func  approvalClicked(sender:UIButton!) {
        self.StatusChosen.isEnabled = false
        buttonRow = sender.tag
            
            self.dbRefEmployees.child(employeeID).child("myBills").child(String("-"+BillArray[buttonRow])).observeSingleEvent(of: .value,with: {(snapshot) in
                self.documentName = snapshot.childSnapshot(forPath: "fDocumentName").value! as? String
                self.counterForpresent = snapshot.childSnapshot(forPath: "fBill").value! as? String
                self.midCalc = snapshot.childSnapshot(forPath: "fBillTax").value! as? String
                self.midCalc2 = snapshot.childSnapshot(forPath: "fBillTotalTotal").value! as? String
                self.midCalc3 = snapshot.childSnapshot(forPath: "fBillSum").value! as? String
                self.account = snapshot.childSnapshot(forPath: "fBillEmployerName").value! as? String
                //self.employerID = (snapshot.childSnapshot(forPath: "fBillEmployer").value! as? String)!
               // self.recoveredreciept = snapshot.childSnapshot(forPath: "fBillRecieptMailSaver").value! as? String


                print (self.midCalc3,self.midCalc2,self.midCalc)
                
          ////  })
            
        
                if self.BillArrayStatus[self.buttonRow] != "Cancelled"
                { if self.BillArrayStatus[self.buttonRow] == "Billed" {  self.statusTemp = "Paid";
                    self.paymentTitle.text = "Fully pay bill \(self.BillArray[self.buttonRow]) by"
                    self.paymentView.isHidden = false
                    self.BillArrayStatus[self.buttonRow] = self.statusTemp
            }//end of if billed
            
                else if self.BillArrayStatus[self.buttonRow] == "Paid" {  if self.StatusChoice == "Not Paid" { self.statusTemp = "Billed"
                    self.dbRefEmployees.child(self.employeeID).child("myBills").child(String("-"+self.BillArray[self.buttonRow])).updateChildValues(["fBillStatus": self.statusTemp, "fBillStatusDate":
                        self.mydateFormat5.string(from: Date())//was 3
            ], withCompletionBlock: { (error) in}) //end of update.
                    self.BillArrayStatus[self.buttonRow] = self.statusTemp
            } else {
            
            if self.documentName == "Bill & Payment" {self.alert78()} else {
            self.alert3()}
            }//end of else
            }//end of if paid

        }else {
                    self.alert9()}// end of if cancelled
        
                 })
        if StatusChoice == "Not Paid"{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.StatusChosen.isEnabled = true
        }} else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.StatusChosen.isEnabled = true
            }//end of fispatch
        }//end of else
    
        }//end button clicked

        func  reSend(sender:UIButton!) {
        print("resend")
        buttonRow = sender.tag
        alert5()
        
        self.dbRefEmployees.child(employeeID).child("myBills").child(String(BillArray[buttonRow])).observeSingleEvent(of: .value,with: { (snapshot) in
        self.recoveredBill = snapshot.childSnapshot(forPath: "fBillMailSaver").value! as? String
        self.recoveredreciept = snapshot.childSnapshot(forPath: "fBillRecieptMailSaver").value! as? String

        print("recovered")
        })
        
        }//end resend clicked
    
    
    
    
    //func for mail// ithink not used
        func  configuredMailComposeViewController2() -> MFMailComposeViewController {
        let mailComposerVC2 = MFMailComposeViewController()
        mailComposerVC2.mailComposeDelegate = self
        mailComposerVC2.setSubject("Bill recovery")
        mailComposerVC2.setMessageBody(recoveredBill!, isHTML: false)
        mailComposerVC2.setToRecipients([ViewController.fixedemail])
        return mailComposerVC2
        }//end of MFMailcomposer
    
        //func for mail of reciept
        func  configuredMailComposeViewController3() -> MFMailComposeViewController {
        let mailComposerVC3 = MFMailComposeViewController()
        mailComposerVC3.mailComposeDelegate = self
        mailComposerVC3.setSubject("Reciept")
        mailComposerVC3.setMessageBody(recieptMailSaver!, isHTML: false)
        mailComposerVC3.setToRecipients([ViewController.fixedemail])
        DispatchQueue.main.asyncAfter(deadline: .now()+2){
        self.saveBase64StringToPDF(self.recieptMailSaver!)
        }
            
        return mailComposerVC3
        }//end of MFMailcomposer

    func saveBase64StringToPDF(_ base64String: String) {
        guard
            var documentsURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last,
            let convertedData = Data(base64Encoded: base64String)
            else {
                //handle error when getting documents URL
                return
        }
    }
        func showSendmailErrorAlert() {
        let sendMailErorrAlert = UIAlertController(title:"Could Not Send Email", message: "Your device could not send e-mail. Please check e-mail configuration and try again.",preferredStyle: .alert)
        sendMailErorrAlert.message = "error occured"
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
        print("Mail cancelled")
        controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.saved.rawValue:
        print("Mail saved3")
        controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.sent.rawValue:
        print("Mail sent3")
        controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.failed.rawValue:
        print("Mail sent failure: %@", [error!.localizedDescription])
        controller.dismiss(animated: true, completion: nil)
        default:
        break
        }
        }
    
        func handleTap(sender: UITapGestureRecognizer? = nil) {
        filterMovement(delay: 0)    }
    
        func filterMovement(delay:Double){
        if isFilterHidden {
        self.blackView.isHidden = false
        self.filterConstrain.constant = 0
        UIView.animate(withDuration: (0.4), animations: {
        self.view.layoutIfNeeded()
        })
        }else{
        self.blackView.isHidden = true
        filterConstrain.constant = -240
        UIView.animate(withDuration:(0.4+delay), animations: {
        self.view.layoutIfNeeded()
        })
        }
        isFilterHidden = !isFilterHidden
        }//end of issidemenuhidden
    
    func recieptProcess() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0){
        self.thinking.isHidden = false
        self.thinking.startAnimating()
        }
        
        
        fetchBillInfo()
        print (buttonRow)
        print (BillArray[buttonRow])
        
        self.dbRefEmployees.child(employeeID).child("myBills").child(String("-"+BillArray[buttonRow])).observeSingleEvent(of: .value,with: {(snapshot) in
            self.employerID = (snapshot.childSnapshot(forPath: "fBillEmployer").value! as? String)!
            if  (snapshot.childSnapshot(forPath: "fBalance").value! as? String) != nil { self.balance = (snapshot.childSnapshot(forPath: "fBalance").value! as? String)!} else {self.balance = (self.midCalc2!)}
            
            self.dbRefEmployers.child(self.employerID).observeSingleEvent(of:.value, with: {(snapshot) in
                //self.lastPrevious = String(describing: snapshot.childSnapshot(forPath: "fLast").value!) as String!
                self.accountAdress = String(describing: snapshot.childSnapshot(forPath: "fAddress").value!) as String!
                self.accountName = String(describing: snapshot.childSnapshot(forPath: "fName").value!) as String!
                self.accountLastName = String(describing: snapshot.childSnapshot(forPath: "fEmployer").value!) as String!
                self.accountParnet = String(describing: snapshot.childSnapshot(forPath: "fParent").value!) as String!
            })
            })
        
        recieptDate = mydateFormat5.string(from: Date())
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2){
            print (self.billInfo)
            
            self.recieptMailSaver = "\(self.mydateFormat10.string(from: Date()))\r\n\r\n\r\n\(ViewController.fixedName!) \(ViewController.fixedLastName!)\r\n\(self.billInfo!)\r\n\(self.taxId!)\r\n\(self.address!)\r\n\(self.seprator2)\(self.seprator2)\r\n\r\nRecieved from:\r\n\(self.accountName) \(self.accountLastName) - \(self.accountParnet)\r\n\(self.accountAdress)\r\n\(self.seprator2)\r\n\r\n\r\nBalance Due from invoice \(self.BillArray[self.buttonRow]): \(ViewController.fixedCurrency!)\(self.balance!)\r\n\(self.paymentBlock!)\r\n\r\n\(self.seprator2)\(self.seprator2)\r\nRemaining Balance Due from Invoice \(self.BillArray[self.buttonRow]): \(ViewController.fixedCurrency!)0.0\r\n\r\n\r\nMade by PerSession app. "
            
            
           // Payment's recipet for Bill-\(self.BillArray[self.buttonRow])\r\
            
            //Reciept-\(self.BillArray[self.buttonRow])
            self.recoveredreciept = self.recieptMailSaver
            print (self.recieptMailSaver)
            print (self.recoveredreciept)

                //update bill with DB
            self.dbRefEmployees.child(self.employeeID).child("myBills").child(String("-"+self.BillArray[self.buttonRow])).updateChildValues(["fBillStatus": self.statusTemp, "fBillStatusDate":
                self.self.mydateFormat5.string(from: Date()),"fPaymentMethood": self.paymentSys, "fPaymentReference": self.paymentReference,"fRecieptDate":self.mydateFormat5.string(from: Date()),"fBillRecieptMailSaver":self.recieptMailSaver
                ], withCompletionBlock: { (error) in}) //end of update.
            
            print (self.employerID)
            print(self.mydateFormat10.string(from: Date()))
            
            self.dbRefEmployers.child(self.employerID).updateChildValues(["fLast":"Last paid: \(self.mydateFormat10.string(from: Date()))"], withCompletionBlock: { (error) in})
            
            self.dbRefEmployees.child(self.employeeID).child("myEmployers").updateChildValues([(self.employerID):Int((self.mydateFormat5.date(from: self.mydateFormat5.string(from: Date()))?.timeIntervalSince1970)!)]) 

            
            
            self.performSegue(withIdentifier: "presentReciept", sender: self.recieptMailSaver)

                //self.navigationController!.popViewController(animated: true)
            
            

           /// if self.StatusChoice == "Not Paid" {self.refresh(presser: 0)}
           /// self.thinking.stopAnimating()
        
            
            }//end of if biller
        
        
    }//end of billprocess
    
    func refresh(presser:Int){
        StatusChosen.isMomentary = true
        segmentedPressed = presser
        StatusChosen.selectedSegmentIndex = segmentedPressed!
        StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
        StatusChosen.isMomentary = false
    }
    
    func fetchBillInfo(){
        self.dbRefEmployees.queryOrderedByKey().queryEqual(toValue: self.employeeID).observeSingleEvent(of: .childAdded, with: { (snapshot) in
           
            let counterForMail = (snapshot.childSnapshot(forPath: "fCounter").value as! String)
            let taxSwitch = (snapshot.childSnapshot(forPath: "fSwitcher").value as! String)
            //let taxation = (snapshot.childSnapshot(forPath: "fTaxPrecentage").value as! String)
            if snapshot.childSnapshot(forPath: "fBillinfo").value as! String != nil {self.billInfo = "\(snapshot.childSnapshot(forPath: "fBillinfo").value as! String)"} else {self.billInfo = ""}
            if snapshot.childSnapshot(forPath: "fTaxId").value as! String != nil {self.taxId = "Tax Id:\(snapshot.childSnapshot(forPath: "fTaxId").value as! String)"} else {self.taxId = ""}
            self.address = (snapshot.childSnapshot(forPath: "fAddress").value as! String)
            self.taxForBlock = "VAT"
            
            
            
          
            
            
            if  taxSwitch == "Yes" {
            self.taxationBlock = ("Total (without \(self.taxForBlock!)): \(ViewController.fixedCurrency!)\(self.midCalc3!)\r\n\(self.taxForBlock!): \(ViewController.fixedCurrency!)\(self.midCalc!)")
            }//if taxswitch = yes
            else {self.taxationBlock = ""}
            

            print (self.paymentSys!)
            if self.paymentReference != "" {self.refernceBlock = "Ref:\(self.paymentReference!)"} else {self.refernceBlock = ""}
            
            
            self.documentName = "Reciept"; if self.paymentSys == "other" || self.paymentSys == ""{self.paymentBlock = ("Payment of \(ViewController.fixedCurrency!)\(self.balance) made: \(self.mydateFormat10.string(from:self.mydateFormat5.date(from: self.recieptDate!)!)) - \(self.refernceBlock) ")
           
            
                
            }

            
            if self.paymentReference != "" {self.refernceBlock = "Ref:\(self.paymentReference!)"} else {self.refernceBlock = ""}
            if self.paymentSys! == "other" || self.paymentSys == ""{// payment == other
                self.paymentBlock = ("Payment of \(ViewController.fixedCurrency!)\(self.midCalc2!) made: \(self.mydateFormat10.string(from:self.mydateFormat5.date(from: self.recieptDate!)!))  \(self.refernceBlock!) ")
            } else {self.paymentBlock = "Payment of \(ViewController.fixedCurrency!)\(self.midCalc2!) made by \(self.paymentSys!) \(self.refernceBlock!) - \(self.mydateFormat10.string(from:self.mydateFormat5.date(from: self.recieptDate!)!))"
            }
        })
    }//end of billing
    
    func monther(monthNumber:Int)  {
        let fmt = DateFormatter()
        fmt.dateFormat = "m"
        monthMMM = fmt.shortMonthSymbols[monthNumber-1]
        return
    }

            // alerts////////////////////////////////////////////////////////////////////////////////////////////
            
            func alert5(){
            let alertController5 = UIAlertController(title: ("Bill Recovery") , message: "Do you want to recover the original bill generated by  PerSession and send it to you?", preferredStyle: .alert)
            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            //do nothing
            }
            let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            let mailComposeViewController2 = self.configuredMailComposeViewController2()
            if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController2, animated: true, completion: nil)
            } //end of if
            else{ self.showSendmailErrorAlert() }
            }
            alertController5.addAction(CancelAction)
            alertController5.addAction(OKAction)
            self.present(alertController5, animated: true, completion: nil)
            }

            func alert9(){
            let alertController9 = UIAlertController(title: ("Bill Alert") , message: "You can't change status of a cancelled Bill.", preferredStyle: .alert)
            let OkAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            //do nothing
            }
            alertController9.addAction(OkAction)
            self.present(alertController9, animated: true, completion: nil)
            }

        func alert78(){
        let alertController78 = UIAlertController(title: ("Cancel Payment Alert") , message: "You can't cancel a payment as 'bill & Pay' document already generated - if requiered, you can delete the document and set a new bill.", preferredStyle: .alert)
        let OkAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            biller.checkBoxBiller = 1
            //do nothing
            self.refresh(presser: 1)
        }
        alertController78.addAction(OkAction)
        self.present(alertController78, animated: true, completion: nil)
        }
    
            func alert3(){
            let alertController3 = UIAlertController(title: ("Bill Alert") , message: "You are about to cancel reciept. Are you Sure?", preferredStyle: .alert)

            let CancelAction = UIAlertAction(title: "No", style: .cancel) { (UIAlertAction) in
            biller.checkBoxBiller = 1
            //do nothing
             self.refresh(presser: 1)
            }

            let OKAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
                
            //  save the canceeld reciept within the bill
                self.dbRefEmployees.child(self.employeeID).child("IrregularLog").child("CancelledReciepts").child(self.mydateFormat5.string(from: Date())).updateChildValues(["fBillRecieptMailSaver":self.recoveredreciept, "fReciept":self.BillArray[self.buttonRow]], withCompletionBlock: { (error) in})
             //resert the reciept data within the bill
            self.statusTemp = "Billed"
            self.BillArrayStatus[self.buttonRow] = self.statusTemp
                self.dbRefEmployees.child(self.employeeID).child("myBills").child(String("-"+self.BillArray[self.buttonRow])).updateChildValues(["fBillStatus": self.statusTemp ,"fBillStatusDate":self.mydateFormat5.string(from: Date()),"fRecieptDate":"","fBillRecieptMailSaver":"","fPaymentMethood" :"","fPaymentReference":""], withCompletionBlock: { (error) in}) //end of update.//was 3

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
             self.refresh(presser: 1)
            }
            }
            alertController3.addAction(OKAction)
            alertController3.addAction(CancelAction)
            self.present(alertController3, animated: true, completion: nil)
            }
    func alert19(){
        print ("in alert19")
        
        let alertController19 = UIAlertController(title: ("Bill") , message: "Register a new reciept." , preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Just do it", style: .default) { (UIAlertAction) in
            self.recieptProcess()
        }
        
        let mailAction = UIAlertAction(title: "Mail it", style: .default) { (UIAlertAction) in
            print ("mail it")
            
            self.recieptProcess() 
            
            
            DispatchQueue.main.asyncAfter(deadline: .now()+2){
                print ("in mail controller")
                //let storyboard = UIStoryboard(name: "Main", bundle: nil)
                //let mailController  =  storyboard.instantiateViewController(withIdentifier: "200")
                //self.present(mailController, animated: false, completion: nil)
                let mailComposeViewController3 = self.configuredMailComposeViewController3()
                if MFMailComposeViewController.canSendMail() {
                    self.present(mailComposeViewController3, animated: true, completion: nil)
                } //end of if
                else{ self.showSendmailErrorAlert() }
                
                DispatchQueue.main.asyncAfter(deadline: .now()+2){
                    self.refresh(presser: 0)
                }
            }
        }
        let printAction = UIAlertAction(title: "Print it", style: .default) { (UIAlertAction) in
            self.recieptProcess()
            //add printing process
        }
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            self.paymentReference = ""
            self.paymentSys = ""
            self.recieptDate = ""
            self.billStatus = "Billed"
            self.refresh(presser: 0)
        }
        
        alertController19.addAction(OKAction)
        alertController19.addAction(mailAction)
        alertController19.addAction(printAction)
        alertController19.addAction(CancelAction)
        self.present(alertController19, animated: true, completion: nil)
    }//end of alert19
            }//end of class

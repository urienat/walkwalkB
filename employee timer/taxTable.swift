//
//  taxTable.swift
//  perSession
//
//  Created by Uri Enat on 12/18/17.
//  Copyright © 2017 אורי עינת. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import MessageUI


class taxCalc: UIViewController, UITableViewDelegate,UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    let greenFilter = UIImage(named: "sandWatchBig")
    let redFilter = UIImage(named: "sandWatchRed")
    var blueColor = UIColor(red :22/255.0, green: 131/255.0, blue: 248/255.0, alpha: 1.0)
    
    var billItems = [billStruct]()
    static var checkBoxBiller:Int = 0
    var BillArrayStatus = [String]()
    var BillArray = [String]()
    var statusTemp = "Billed"
    var StatusChoice = "Not Paid"
    var buttonRow = 0
    var recoveredBill:String?
    var titleLbl = ""
    var cellId = "taxerId"
    var billCounter = 0
    var taxCounter = 0.0
    var AmountCounter = 0.0
    var isFilterHidden = true
    var filterDecided :Int = 0
    
    var byMonthTax = [String:Double]()
    var arrayOfMonths = [String]()
    var uniqueTaxMonths = [String]()
    var monthSorter = [String]()
    var uniqueTaxMonthsdateFormat = [Date]()
    var taxMonthRow: IndexPath?
    
    var calendar = Calendar.current
    var taxMonth : Int = 0
    var taxYear : Int = 0
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
    @IBOutlet weak var filterChoiceImage: UIImageView!
    @IBOutlet weak var filterImageConstrain: NSLayoutConstraint!
    @IBOutlet weak var filterConstrain: NSLayoutConstraint!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var filterBG: UIView!
    @IBOutlet weak var filter: UIButton!
    @IBAction func filter(_ sender: Any) {
        filterMovement(delay: 0)
    }
    @IBAction func noneBtn(_ sender: Any) {
        filterDecided = 0
        fetchBills()
        filterImageConstrain.constant = 20
        filter.setImage(greenFilter, for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.filterMovement(delay: 1.3)
        }
    }
 //   let btnFilter : UIButton
  // let filterItem : UIBarButtonItem
    
    @IBAction func currentMonthBtn(_ sender: Any) {
        filterDecided = 1
        fetchBills()
        filterImageConstrain.constant = 60
        filterChoiceImage.reloadInputViews()
        
        filter.setImage(redFilter, for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.filterMovement(delay: 1.3)
        }
    }
    
    @IBAction func lastMonthBtn(_ sender: Any) {
        filterImageConstrain.constant = 100
        filterDecided = 2
        fetchBills()
        filter.setImage(redFilter, for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.filterMovement(delay: 1.3)
        }
    }
    
    @IBAction func currentYearBtn(_ sender: Any) {
        filterImageConstrain.constant = 140
        filterDecided = 3
        fetchBills()
        filter.setImage(redFilter, for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.filterMovement(delay: 1.3)
        }
    }
    
    @IBAction func lastYearBtn(_ sender: Any) {
        filterImageConstrain.constant = 180
        filterDecided = 4
        fetchBills()
        filter.setImage(redFilter, for: .normal)
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
    let mydateFormat20 = DateFormatter()

    
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
        filter.setImage(greenFilter, for: .normal)
        StatusChosen.isHidden = true
        
        billerConnect.backgroundColor = UIColor.clear
        titleLbl = "Tax"
        self.title = titleLbl
        
        //connectivity
        if Reachability.isConnectedToNetwork() == true
        {print("Internet Connection Available!")
        }else{
            print("Internet Connection not Available!")
        }
        
        //formatting decimal
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.roundingMode = .up
        
        //Date
        mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)",options: 0, locale: nil)!
        mydateFormat10.dateFormat = DateFormatter.dateFormat(fromTemplate: " MMM d, yyyy", options: 0, locale: Locale.autoupdatingCurrent)!
        mydateFormat20.dateFormat = DateFormatter.dateFormat(fromTemplate: " MMM , yyyy", options: 0, locale: Locale.autoupdatingCurrent)!
      
        
       // btnFilter.setImage (greenFilter, for: .normal)
       // btnFilter.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        //btnFilter.addTarget(self, action: #selector(filterMovement(delay:)), for: .touchUpInside)
        //filterItem.customView = btnFilter

        let today = calendar.dateComponents([.year, .month, .day, .weekOfYear, .yearForWeekOfYear], from: Date())
        currentMonth = today.month!
        currentYear = today.year!
        
        self.StatusChoice = "All"
        self.billerConnect.separatorColor = blueColor
        
        billerConnect.delegate = self
        billerConnect.dataSource = self
    }//end of view did load////////////////////////////////////////////////////////////////////////////////////////////
    
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
        
        fetchBills()
        print (billItems.count)
        billerConnect.reloadData()
    }//view did appear end
    
    func tableView(_ billerConnect: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ billerConnect: UITableView, numberOfRowsInSection section: Int) -> Int {

        return uniqueTaxMonths.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = billerConnect.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! taxerCell
        print (uniqueTaxMonths)
        
        let taxMonthItem = arrayOfMonths[indexPath.row]
        let taxForMonth =  byMonthTax[taxMonthItem]!
        cell.backgroundColor = UIColor.clear
        cell.l1.text = arrayOfMonths[indexPath.row]
        cell.l4.text  = ViewController.fixedCurrency
        cell.l3.text = String(taxForMonth) as String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        taxMonthRow = self.billerConnect.indexPathForSelectedRow!
        print (taxMonthRow)
        print (taxMonthRow?.row)
            print (arrayOfMonths)
print (mydateFormat20.date(from: (arrayOfMonths[(taxMonthRow?.row)!])))
            
            
        if (segue.identifier == "billsForTaxMonth")
        { let billTaxManager = segue.destination as? biller
        print ("presparesegue")
        print (arrayOfMonths[(taxMonthRow?.row)!])
            
            
            
            let components = self.calendar.dateComponents([.year, .month], from: (mydateFormat20.date(from: (arrayOfMonths[(taxMonthRow?.row)!])))!)
        self.taxMonth =   components.month!
        self.taxYear = components.year!
            print (self.taxYear,self.taxMonth)
            
            billTaxManager?.monthToHandle = components.month!
            billTaxManager?.yearToHandle = components.year!
        billTaxManager?.employeeID = employeeID
        billTaxManager?.taxBillsToHandle = true
        }//end of if (segue...
        }//end of prepare
    
    func fetchBills(){
        billItems.removeAll()
        BillArray.removeAll()
        BillArrayStatus.removeAll()
        arrayOfMonths.removeAll()
        byMonthTax.removeAll()
        uniqueTaxMonths.removeAll()
        self.billCounter = 0
        self.taxCounter = 0
        self.AmountCounter = 0
        
        self.dbRefEmployees.child(employeeID).child("myBills").observe(.childAdded, with: { (snapshot) in
            if let dictionary =  snapshot.value as? [String: AnyObject] {
                print ("snappp\(snapshot.value!)")
                let billItem = billStruct()
                billItem.setValuesForKeys(dictionary)
                
                let components = self.calendar.dateComponents([.year, .month], from: self.mydateFormat5.date(from: billItem.fBillDate!)!)
                self.taxMonth = components.month!
                self.taxYear = components.year!
                print (self.taxMonth-1,self.taxYear-1)
                
                
                func inFilter() {
                    if billItem.fBillStatus != "Cancelled"{
                    if self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)] == nil {
                        self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)] = Double(billItem.fBillTax!)!
                    }else{
                        self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)] = self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)]! + Double(billItem.fBillTax!)!
                        }
                        }
                    
                    if billItem.fBillStatus != "Cancelled"{
                        self.monthSorter.append(self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!))
                    self.uniqueTaxMonths = Array(Set(self.monthSorter))
                    self.uniqueTaxMonthsdateFormat = self.uniqueTaxMonths.map {self.mydateFormat20.date(from: $0)! }
                    self.uniqueTaxMonthsdateFormat.sort { $0.compare($1) == .orderedDescending }
                    self.arrayOfMonths = self.uniqueTaxMonthsdateFormat.map { self.mydateFormat20.string(from: $0)}
                    }
                    self.billItems.append(billItem);if billItem.fBillStatus != "Cancelled" {self.billCounter+=1; self.AmountCounter += Double(billItem.fBillTotalTotal!)!;
                        self.taxCounter += Double(billItem.fBillTax!)!}
                    ;self.BillArray.append(billItem.fBill!);self.BillArrayStatus.append(billItem.fBillStatus!)
                    
                }//end of in filter
                
                switch self.filterDecided {
                case 0:inFilter()
                case 1:if self.currentMonth == self.taxMonth && self.currentYear == self.taxYear{inFilter()}
                case 2:if self.currentMonth-1 == self.taxMonth && self.currentYear == self.taxYear{inFilter()} else if self.currentMonth == 1 && self.taxMonth == 12 && self.currentYear-1 == self.taxYear{inFilter()}
                case 3:if self.currentYear == self.taxYear{inFilter()}
                case 4:if self.currentYear-1 == self.taxYear {inFilter()}
                default: inFilter()
                } //end of switch
                
                
                
                if self.billItems.count == 0 {self.noSign.isHidden = false} else {self.noSign.isHidden = true}
                self.totalBills.text = "\(String(describing: self.billCounter)) Bills"
                self.totalAmount.text = "\(ViewController.fixedCurrency!)\(String(describing: self.AmountCounter))"
                self.totalTax.text = "Tax \(ViewController.fixedCurrency!)\(String (describing: self.taxCounter))"
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
        
    }//end of fetch
    
        @IBAction func StatusChosen(_ sender: Any) {
        print("pressed")
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

        if BillArrayStatus[buttonRow] != "Cancelled"
        { if BillArrayStatus[buttonRow] == "Billed" {  statusTemp = "Paid"
        self.dbRefEmployees.child(employeeID).child("myBills").child(String("-"+BillArray[buttonRow])).updateChildValues(["fBillStatus": statusTemp, "fBillStatusDate":
        mydateFormat5.string(from: Date())//was 3
        ], withCompletionBlock: { (error) in}) //end of update.
        BillArrayStatus[buttonRow] = statusTemp
        }//end of if billed
        else if BillArrayStatus[buttonRow] == "Paid" {  if StatusChoice == "Not Paid" { statusTemp = "Billed"
        self.dbRefEmployees.child(employeeID).child("myBills").child(String("-"+BillArray[buttonRow])).updateChildValues(["fBillStatus": statusTemp, "fBillStatusDate":
        mydateFormat5.string(from: Date())//was 3
        ], withCompletionBlock: { (error) in}) //end of update.
        BillArrayStatus[buttonRow] = statusTemp
        } else { //BillArrayStatus[buttonRow] == "Cancelled"
        }
        }//end of if paid

        }else {
        }// end of if cancelled

        if StatusChoice == "Not Paid"{
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
        self.StatusChosen.isMomentary = true
        self.StatusChosen.selectedSegmentIndex = 0
        self.StatusChosen.sendActions(for: .valueChanged)            //  StatusChosenis pressed
        self.StatusChosen.isMomentary = false
        self.StatusChosen.isEnabled = true
        }} else {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
        self.StatusChosen.isEnabled = true
        }//end of fispatch
        }//end of else

        }//end button clicked



        func noFB() {
        self.thinking.stopAnimating()
        self.alert30()
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
    
    // alerts////////////////////////////////////////////////////////////////////////////////////////////
    func alert30(){
    let alertController30 = UIAlertController(title: ("No connection") , message: "Currently there is no connection with database. Please try again.", preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
    }
    alertController30.addAction(OKAction)
    self.present(alertController30, animated: true, completion: nil)
    }

}//end of class

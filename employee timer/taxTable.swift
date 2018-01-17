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
    
    let greenFilter = UIImage(named: "filterBlack")
    let redFilter = UIImage(named: "filterRed")
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
    
    var monthMMM: String?
    var monthTitle : Int = 0
    var yearTitle : Int = 0
    
    var byMonthTax = [String:Double]()
    var byMonthTotal = [String:Double]()
    var byMonthBills = [String:Int]()
    var billTxt: String?


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
            self.title = "Tax"
            filterDecided = 0
            fetchBills()
            filterImageConstrain.constant = 20
            btnFilter.setImage (greenFilter, for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.filterMovement(delay: 1.3)
            }
            }

            @IBAction func currentMonthBtn(_ sender: Any) {
            monther(monthNumber: currentMonth)
            self.title = "Tax: \(monthMMM!)-\(self.currentYear)"

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

            if currentMonth == 1 {self.title = "Tax: Dec-\(self.currentYear-1)" } else  {monther(monthNumber: currentMonth-1);self.title = "Tax: \(monthMMM!)-\(self.currentYear)"}

            filterImageConstrain.constant = 100
            filterDecided = 2
            fetchBills()
            btnFilter.setImage (redFilter, for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.filterMovement(delay: 1.3)
            }
            }

            @IBAction func currentYearBtn(_ sender: Any) {
            self.title = "Tax: \(self.currentYear)"

            filterImageConstrain.constant = 140
            filterDecided = 3
            fetchBills()
            btnFilter.setImage (redFilter, for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.filterMovement(delay: 1.3)
            }
            }

            @IBAction func lastYearBtn(_ sender: Any) {
            self.title = "Tax: \(self.currentYear-1)"
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
        
        billerConnect.backgroundColor = UIColor.clear
        titleLbl = "Tax"
        self.title = titleLbl

        connectivityCheck()
        
        //formatting decimal
        let formatter = NumberFormatter()
        //formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .up
        formatter.minimumFractionDigits = 2
        formatter.numberStyle = .currencyAccounting
        
        
        //Date
        mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)",options: 0, locale: nil)!
        mydateFormat10.dateFormat = DateFormatter.dateFormat(fromTemplate: " MMM d, yyyy", options: 0, locale: Locale.autoupdatingCurrent)!
        mydateFormat20.dateFormat = DateFormatter.dateFormat(fromTemplate: " MMM , yyyy", options: 0, locale: Locale.autoupdatingCurrent)!
      
        btnFilter.setImage (greenFilter, for: .normal)
        btnFilter.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        btnFilter.addTarget(self, action: #selector(filterMovement(delay:)), for: .touchUpInside)
        filterItem.customView = btnFilter
        navigationItem.rightBarButtonItem = filterItem

        let today = calendar.dateComponents([.year, .month, .day, .weekOfYear, .yearForWeekOfYear], from: Date())
        currentMonth = today.month!
        currentYear = today.year!
        
        self.StatusChoice = "All"
        self.billerConnect.separatorColor = blueColor
        
        billerConnect.delegate = self
        billerConnect.dataSource = self
    }//end of view did load////////////////////////////////////////////////////////////////////////////////////////////
    
        override func viewDidAppear(_ animated: Bool) {
        firebaseConnectivity()
        
        fetchBills()
        print (billItems.count)
        billerConnect.reloadData()
        }//view did appear end
    
        func tableView(_ billerConnect: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 69
            
        }
    
        func tableView(_ billerConnect: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uniqueTaxMonths.count
        }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = billerConnect.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! taxerCell
        print ("uniqueTaxMonths\(uniqueTaxMonths)")

        let taxMonthItem = arrayOfMonths[indexPath.row]
        print ("taxMonthItem\(taxMonthItem)")
        print ("byMonthTax\(byMonthTax)")

        let taxForMonth =  byMonthTax[taxMonthItem]!
        let totalForMonth =  byMonthTotal[taxMonthItem]!
        let billsForMonth =  byMonthBills[taxMonthItem]!
        if billsForMonth == 1 {billTxt = "bill"} else {billTxt = "bills"}

        cell.backgroundColor = UIColor.clear
        cell.l1.text = arrayOfMonths[indexPath.row]
        //cell.l2.text = "\(billsForMonth) \(billTxt!)"
        //cell.l5.text = "Total(w/tax): \(ViewController.fixedCurrency!)\(totalForMonth) - \(billsForMonth) \(billTxt!)"
        cell.l5.text = "\(billsForMonth) \(billTxt!)"

        //cell.l4.text  = ViewController.fixedCurrency
        cell.l3.text = "Tax: \(ViewController.fixedCurrency!)\(String(taxForMonth) as String)"
        return cell
        }
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print (arrayOfMonths)
            print (taxMonthRow?.row)

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
        byMonthTotal.removeAll()
        byMonthBills.removeAll()
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
                    if self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)] == nil {
                    self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)] = Double(billItem.fBillTax!)!;
                    self.byMonthTotal[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)] = Double(billItem.fBillTotalTotal!)!;
                    self.byMonthBills[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)] = 1

                    }else{
                    self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)] = self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)]! + Double(billItem.fBillTax!)!;
                    self.byMonthTotal[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)] = self.byMonthTotal[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)]! + Double(billItem.fBillTotalTotal!)!;
                    self.byMonthBills[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)] = self.byMonthBills[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)]! + 1
                    }
                    
                    if billItem.fBillStatus == "Cancelled"{
                    if self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillStatusDate!)!)] == nil {
                    self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillStatusDate!)!)] = -Double(billItem.fBillTax!)!;
                    self.byMonthTotal[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillStatusDate!)!)] = -Double(billItem.fBillTotalTotal!)!;
                    self.byMonthBills[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillStatusDate!)!)] = 1
                    }else{
                    self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillStatusDate!)!)] = self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillStatusDate!)!)]! - Double(billItem.fBillTax!)!;
                    self.byMonthTotal[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillStatusDate!)!)] = self.byMonthTotal[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillStatusDate!)!)]! - Double(billItem.fBillTotalTotal!)!;
                    self.byMonthBills[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillStatusDate!)!)] = self.byMonthBills[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillStatusDate!)!)]! - 1
                    }
                    }


                    if billItem.fBillStatus != "Cancelled"{
                    self.monthSorter =  Array(self.byMonthTax.keys.map{$0})
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
               // self.totalBills.text = "Total(w/Tax): \(ViewController.fixedCurrency!)\(String(describing: self.AmountCounter)) - \(String(describing: self.billCounter)) Bills "
                self.totalAmount.text = "Total Tax: \(ViewController.fixedCurrency!)\(String (describing: self.taxCounter))"
                //self.totalTax.text = "Tax: \(ViewController.fixedCurrency!)\(String (describing: self.taxCounter))"
                self.billerConnect.reloadData()
            }//end of if let dic
        })//end of dbref

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            if self.billItems.count != self.BillArray.count {
                print ("Stop")
            }
            
            if self.billItems.count == 0 {self.noSign.isHidden = false} else {self.noSign.isHidden = true}
            self.thinking.isHidden = true
            self.thinking.stopAnimating()
        }
        
    }//end of fetch
    
    
        // button on table clicked
        func  approvalClicked(sender:UIButton!) {
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
            fetchBills()
   
    } else {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
        }//end of fispatch
        }//end of else

        }//end button clicked



        
    
    
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
    
    func monther(monthNumber:Int)  {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM"
        monthMMM = fmt.shortMonthSymbols[monthNumber-1]
        print (monthMMM!)
        return
    }
    
    
    // alerts////////////////////////////////////////////////////////////////////////////////////////////
    

}//end of class


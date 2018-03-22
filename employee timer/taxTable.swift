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
    var home = UIImage(named: "home")?.withRenderingMode(.alwaysTemplate)
    let mydateFormat5 = DateFormatter()
    let mydateFormat10 = DateFormatter()
    let mydateFormat20 = DateFormatter()
    
    let dbRef = FIRDatabase.database().reference().child("fRecords")
    let dbRefEmployers = FIRDatabase.database().reference().child("fEmployers")
    let dbRefEmployees = FIRDatabase.database().reference().child("fEmployees")

    var aaa = 0
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
        var pdfDataTable = NSMutableData()
     

    @IBOutlet weak var taxInfo: UIButton!
    @IBAction func taxInfo(_ sender: Any) {
        alert17()
    }
    
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
    var taxMonth2 : Int = 0
    var taxYear2 : Int = 0
    var currentMonth : Int = 0
    var currentYear : Int = 0
    
    @IBOutlet weak var billerConnect: UITableView!
    @IBOutlet weak var thinking: UIActivityIndicatorView!
        @IBOutlet weak var totalBills: UITextField!
    @IBOutlet weak var totalTax: UITextField!
    @IBOutlet weak var totalAmount: UITextField!
    @IBOutlet weak var noSign: UIImageView!
    
    @IBOutlet weak var totalBG: UIView!
    @IBOutlet weak var totalLbl: UITextField!
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
            totalLbl.text = "All Periods"
            filterDecided = 0
            fetchBills()
            filterImageConstrain.constant = 20
            btnFilter.setImage (greenFilter, for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.filterMovement(delay: 1.3)
            }
            }


            @IBAction func currentYearBtn(_ sender: Any) {
            totalLbl.text = "\(self.currentYear)"
            self.title = "Tax: \(self.currentYear)"
            filterImageConstrain.constant = 100
            filterDecided = 3
            fetchBills()
            btnFilter.setImage (redFilter, for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.filterMovement(delay: 1.3)
            }
            }

            @IBAction func lastYearBtn(_ sender: Any) {
            totalLbl.text = "\(self.currentYear-1)"
            self.title = "Tax: \(self.currentYear-1)"
            filterImageConstrain.constant = 180
            filterDecided = 4
            fetchBills()
            btnFilter.setImage (redFilter, for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.filterMovement(delay: 1.3)
            }
            }

    //variablesfrom main
    var employerID = ""
    var employerFromMain = ""
    var employeeID = ""
    
    func shareProcesses(){
        //if reportMode
       
        let textForReport = "* This report made on \(mydateFormat5.string(from: Date())) by WalkWalk APP.** It includes Tax information based on acuural accounting for the defined period.***Tax calculation affected by invoice cancellation timing(if occured)\nand therefore might differ from this mangerial report.\n**** Tax filing should be based on this report and Not general managerial report"
        
        pdfDataTable = pdfDataWithTableView2(tableView: billerConnect, pageHeight: 6*89,totalBG: totalBG, Closing: textForReport as NSString, distance: 90.0)
        self.alert101(printItem: self.pdfDataTable, mailFunction: configuredMailComposeViewController6())
       
    }
    
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

        
        let shareProcess = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(shareProcesses))

        
        let yourBackImage = UIImage(named: "home")
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        self.navigationController?.navigationBar.topItem?.title = " "

        
        //formatting decimal
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .up
        formatter.minimumFractionDigits = 2
        formatter.numberStyle = .currencyAccounting
        
        //Date
        mydateFormat5.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy, (HH:mm)",options: 0, locale: nil)!
        mydateFormat10.dateFormat = DateFormatter.dateFormat(fromTemplate: " MMM d, yyyy", options: 0, locale: Locale.autoupdatingCurrent)!
        mydateFormat20.dateFormat = DateFormatter.dateFormat(fromTemplate: " MMM , yyyy", options: 0, locale: Locale.autoupdatingCurrent)!
      
        btnFilter.setImage (greenFilter, for: .normal)
        btnFilter.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnFilter.addTarget(self, action: #selector(filterMovement(delay:)), for: .touchUpInside)
        filterItem.customView = btnFilter
        
        navigationItem.rightBarButtonItems = [filterItem,shareProcess]

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
        billerConnect.reloadData()
        }//view did appear end
    
        func tableView(_ billerConnect: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 89}
        
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
        if billsForMonth == 1 {billTxt = "invoice"} else {billTxt = "invoices"}
            

        cell.backgroundColor = UIColor.clear
        cell.l1.text = taxMonthItem//arrayOfMonths[indexPath.row]
        cell.l3.text = "Tax: \(ViewController.fixedCurrency!)\(String(taxForMonth.roundTo(places: 2)) as String)"
        let totalWithOut = (totalForMonth-taxForMonth).roundTo(places: 2)
            cell.l2.text = "w/o Tax: \(ViewController.fixedCurrency!)\(String(totalWithOut.roundTo(places: 2)) as String)"
        cell.l5.text = "\(ViewController.fixedCurrency!)\(String(totalForMonth.roundTo(places: 2)) as String)"

        return cell
        }
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        taxMonthRow = self.billerConnect.indexPathForSelectedRow!
            
        if (segue.identifier == "billsForTaxMonth")
        { let billTaxManager = segue.destination as? biller
        print ("presparesegue")
        let components = self.calendar.dateComponents([.year, .month], from: (mydateFormat20.date(from: (arrayOfMonths[(taxMonthRow?.row)!])))!)
        self.taxMonth =   components.month!
        self.taxYear = components.year!
        billTaxManager?.monthToHandle = components.month!
        billTaxManager?.yearToHandle = components.year!
        billTaxManager?.employeeID = employeeID
        billTaxManager?.taxBillsToHandle = true
        billTaxManager?.reportMode = false
        }//end of if (segue...
        }//end of prepare
    
        func fetchBills(){
        connectivityCheck()
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
            let billItem = billStruct()
            billItem.setValuesForKeys(dictionary)
             
             //get the invoice month and year
            let components = self.calendar.dateComponents([.year, .month], from: self.mydateFormat5.date(from: billItem.fBillDate!)!)
                self.taxMonth = components.month!
                self.taxYear = components.year!
             
             //get the status date month and year
            if billItem.fBillStatusDate != nil { let components2 = self.calendar.dateComponents([.year, .month], from: self.mydateFormat5.date(from: billItem.fBillStatusDate!)!)
                self.taxMonth2 = components2.month!
                self.taxYear2 = components2.year!
                } else  {self.taxMonth2 = 0;self.taxYear2 = 0}
                
                
            func inFilterBilldate() {
            if self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)] == nil {
            self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)] = Double(billItem.fBillTax!)!; self.taxCounter += Double(billItem.fBillTax!)!
            self.byMonthTotal[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)] = Double(billItem.fBillTotalTotal!)!;self.AmountCounter += Double(billItem.fBillTotalTotal!)!
            self.byMonthBills[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)] = 1
            }else{
            self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)] = self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)]! + Double(billItem.fBillTax!)!; self.taxCounter += Double(billItem.fBillTax!)!
            self.byMonthTotal[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)] = self.byMonthTotal[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)]! + Double(billItem.fBillTotalTotal!)!;self.AmountCounter += Double(billItem.fBillTotalTotal!)!
            self.byMonthBills[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)] = self.byMonthBills[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillDate!)!)]! + 1
            }
            }//end of infiltermain
                
            func inFilterBillStatusDate() {
            if billItem.fBillStatus == "Cancelled"{
            if self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillStatusDate!)!)] == nil {
            self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillStatusDate!)!)] = -Double(billItem.fBillTax!)!; self.taxCounter -= Double(billItem.fBillTax!)!
                self.byMonthTotal[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillStatusDate!)!)] = -Double(billItem.fBillTotalTotal!)!;self.AmountCounter -= Double(billItem.fBillTotalTotal!)!
            self.byMonthBills[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillStatusDate!)!)] = 1
            }else{
            self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillStatusDate!)!)] = self.byMonthTax[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillStatusDate!)!)]! - Double(billItem.fBillTax!)!; self.taxCounter -= Double(billItem.fBillTax!)!
            self.byMonthTotal[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillStatusDate!)!)] = self.byMonthTotal[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillStatusDate!)!)]! - Double(billItem.fBillTotalTotal!)!;self.AmountCounter -= Double(billItem.fBillTotalTotal!)!
            self.byMonthBills[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillStatusDate!)!)] = self.byMonthBills[self .mydateFormat20.string(from: self.mydateFormat5.date(from:billItem.fBillStatusDate!)!)]! - 1
            }
            }
            }//end of infilterbillstatusdate
                
            func inFilter() {
            if self.self.filterDecided == 3 && self.taxYear == self.currentYear {inFilterBilldate()}
            if self.self.filterDecided == 4 && self.taxYear == self.currentYear-1 {inFilterBilldate()}
            if self.filterDecided == 0  {inFilterBilldate()}
            if self.self.filterDecided == 3 && self.taxYear2 == self.currentYear {inFilterBillStatusDate()}
            if self.self.filterDecided == 4 && self.taxYear2 == self.currentYear-1 {inFilterBillStatusDate()}
            if self.filterDecided == 0  {inFilterBillStatusDate()}



            // if billItem.fBillStatus != "Cancelled"{
            self.monthSorter =  Array(self.byMonthTax.keys.map{$0})
            self.uniqueTaxMonths = Array(Set(self.monthSorter))
            self.uniqueTaxMonthsdateFormat = self.uniqueTaxMonths.map {self.mydateFormat20.date(from: $0)! }
            self.uniqueTaxMonthsdateFormat.sort { $0.compare($1) == .orderedDescending }
            self.arrayOfMonths = self.uniqueTaxMonthsdateFormat.map { self.mydateFormat20.string(from: $0)}
            //}

            //self.billItems.append(billItem);if billItem.fBillStatus != "Cancelled" {self.billCounter+=1; self.AmountCounter += Double(billItem.fBillTotalTotal!)!;
            // self.taxCounter += Double(billItem.fBillTax!)!}
            // ;self.BillArray.append(billItem.fBill!);self.BillArrayStatus.append(billItem.fBillStatus!)
            //self.taxCounter += Double(billItem.fBillTax!)!}
            }//end of in filter


            switch self.filterDecided {
            case 0:inFilter()
            case 3:if (self.currentYear == self.taxYear || self.currentYear == self.taxYear2) {inFilter()}
            case 4:if self.currentYear-1 == self.taxYear || self.currentYear == self.taxYear2-1 {inFilter()}
            default: print ("nothing")
            } //end of switch


                
            self.totalAmount.text = "\(ViewController.fixedCurrency!)\(String(describing: self.AmountCounter.roundTo(places: 2)))"
            self.totalTax.text = "Tax: \(ViewController.fixedCurrency!)\(String (describing: self.taxCounter.roundTo(places: 2)))"
            self.totalBills.text = "w/o Tax: \(String(self.AmountCounter.roundTo(places: 2) - self.taxCounter.roundTo(places: 2)))"
                
                print (self.AmountCounter)
                
                
                if self.AmountCounter == 0 {self.noSign.isHidden = false} else {self.noSign.isHidden = true}
                self.thinking.isHidden = true
                self.thinking.stopAnimating()


            self.billerConnect.reloadData()
            }//end of if let dic
            } , withCancel: { (Error) in
            self.alert30()
            print("error from FB")})//end of dbref


            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                if self.billItems.count != self.BillArray.count {
                    print ("Stop")
                }
                
                if self.AmountCounter == 0 {self.noSign.isHidden = false;self.taxInfo.isHidden = true} else {self.noSign.isHidden = true;self.taxInfo.isHidden = false}
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
    
    //func for mail
    func  configuredMailComposeViewController6() -> MFMailComposeViewController {
        let mailComposerVC2 = MFMailComposeViewController()
        mailComposerVC2.mailComposeDelegate = self
        mailComposerVC2.setSubject("TAX report from WalkWalk App")
        mailComposerVC2.setMessageBody("This report is based on acurral accounting for tax filing purposes and it is attached for your records.\r\n\r\nRegards\r\n \(ViewController.fixedName!) \(ViewController.fixedLastName!)", isHTML: false)
        mailComposerVC2.setToRecipients([ViewController.fixedemail])
        mailComposerVC2.addAttachmentData( pdfDataTable as Data, mimeType: "application/pdf", fileName: "Tax report")
        return mailComposerVC2
    }//end of MFMailcomposer
    
    func showSendmailErrorAlert() {
        let sendMailErorrAlert = UIAlertController(title:"Could Not Send Email", message: "Your device could not send e-mail. Please check e-mail configuration and try again.",preferredStyle: .alert)
        sendMailErorrAlert.message = "error occured"
        //seems that it does not work check!!!!
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,didFinishWith result: MFMailComposeResult, error: Error?) {
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
    // alerts////////////////////////////////////////////////////////////////////////////////////////////
    
    func alert17(){
        let alertController17 = UIAlertController(title: ("Tax calaculation") , message: "Tax accural calculation is based on invoice cancellation timing(if occured) and therefore tax and invoice allocation can be different from general report. Tax filing should be based on 'Tax'(this module) and Not 'Reports'", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
        }
        alertController17.addAction(OKAction)
        self.present(alertController17, animated: true, completion: nil)
    }
}//end of class


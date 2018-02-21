//
//  fetchBills.swift
//  perSession
//
//  Created by uri enat on 05/02/2018.
//  Copyright © 2018 אורי עינת. All rights reserved.
//

import Foundation
extension(biller){

        func fetchHandler() {
           
            fetch {self.final()}
            
          
        }

    
            func fetch(completion: @escaping () -> () ){
            connectivityCheck()
            a = 0
            var billsNumber = 0
            billItems.removeAll()
            BillArray.removeAll()
            BillArrayStatus.removeAll()
            self.billCounter = 0
            self.taxCounter = 0
            self.AmountCounter = 0
                
            self.dbRefEmployees.child(employeeID).child("myBills").observeSingleEvent(of:.value, with: { (snapshot) in
                print ("count:\(snapshot.childrenCount)")
                billsNumber = Int(snapshot.childrenCount)
                
            
            self.dbRefEmployees.child(self.employeeID).child("myBills").observe(.childAdded, with: { (snapshot) in

            if let dictionary =  snapshot.value as? [String: AnyObject] {
            print ("snappp\(snapshot.value!)")
            let billItem = billStruct()
            billItem.setValuesForKeys(dictionary)

            let components = self.calendar.dateComponents([.year, .month], from: self.mydateFormat5.date(from: billItem.fBillDate!)!)
            self.recordMonth = components.month!
            self.recordYear = components.year!
            print (self.recordMonth-1,self.recordYear-1)

            func inFilter() {
            if  billItem.fBalance == nil || billItem.fBalance == "" {self.remainingBalance = (billItem.fBillTotalTotal!)} else {self.remainingBalance = billItem.fBalance!}
            if self .employerID != ""{
            if self.StatusChoice == "Not Paid" && (billItem.fBillStatus == "Billed" || billItem.fBillStatus == "Partially") && billItem.fBillEmployer == self.employerID {
                print (self.remainingBalance)
                
            self.billItems.append(billItem); self.billCounter+=1 ;self.AmountCounter += Double(self.remainingBalance!)!;self.taxCounter += Double(billItem.fBillTax!)!
            ; self.BillArray.append(billItem.fBill!); self.BillArrayStatus.append(billItem.fBillStatus!)
            }
            else  if self.StatusChoice == "All" && billItem.fBillEmployer == self.employerID  {self.billItems.append(billItem);if billItem.fBillStatus != "Cancelled" {self.billCounter+=1; self.AmountCounter += Double(billItem.fBillTotalTotal!)!;
            self.taxCounter += Double(billItem.fBillTax!)!}
            ;self.BillArray.append(billItem.fBill!);self.BillArrayStatus.append(billItem.fBillStatus!)}
            }//end of spesic employer

            if self .employerID == "" {
            if self.StatusChoice == "All"  {self.billItems.append(billItem);if billItem.fBillStatus != "Cancelled" {self.billCounter+=1; self.AmountCounter += (Double(billItem.fBillTotalTotal!)!);  self.taxCounter += Double(billItem.fBillTax!)!};    self.BillArray.append(billItem.fBill!);self.BillArrayStatus.append(billItem.fBillStatus!)}
            else if self.StatusChoice == "Not Paid" &&  (billItem.fBillStatus == "Billed" || billItem.fBillStatus == "Partially"){self.billItems.append(billItem);self.billCounter+=1; self.AmountCounter += Double(self.remainingBalance!)!;self.taxCounter += Double(billItem.fBillTax!)!;self.BillArray.append(billItem.fBill!);self.BillArrayStatus.append(billItem.fBillStatus!)}
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

            }//end of if let
            
            self.a += 1
            print ("a before\(self.a)")
                if billsNumber == self.a{ completion()}
                
            }
            , withCancel: { (Error) in
            self.alert30()
            print("error from FB")}
            )//end of dbref

                
            })//end of count dbref
                
            }//end of fetch

            func final(){
                
            print ("a for final\(a)")
            self.billerConnect.reloadData()
            if self.billItems.count != self.BillArray.count {
            print ("Stop")
                
            }

            self.thinking.isHidden = true
            self.thinking.stopAnimating()
            if self.billItems.count == 0 {self.noSign.isHidden = false} else {self.noSign.isHidden = true}
            self.totalBills.text = "\(whenInvoices!)-\(String(describing: self.billCounter)) Bills"
            self.totalAmount.text = "\(ViewController.fixedCurrency!)\(String(describing: self.AmountCounter))"
            if ViewController.taxOption == "Yes"{ self.totalTax.text = "* Total included tax";self.totalBg.backgroundColor = self.blueColor} else { self.totalTax.text = "* Cancelled bills excluded";self.totalBg.backgroundColor = self.blueColor}
            if self.StatusChoice == "Not Paid" {self.totalTax.text = "* Balance only"; self.totalBg.backgroundColor = self.redColor}

            self.StatusChosen.isEnabled = true
            
            showRow()

            }
    
    
        func showRow(){
            print (biller.rowMemory)
            
        if biller.rowMemory != nil {
        var index = IndexPath.init(row: biller.rowMemory!, section: 0)
        self.billerConnect.selectRow(at: index, animated: true, scrollPosition: .none)
        self.billerConnect.scrollToRow(at: index, at: .middle, animated: false)
        biller.rowMemory = nil
        }
        }
    
        func fetchBillInfo(){
        self.dbRefEmployees.queryOrderedByKey().queryEqual(toValue: self.employeeID).observeSingleEvent(of: .childAdded, with: { (snapshot) in

        let counterForMail = (snapshot.childSnapshot(forPath: "fCounter").value as! String)
        let taxSwitch = (snapshot.childSnapshot(forPath: "fSwitcher").value as! String)
        //let taxation = (snapshot.childSnapshot(forPath: "fTaxPrecentage").value as! String)
        if snapshot.childSnapshot(forPath: "fBillinfo").value as! String != nil {self.billInfo = "\(snapshot.childSnapshot(forPath: "fBillinfo").value as! String)"} else {self.billInfo = ""}
        if snapshot.childSnapshot(forPath: "fTaxId").value as! String == nil || snapshot.childSnapshot(forPath: "fTaxId").value as! String == "" {self.taxId = ""} else {self.taxId = "Tax ID: \(snapshot.childSnapshot(forPath: "fTaxId").value as! String)"} 
        self.address = (snapshot.childSnapshot(forPath: "fAddress").value as! String)
        self.taxForBlock = "VAT"

        if  taxSwitch == "Yes" {
        self.taxationBlock = ("Total (without \(self.taxForBlock!)): \(ViewController.fixedCurrency!)\(self.midCalc3!)\r\n\(self.taxForBlock!): \(ViewController.fixedCurrency!)\(self.midCalc!)")
        }//if taxswitch = yes
        else {self.taxationBlock = ""}
        if self.paymentReference != "" {self.refernceBlock = "Ref:\(self.paymentReference!)"} else {self.refernceBlock = ""}
        if self.fully == false { self.self.recieptPayment = self.balance!} else {self.recieptPayment = self.partialPayment.text!}

        self.documentName = "Reciept \(self.BillArray[self.buttonRow])-\(self.recieptCounter!)"; if self.paymentSys == "other" || self.paymentSys == ""{self.paymentBlock = ("Payment of \(ViewController.fixedCurrency!)\(self.recieptPayment!) made: \(self.mydateFormat10.string(from:self.mydateFormat5.date(from: self.recieptDate!)!)) - \(self.refernceBlock) ")
        }

        if self.paymentReference != "" {self.refernceBlock = "Ref:\(self.paymentReference!)"} else {self.refernceBlock = ""}
        if self.paymentSys! == "other" || self.paymentSys == ""{// payment == other
        self.paymentBlock = ("Payment of \(ViewController.fixedCurrency!)\(self.recieptPayment!) made: \(self.mydateFormat10.string(from:self.mydateFormat5.date(from: self.recieptDate!)!))  \(self.refernceBlock!) ")
        } else {self.paymentBlock = "Payment of \(ViewController.fixedCurrency!)\(self.recieptPayment!) made by \(self.paymentSys!) \(self.refernceBlock!) - \(self.mydateFormat10.string(from:self.mydateFormat5.date(from: self.recieptDate!)!))"
        }
        }
        , withCancel: { (Error) in
        self.alert30()
        print("error from FB")}
        )
        }//end of billing
    
        func recieptProcess() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0){
        self.thinking.isHidden = false
        self.thinking.startAnimating()
        }
        fetchBillInfo()
        self.dbRefEmployees.child(employeeID).child("myBills").child(String("-"+BillArray[buttonRow])).observeSingleEvent(of: .value,with: {(snapshot) in
        self.employerID = (snapshot.childSnapshot(forPath: "fBillEmployer").value! as? String)!
        if  (snapshot.childSnapshot(forPath: "fBalance").value! as? String) != nil { self.balance = (snapshot.childSnapshot(forPath: "fBalance").value! as? String)!} else {self.balance = (snapshot.childSnapshot(forPath: "fBillTotalTotal").value! as? String)!}
        if  (snapshot.childSnapshot(forPath: "fRecieptCounter").value! as? String) != nil { self.recieptCounter = (snapshot.childSnapshot(forPath: "fRecieptCounter").value! as? String)!} else {self.recieptCounter = "1"}
        self.dbRefEmployers.child(self.employerID).observeSingleEvent(of:.value, with: {(snapshot) in

        self.accountAdress = String(describing: snapshot.childSnapshot(forPath: "fAddress").value!) as String!
        self.accountName = String(describing: snapshot.childSnapshot(forPath: "fName").value!) as String!
        self.accountLastName = String(describing: snapshot.childSnapshot(forPath: "fEmployer").value!) as String!
        self.accountParnet = String(describing: snapshot.childSnapshot(forPath: "fParent").value!) as String!
        }
        , withCancel: { (Error) in
        self.alert30()
        print("error from FB")}
        )
        }
        , withCancel: { (Error) in
        self.alert30()
        print("error from FB")}
        )

        recieptDate = mydateFormat5.string(from: Date())

        DispatchQueue.main.asyncAfter(deadline: .now()+2){/// used to be 2
        print (self.billInfo)
        print (Double(self.balance!) as Double!)
        print (Double(self.partialPayment.text!))
        if self.fully == false {self.remainingBalance = "0.0"} else {self.remainingBalance = String(Double(self.balance!)! - Double(self.partialPayment.text!)!)}
        if Double (self.remainingBalance!) != 0.0 {self.statusTemp = "Partially"}

        if  ViewController.professionControl! == "Tutor" && self.accountParnet != "" {self.contact = "\(self.accountParnet) \(self.accountLastName) - \(self.accountName)"} else {
        self.contact = "\(self.accountName) \(self.accountLastName)"}

        self.recieptMailSaver = "\(self.mydateFormat10.string(from: Date()))\r\n\r\n\r\n\(ViewController.fixedName!) \(ViewController.fixedLastName!)\r\n\(self.billInfo!)\r\n\(self.taxId!)\r\n\(self.address!)\r\n\(self.seprator2)\(self.seprator2)\r\n\r\nRecieved from:\r\n\(self.contact!)\r\n\(self.accountAdress)\r\n\(self.seprator2)\r\n\r\n\r\nBalance Due from invoice \(self.BillArray[self.buttonRow]): \(ViewController.fixedCurrency!)\(self.balance!)\r\n\(self.paymentBlock!)\r\n\r\n\(self.seprator2)\(self.seprator2)\r\nRemaining Balance Due from Invoice \(self.BillArray[self.buttonRow]): \(ViewController.fixedCurrency!)\(self.remainingBalance!)\r\n\r\n\r\nMade by PerSession app. "

        self.recoveredreciept = self.recieptMailSaver
        print (self.recieptMailSaver)
        print (self.recoveredreciept)

        //update bill with DB
        self.dbRefEmployees.child(self.employeeID).child("myBills").child(String("-"+self.BillArray[self.buttonRow])).updateChildValues(["fBillStatus": self.statusTemp, "fBillStatusDate":
        self.self.mydateFormat5.string(from: Date()), "fBalance" : self.remainingBalance,"fRecieptCounter":String(Int(self.recieptCounter!)!+1),
                                      //"fPaymentMethood": self.paymentSys, "fPaymentReference": self.paymentReference,"fRecieptDate":self.mydateFormat5.string(from: Date()),"fBillRecieptMailSaver":self.recieptMailSaver
        ], withCompletionBlock: { (error) in}) //end of update.

        self.dbRefEmployees.child(self.employeeID).child("myReciepts").child(String("-"+self.BillArray[self.buttonRow])).child(self.recieptCounter!).updateChildValues(["fPaymentMethood": self.paymentSys, "fPaymentReference": self.paymentReference,"fRecieptDate":self.mydateFormat5.string(from: Date()),"fBillRecieptMailSaver":self.recieptMailSaver,"fActive":"Yes","fBill":self.BillArray[self.buttonRow],"fDocument":"Reciept \(self.BillArray[self.buttonRow])-\(self.recieptCounter!)","fRecieptAmount": (self.recieptPayment!) ], withCompletionBlock: { (error) in}) //end of update.

        self.dbRefEmployers.child(self.employerID).updateChildValues(["fLast":"Last paid: \(self.mydateFormat10.string(from: Date()))" ], withCompletionBlock: { (error) in})
        self.dbRefEmployees.child(self.employeeID).child("myEmployers").updateChildValues([(self.employerID):Int((self.mydateFormat5.date(from: self.mydateFormat5.string(from: Date()))?.timeIntervalSince1970)!)])

        self.referenceTxt.text = ""
        self.paymentReference = ""
        self.paymentSys = ""
        self.recieptDate = ""
        self.paymentMethood.selectedSegmentIndex = -1
        self.referenceTxt.isHidden = true
            
        self.performSegue(withIdentifier: "presentReciept", sender: self.recieptMailSaver)
        }//end of if biller
        }//end of billprocess


}//end of ext/////////////////////////////

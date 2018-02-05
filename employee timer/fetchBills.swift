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
        myGroupMemory.enter()
        fetch {
        self.final()
        }
        myGroupMemory.notify(queue: DispatchQueue.main) {self.showRow()}
        }

    
            func fetch(completion: @escaping () -> () ){
            connectivityCheck()
            myGroupMemory.enter()

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
            if  billItem.fBalance == nil{self.remainingBalance = (billItem.fBillTotalTotal!)} else {self.remainingBalance = billItem.fBalance!}
            if self .employerID != ""{
            if self.StatusChoice == "Not Paid" && (billItem.fBillStatus == "Billed" || billItem.fBillStatus == "Partially") && billItem.fBillEmployer == self.employerID {
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



            }

            self.a += 1
            print ("a\(self.a)")
            completion()

            }
            , withCancel: { (Error) in
            self.alert30()
            print("error from FB")}
            )//end of dbref




            }//end of fetch

            func final(){
            print ("final")
            self.billerConnect.reloadData()
            if self.billItems.count != self.BillArray.count {
            print ("Stop")
            }

            self.thinking.isHidden = true
            self.thinking.stopAnimating()
            if self.billItems.count == 0 {self.noSign.isHidden = false} else {self.noSign.isHidden = true}

            if self.billItems.count == 0 {self.noSign.isHidden = false} else {self.noSign.isHidden = true}

            self.totalBills.text = "\(String(describing: self.billCounter)) Bills"
            self.totalAmount.text = "\(ViewController.fixedCurrency!)\(String(describing: self.AmountCounter))"
            if ViewController.taxOption == "Yes"{ self.totalTax.text = "* Total included tax";self.totalBg.backgroundColor = self.blueColor} else { self.totalTax.text = "* Cancelled bills excluded";self.totalBg.backgroundColor = self.blueColor}
            if self.StatusChoice == "Not Paid" {self.totalTax.text = "* Balance only"; self.totalBg.backgroundColor = self.redColor}

            self.StatusChosen.isEnabled = true
            //self.myGroupMemory.leave()

            }
    
    
    
    
    
        func showRow(){
        if self.rowMemory != nil {
        var index = IndexPath.init(row: self.rowMemory!, section: 0)
        self.billerConnect.selectRow(at: index, animated: true, scrollPosition: .none)
        self.rowMemory = nil
        }
        }


}//end of ext/////////////////////////////

//
//  fetch.swift
//  perSession
//
//  Created by uri enat on 04/02/2018.
//  Copyright © 2018 אורי עינת. All rights reserved.
//

import Foundation

        extension(newVCTable){
        func fetch(completion: @escaping () -> () ){
        connectivityCheck()
        itemSum = 0
        eventCounter = 0
        self.dateDuplicate.removeAll()
        self.idArray.removeAll()
        self.indicationArray.removeAll()
        self.amountArray.removeAll()
        self.appArray.removeAll()
        self.records.removeAll()
        self.FbArray.removeAll()
        self.FbArray2.removeAll()
        self.firstTime = true
        self.firstTimeGeneral = true
        htmlReport = nil
        self.tableConnect.reloadData()
        dbRefEmployers.child(self.employerID).child("myEmployees").queryOrderedByKey().queryEqual(toValue: employeeID).observeSingleEvent(of: .childAdded, with:  {(snapshot) in
        self.Employerrate = Double(snapshot.childSnapshot(forPath: "fEmployerRate").value! as! Double)


        self.dbRefEmployers.child(self.employerID).child("fEmployerRecords").queryOrderedByValue().observeSingleEvent(of: .value, with: { (snapshot) in
        print("id of employers34\(String(describing: snapshot.value))")
        if snapshot.value as? [String : AnyObject] == nil {
        print ("nillllll!!!")
            self.final()// check if not disturbing
        }else{
        self.idOfEmployers   = snapshot.value as! [String : AnyObject]
        func sortFunc   (_ s1: (key: String, value: AnyObject), _ s2: (key: String, value: AnyObject)) -> Bool {
        return   s2.value as! Int > s1.value as! Int
        }

        self.FbArray = (self.idOfEmployers.sorted(by: sortFunc) as [AnyObject] )
        print ("recordsFB\(self.FbArray)")

        for j in 0...(self.FbArray.count-1){
        let splitItem = self.FbArray[j] as! (String, AnyObject)
        let split2  = splitItem.0
        self.FbArray2.append(split2)
        }

        for i in 0...(self.FbArray2.count-1)  {
        if i == 0 {self.thinking.isHidden = false
        self.thinking.startAnimating()
        }

        self.dbRef.child((self.FbArray2[i])).observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
        let record = recordsStruct()
        record.setValuesForKeys(dictionary)
        if record.fEmployeeRef != self.employeeID {
        //do nothing
        }else{
        //array for record ID
        let id = snapshot.key
        let appStatus = record.fStatus
        let indicationItem = record.fIndication3
        if record.fIndication3 ==  "📄" {self.amountItem = Double(record.fSpecialAmount!)!} else {self.amountItem = 0.00}
        let dateDuplicate = record.fIn
        if record.fStatus == "Approved" && record.fSpecialAmount == nil {self.eventCounter+=1}
        if record.fStatus == "Approved" && record.fSpecialAmount != nil {self.itemSum += Double(record.fSpecialAmount!)!}

        let period: Int = 5//self.periodChosen.selectedSegmentIndex

        var calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, ], from: self.mydateFormat5.date(from: record.fIn!)!)
        let today = calendar.dateComponents([.year, .month, .day], from: Date())
        self.recotdMonth = components.month!
        self.recordYear = components.year!
        self.currentMonth = today.month!
        self.currentYear = today.year!

        func cases() {
        self.currentYear = today.year!
        self.records.append(record)
        self.idArray.append(id)
        self.indicationArray.append(indicationItem!)
        self.amountArray.append(self.amountItem)
        if record.fIndication3 !=  "📄"  {self.dateDuplicate.append(dateDuplicate!)}
        self.appArray.append(appStatus!)
        self.tableConnect.reloadData()

        if record.fIndication3 == "📄" {if self.firstTimeGeneral == true {self.csv2.append("Following general items included:\r\n");self.firstTimeGeneral = false };self.csv2.append("\(record.fSpecialItem!)");

        self.csv2.append(".......................................");self.csv2.append(ViewController.fixedCurrency!); self.csv2.append(record.fSpecialAmount!);self.csv2.append("\r\n")}
        else {if self.firstTime == true {self.csv2.append("\r\nThese are the sessions included:\r\n");self.firstTime = false}

        if ViewController.dateTimeFormat == "DateTime" {print (record.fIn!);self.csv2.append("\(self.mydateFormat11.string(from: self.mydateFormat5.date(from: record.fIn!)!))");
        self.csv2.append("\r\n")
        }
        else {self.csv2.append("\( self.mydateFormat10.string(from: self.mydateFormat5.date(from: record.fIn!)!))");self.csv2.append("\r\n") }
        }//end of else

        }// end of cases func


        if self.Status == "Approved" {if record.fStatus == "Approved" {cases()}}
        else if record.fStatus == "Pre" || record.fStatus == "Approved" {cases()}
        else if record.fStatus == nil
        {
        print ("stop there is no status!")
        }
        }//end of else of fout is not empty
        }// end of if let dictionary
        if i == self.FbArray2.count-1 {completion()}
        }, withCancel: { (Error) in
        self.alert30()
        print("error from FB")}
        )//end of dbref2
        }//end of loop
        }//end of elseif snapshot.value as? String == nil

        }, withCancel: { (Error) in
        self.alert30()
        print("error from FB")}
        )//end of dbref1the second one
        }, withCancel: { (Error) in
        self.alert30()
        print("error from FB")}
        ) //end of dbref employers0 the first one

        }//end of fetch

        func final(){
        print ("final")
        sleep(UInt32(1))
        self.StatusChosen.isEnabled = true
        self.periodChosen.isEnabled = true
            
        print (billStarted)

        if self.billStarted == false && self.billPayStarted == false   { self.thinking.stopAnimating()//}

        if self.eventCounter == 0 {self.eventsLbl.text = " No Due Sessions";if  self.itemSum == 0{self.toolbar1.isHidden = true;self.noSign.isHidden = false}else{self.toolbar1.isHidden = false;self.noSign.isHidden = true}}
        else if self.eventCounter == 1 {self.toolbar1.isHidden = false;self.billSender.isEnabled = true;self.billPay.isEnabled = true;self.eventsLbl.text = "\(String(self.eventCounter)) Due session";self.noSign.isHidden = true}
        else {self.toolbar1.isHidden = false;self.billSender.isEnabled = true;self.billPay.isEnabled = true;self.eventsLbl.text = "\(String(self.eventCounter)) due Sessions";self.noSign.isHidden = true}

        if self.Employerrate == 0.0 { noRateInfo.isHidden = false} else {noRateInfo.isHidden = true}
        self.calc = (Double(self.eventCounter))*(self.Employerrate) + self.itemSum
        self.perEvents.text =  String("\(ViewController.fixedCurrency!)\(self.Employerrate) /session")

        if ViewController.taxOption == "Yes" && ViewController.taxCalc == "Over" {let totalForExcluded = Double(Double(ViewController.taxation!)!*self.calc*0.01).roundTo(places: 2) + Double(self.calc).roundTo(places: 2);self.amount.text =  ("\(ViewController.fixedCurrency!)\(String(totalForExcluded))")
        } else {
        self.amount.text =  ("\(ViewController.fixedCurrency!)\(String(Double(self.calc).roundTo(places: 2)))")}

        if ViewController.taxOption == "Yes" {self.taxIncluded.isHidden = false } else {self.taxIncluded.isHidden = true}
        if self.duplicateChecked == false {self.checkDuplicate()}
            }// end bill started = true
        if self.billStarted == true {  self.myGroup.leave() }
        if self.billPayStarted == true  {self.myGroupBillPay.leave()}
        }
        }

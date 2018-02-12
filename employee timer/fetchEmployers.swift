//
//  fetchEmployers.swift
//  perSession
//
//  Created by uri enat on 09/02/2018.
//  Copyright © 2018 אורי עינת. All rights reserved.
//

import Foundation

extension(ViewController){
func fetchEmployers() {
        // connectivityCheck()
        self.employerIdArray.removeAll()
        self.employerIdArray2.removeAll()
        self.pickerData.removeAll()
    self.filteredEmployerForList.removeAll()
        self.imageArray.removeAll()
        self.nameData.removeAll()
        self.lastDocument.removeAll()
        self.activeData.removeAll()

        self.dbRefEmployee.child(self.employeeIDToS).child("myEmployers").observeSingleEvent(of: .value, with:{(snapshot) in
        self.listOfEmployers = snapshot.value as! [String : AnyObject] as! [String : Int]
        func sortFunc   (_ s1: (key: String, value: Int), _ s2: (key: String, value: Int)) -> Bool {
        return   s2.value > s1.value
        }

        self.employerIdArray = (self.listOfEmployers.sorted(by: sortFunc) as [AnyObject]  )

        for j in 0...(self.employerIdArray.count-1){
        let splitItem = self.employerIdArray[j] as! (String, Int)
        print (splitItem)

        let split2    = splitItem.0
        print (split2)

        if split2 != "New Dog" {
        self.employerIdArray2.append(split2 as AnyObject) } else {//do nothing
        }
        }//end of j loop


        if self.employerIdArray2.isEmpty == true {self.menuItem.isEnabled = false; self.thinking2.stopAnimating();  self.arrow.isHidden = false; self.arrowMove()

        } else {
        self.menuItem.isEnabled = true
        self.arrow.isHidden = true
        for iIndex in 0...(self.employerIdArray2.count-1){
        self.dbRefEmployer.child(self.employerIdArray2[iIndex] as! String).observeSingleEvent(of: .value, with:{ (snapshot) in
        self.employerItem = String(describing: snapshot.childSnapshot(forPath: "fEmployer").value!) as String!
        //self.pickerData.append(self.employerItem  )

        print(String(describing: snapshot.childSnapshot(forPath: "fLast").value!) as String!)


        if String(describing: snapshot.childSnapshot(forPath: "fLast").value!) as String! != "" {self.lastDocumentItem = String(describing: snapshot.childSnapshot(forPath: "fLast").value!) as String!} //else {self.lastDocumentItem = ""}
        self.dogItem = String(describing: snapshot.childSnapshot(forPath: "fName").value!) as String!
        self.nameData.append(self.dogItem  )
        self.lastDocument.append(self.lastDocumentItem)
           
            var employerToAdd:employerStruct = employerStruct( accountName:"\(self.dogItem) \(self.employerItem)" , employerRef: self.employerIdArray2[iIndex] as! String)
        self.employerForList.append(employerToAdd)
            

        self.pickerData.append("\(self.dogItem) \(self.employerItem)" )

        self.activeItem =  snapshot.childSnapshot(forPath: "fActive").value as? Bool
        self.activeData.append(self.activeItem! )

        self.profileImageUrl = snapshot.childSnapshot(forPath: "fImageRef").value as! String!
        //  self.profileImageUrl = "https://firebasestorage.googleapis.com/v0/b/persession-45987.appspot.com/o/Myprofile.png?alt=media&token=263c8fdb-9cca-4256-9d3b-b794774bf4e1"
        self.imageArray.append(self.profileImageUrl)

            
            
        if iIndex == (self.employerIdArray2.count-1) {
        print (self.filteredEmployerForList.count)
            
       

            print (self.employerForList)
        self.filteredEmployerForList = self.employerForList
     ///   self.notFilteredList = self.pickerData
        self.thinking2.stopAnimating()
          
            if self.filteredEmployerForList.count > 8 {
                if #available(iOS 11.0, *) {
                    self.navigationItem.searchController = self.searchController
                } else {
                    self.employerList.tableHeaderView = self.searchController.searchBar
                }
            }//end of >4

        self.employerList.isUserInteractionEnabled = true
        self.employerListBottom.priority = 750; self.employerListHeiget.priority = 1000;self.employerListTop.constant = 30.0;self.employerListBottom.constant = 30
        self.employerList.reloadData()

        self.employerList.isHidden = false;

        self.postTimerView()//check if solve the bug of view interaction


        }

        }, withCancel: { (Error) in
        self.alert30(); print(Error.localizedDescription)
        print("error from FB")})// end of dbrefemployer

        }//end of i loop
        }//end of idarray2 is empty

        }, withCancel: { (Error) in
        self.alert30(); print(Error.localizedDescription)
        print("error from FB")})// end of
}//end of fetch employer

}

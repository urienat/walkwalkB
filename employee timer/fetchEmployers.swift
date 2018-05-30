//  fetchEmployers.swift
//  perSession
//
//  Created by uri enat on 09/02/2018.
//  Copyright © 2018 אורי עינת. All rights reserved.

        import Foundation

        extension(ViewController){
        func fetchEmployers() {
        self.employerIdArray.removeAll()
        self.employerIdArray2.removeAll()
        self.employerForList.removeAll()
        self.filteredEmployerForList.removeAll()
        connectivityCheck()


        self.dbRefEmployee.child(self.employeeIDToS).child("myEmployers").observeSingleEvent(of: .value, with:{(snapshot) in
        self.listOfEmployers = snapshot.value as! [String : AnyObject] as! [String : Int]
        func sortFunc   (_ s1: (key: String, value: Int), _ s2: (key: String, value: Int)) -> Bool {
        return   s2.value > s1.value
        }

        self.employerIdArray = (self.listOfEmployers.sorted(by: sortFunc) as [AnyObject]  )

        for j in 0...(self.employerIdArray.count-1){
        let splitItem = self.employerIdArray[j] as! (String, Int)
        print (splitItem)

        let split2   = splitItem.0

        if split2 != "New Dog" {
        self.employerIdArray2.append(split2 as AnyObject) } else {//do nothing
        }
        }//end of j loop


            if self.employerIdArray2.isEmpty == true {self.menuItem.isEnabled = false; self.thinking2.stopAnimating();  self.arrow.isHidden = false; self.arrowMove(instruct: self.arrow)

        } else {
        self.menuItem.isEnabled = true
        self.arrow.isHidden = true
        for iIndex in 0...(self.employerIdArray2.count-1){
        self.dbRefEmployer.child(self.employerIdArray2[iIndex] as! String).observeSingleEvent(of: .value, with:{ (snapshot) in
        
        self.employerItem = String(describing: snapshot.childSnapshot(forPath: "fEmployer").value!) as String!

            
            
        if String(describing: snapshot.childSnapshot(forPath: "fLast").value!) as String! != "" {self.lastDocumentItem = String(describing: snapshot.childSnapshot(forPath: "fLast").value!) as String!} //else {self.lastDocumentItem = ""}
        self.dogItem = String(describing: snapshot.childSnapshot(forPath: "fName").value!) as String!
           
            
            
            self.profileImageUrl = snapshot.childSnapshot(forPath: "fImageRef").value as! String! 
          if self.profileImageUrl == "" {
                print ("empty image")
            self.profileImageUrl = "https://firebasestorage.googleapis.com/v0/b/persession-45987.appspot.com/o/perSessionImage.jpg?alt=media&token=078c12de-f291-43a6-82d4-f68ac83cd9c9"
                
            }
            
            
            if  (snapshot.childSnapshot(forPath: "fSesQty").value as? String) == nil{
            self.sesQtyTemp = "0"
            } else {  print ("qty:\(snapshot.childSnapshot(forPath: "fSesQty").value as! String)")
                self.sesQtyTemp = (snapshot.childSnapshot(forPath: "fSesQty").value as! String)}
            if self.sesQtyTemp! != "+" {
                if Int (self.sesQtyTemp!)! < 0 {self.sesQtyTemp = "0" }}
            
            
            
            
          

            let employerToAdd:employerStruct = employerStruct( accountName:"\(self.dogItem) \(self.employerItem)" , employerRef: self.employerIdArray2[iIndex] as! String, activeAccount: (snapshot.childSnapshot(forPath: "fActive").value as! Bool), lastDocAccount: self.lastDocumentItem, accountImageUrl:self.profileImageUrl,sesQty: self.sesQtyTemp! )
            self.employerForList.append(employerToAdd)


        if iIndex == (self.employerIdArray2.count-1) {
        
            self.filteredEmployerForList = self.employerForList
        self.thinking2.stopAnimating()

            if self.employerForList.count > 8 {

        if #available(iOS 11.0, *) {
        self.navigationItem.searchController = self.searchController
        } else {
        self.employerList.tableHeaderView = self.searchController.searchBar
        }
        }//end of >4
          
            print (self.employerIdArray.count)
            
            if self.self.employerIdArray.count < 4 && self.self.employerIdArray.count > 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.instruction.isHidden = false
                    self.arrowMove(instruct: self.instruction)
                }//end of dispatch
            } else { self.instruction.isHidden = true
            }
            
        self.employerList.isUserInteractionEnabled = true
        self.employerListBottom.priority = 750; self.employerListHeiget.priority = 1000;self.employerListTop.constant = 30.0;self.employerListBottom.constant = 30
        self.employerList.reloadData()
        self.employerList.isHidden = false;
        self.postTimerView()
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

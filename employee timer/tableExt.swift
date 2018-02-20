//  tableExt.swift
//  Created by אורי עינת on 5.12.2016.
//  Copyright © 2016 אורי עינת. All rights reserved.

import Foundation
import UIKit
import Firebase

extension(ViewController){
    
        func tableView(_ employerList: UITableView, didSelectRowAt indexPath: IndexPath) {

        if #available(iOS 11.0, *) { //handle when ios 11 is out
        searchController.dismiss(animated: false, completion: nil)
        ///searchController.searchBar.text = "" //to move it after selection
        self.navigationItem.searchController = nil
        } else {
        self.searchController.isActive = false
        }
            
        employerList.isHidden = true
        self.thinking2.startAnimating()
        employerList.isUserInteractionEnabled = false
        chooseEmployer.isUserInteractionEnabled = false

        records.isEnabled = true
        account.isEnabled = true
        bills.isEnabled = true
        importSpesific.isEnabled = true

        self.homeTitle.titleView = nil
        self.homeTitle.title = (filteredEmployerForList[indexPath.row].accountName)
        btnMenu.setImage (home, for: .normal)
        btnMenu.removeTarget(self, action:#selector(sideMenuMovement), for: .touchUpInside)
        btnMenu.addTarget(self, action: #selector(noAccount), for: .touchUpInside)
        toolBar.isHidden = false
        addAccount.isEnabled = false

        print (filteredEmployerForList)
            
        employerToS = filteredEmployerForList[indexPath.row].accountName
        employerIDToS = filteredEmployerForList[indexPath.row].employerRef
            
        print (employerToS,indexPath.row)

        bringEmployerData()


        if filteredEmployerForList[indexPath.row].activeAccount != false {self.thinking2.stopAnimating(); preStartView();records.isEnabled = true}
        else { chooseEmployer.isUserInteractionEnabled = true; self.thinking2.stopAnimating();alert670();records.isEnabled = false}

        chooseEmployer.isHidden = false
        }//end of did select


        func tableView(_ employerList: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEmployerForList.count
        }

        func tableView(_ employerList: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableRowHeight = 55
        return CGFloat(tableRowHeight!)
        }

        func tableView(_ employerList: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell2 = employerList.dequeueReusableCell(withIdentifier: "employerList", for: indexPath) as! employerCellTableViewCell

        if filteredEmployerForList[indexPath.row].accountName != "Add new dog" {
        cell2.backgroundColor = UIColor.clear; cell2.employerFirst.isHidden = false;
        
        cell2.employerFirst?.text = filteredEmployerForList[indexPath.row].accountName
        if filteredEmployerForList[indexPath.row].activeAccount == false {
        cell2.employerFirst.alpha = 0.5;cell2.lastDocument.alpha = 0.5;cell2.lastDocument?.text = "Not Active!"; cell2.employerFirst?.text =  "\(filteredEmployerForList[indexPath.row].accountName)"}
        else{ cell2.employerFirst.alpha = 1;cell2.lastDocument.alpha = 1;cell2.employerFirst?.text =  "\(filteredEmployerForList[indexPath.row].accountName)";cell2.lastDocument?.text = "\(filteredEmployerForList [indexPath.row].lastDocAccount)" }
        }//end of if

        cell2.dogImage.clipsToBounds = true
        cell2.dogImage.layer.cornerRadius = CGFloat(25)
        cell2.dogImage.contentMode = .scaleAspectFill
        //bring image
        if let cachedImage = MyImageCache.sharedCache.object(forKey: self.filteredEmployerForList[indexPath.row].employerRef as AnyObject) as? UIImage //bring from cache //was employerref
        { DispatchQueue.main.async {
        cell2.dogImage.image = cachedImage
        }
        }//end of bring image from cache
        else
        //bring from Firebase
        {
        let url = URL(string: self.filteredEmployerForList[indexPath.row].accountImageUrl)!
        URLSession.shared.dataTask(with: url, completionHandler: { (Data, response, error) in
        if error != nil {
        print (error as Any)
        cell2.dogImage.image = self.perSessionImage
        return
        }//end of if error

        else {
        DispatchQueue.main.async {
        cell2.dogImage?.image =  UIImage(data: Data!)
        }}//end of else
        }) .resume()
        } //end of bring from firebase

        return cell2
        }//end of cell for row

        func bringEmployerData() {
        if self.employerToS != "Add new dog" {
        homeTitle.title = employerToS

        dbRefEmployer.child(self.employerIDToS).child("myEmployees").queryOrderedByKey().queryEqual(toValue: employeeIDToS).observeSingleEvent(of:.childAdded, with: { (snapshot) in
        self.startButton.setTitle("+Session Now", for: .normal);
        self.startImage.image = self.roundImageBig
        self.RateUpdate = Double(snapshot.childSnapshot(forPath: "fEmployerRate").value! as! Double)
        }
        , withCancel: { (Error) in
        self.alert30()
        print("error from FB")}
        )
        }
        }//end of dbrefemployers

        }//end of ext!!!!!!!!!!//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

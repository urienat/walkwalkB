//
//  tableExt.swift
//  employee timer
//
//  Created by אורי עינת on 5.12.2016.
//  Copyright © 2016 אורי עינת. All rights reserved.
//

import Foundation
import UIKit
import Firebase

extension(ViewController){
    
            func tableView(_ employerList: UITableView, didSelectRowAt indexPath: IndexPath) {

            if #available(iOS 11.0, *) {
            self.navigationItem.searchController = nil
            } else {
            self.searchController.isActive = false
            }

            employerList.isHidden = true
            self.thinking2.startAnimating()

            employerList.isUserInteractionEnabled = false
            chooseEmployer.isUserInteractionEnabled = false
            print ("selected!!!!!!")
            records.isEnabled = true
            account.isEnabled = true
            bills.isEnabled = true
            importSpesific.isEnabled = true

            if pickerData.count == 0 {
            print ("indexpath4\([pickerData])")
            }

            chooseEmployer.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            chooseEmployer.titleLabel?.textAlignment = NSTextAlignment.center
            homeTitle.title = (pickerData[indexPath.row])

            btnMenu.setImage (home, for: .normal)
            let font = UIFont.systemFont(ofSize: 17.0)
            let textFontAttributes = [ NSFontAttributeName: font,NSForegroundColorAttributeName: systemBlue] as [String : Any]
            let homeBackTitle = NSAttributedString(string: " Home", attributes: textFontAttributes)
            btnMenu.setAttributedTitle(homeBackTitle, for: .normal)
            btnMenu.attributedTitle(for: .normal)
            btnMenu.removeTarget(self, action:#selector(sideMenuMovement), for: .touchUpInside)
            btnMenu.addTarget(self, action: #selector(noAccount), for: .touchUpInside)

            toolBar.isHidden = false
            addAccount.isEnabled = false
            account.title = "\(pickerData[indexPath.row])'s file"
            records.title =  "\(pickerData[indexPath.row])'s Sessions"

            employerToS = pickerData[indexPath.row]


            employerIDToS = employerIdArray2[indexPath.row] as! String
            bringEmployerData()
            if activeData[indexPath.row] != false {self.thinking2.stopAnimating(); preStartView();records.isEnabled = true}
            else { chooseEmployer.isUserInteractionEnabled = true; self.thinking2.stopAnimating();alert670();records.isEnabled = false}

            //set variable for Segue
            employerToS = pickerData[indexPath.row]
            chooseEmployer.isHidden = false

            }//end of did select

    
            func tableView(_ employerList: UITableView, numberOfRowsInSection section: Int) -> Int {
            return pickerData.count
            }
    
            func tableView(_ employerList: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            tableRowHeight = 55
            return CGFloat(tableRowHeight!)
            }
    
            func tableView(_ employerList: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell2 = employerList.dequeueReusableCell(withIdentifier: "employerList", for: indexPath) as! employerCellTableViewCell
            print(activeData[indexPath.row])
            print (lastDocument[indexPath.row])
                
            if pickerData[indexPath.row] != "Add new dog" {            cell2.backgroundColor = UIColor.clear
                ;cell2.employerFirst.isHidden = false; cell2.employerFirst?.text = pickerData[indexPath.row]
           
                
                if activeData[indexPath.row] == false {
             print ("alpha")
                cell2.employerFirst.alpha = 0.5;cell2.lastDocument.alpha = 0.5}
                
                else{ cell2.employerFirst.alpha = 1;cell2.lastDocument.alpha = 1 }
                
                }//end of if
            
                

                if activeData[indexPath.row] == false {cell2.lastDocument?.text = "Not Active!"; cell2.employerFirst?.text =  "\(pickerData[indexPath.row])"} else{cell2.employerFirst?.text =  "\(pickerData[indexPath.row])";cell2.lastDocument?.text = "\(lastDocument[indexPath.row])"}
            
           
                cell2.dogImage.clipsToBounds = true
            cell2.dogImage.layer.cornerRadius = CGFloat(25)
            cell2.dogImage.contentMode = .scaleAspectFill
            if let cachedImage = MyImageCache.sharedCache.object(forKey: self.employerIdArray2[indexPath.row] as AnyObject) as? UIImage //bring from cache
            { DispatchQueue.main.async {
            cell2.dogImage.image = cachedImage
                }
            }//end of bring image from cache
            else
            //bring from Firebase
            {
            print (imageArray)
            let url = URL(string: self.imageArray[indexPath.row])!
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
        print ("employerfrom main:\(employerToS)")
        if self.employerToS != "Add new dog" {
        dbRefEmployer.child(self.employerIDToS).child("myEmployees").queryOrderedByKey().queryEqual(toValue: employeeIDToS).observeSingleEvent(of:.childAdded, with: { (snapshot) in
        self.startButton.setTitle("+Session Now", for: .normal);self.startImage.image = self.roundImageBig
        self.RateUpdate = Double(snapshot.childSnapshot(forPath: "fEmployerRate").value! as! Double)
        if self.RateUpdate != 0.0 { } else {}
        }
            , withCancel: { (Error) in
                self.alert30()
                print("error from FB")}
            )
        }}//end of dbrefemployers

}//end of ext!!!!!!!!!!//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

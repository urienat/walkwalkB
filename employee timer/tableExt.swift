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
            employerList.isHidden = true
            self.thinking2.startAnimating()

            employerList.isUserInteractionEnabled = false
            chooseEmployer.isUserInteractionEnabled = false
            print ("selected!!!!!!")
            records.isEnabled = true
            account.isEnabled = true
            bills.isEnabled = true

            if pickerData.count == 0 {
            print ("indexpath4\([pickerData])")
            }

            chooseEmployer.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            chooseEmployer.titleLabel?.textAlignment = NSTextAlignment.center
            homeTitle.title = (nameData[indexPath.row] + " " + pickerData[indexPath.row])
            
            btnMenu.setImage (backArrow, for: .normal)
            btnMenu.removeTarget(self, action:#selector(sideMenuMovement), for: .touchUpInside)
            btnMenu.addTarget(self, action: #selector(noAccount), for: .touchUpInside)
            toolBar.isHidden = false
            addAccount.isEnabled = false

                
            //chooseEmployer.setTitle( nameData[indexPath.row] + " " + pickerData[indexPath.row] + " ▽", for: UIControlState.normal)
            account.title = "\(pickerData[indexPath.row])'s file"
            records.title =  "\(pickerData[indexPath.row])'s Sessions"

            employerToS = pickerData[indexPath.row]

            employerIDToS = employerIdArray2[indexPath.row] as! String
            bringEmployerData()
            if activeData[indexPath.row] != "0" {self.thinking2.stopAnimating(); preStartView()}
            else { chooseEmployer.isUserInteractionEnabled = true; self.thinking2.stopAnimating()}

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
            if pickerData[indexPath.row] != "Add new dog" {            cell2.backgroundColor = UIColor.clear
             ;cell2.employerFirst.isHidden = false; cell2.employerFirst?.text = nameData[indexPath.row]} else
            //change add dof to account
            //{cell2.employerName.textColor = blueColor;cell2.employerName?.text = "New Account ✚" ;cell2.employerFirst.isHidden = true;            cell2.backgroundColor = UIColor.clear
            //}
            if activeData[indexPath.row] == "0" { cell2.employerFirst.alpha = 0.4} else{ cell2.employerFirst.alpha = 1}
            cell2.employerFirst?.text =  "\(nameData[indexPath.row]) \(pickerData[indexPath.row])"

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
        self.startButton.setTitle("Session", for: .normal);self.startImage.image = self.roundImageBig
        self.RateUpdate = Double(snapshot.childSnapshot(forPath: "fEmployerRate").value! as! Double)
        if self.RateUpdate != 0.0 { } else {}
        })
        }}//end of dbrefemployers

}//end of ext!!!!!!!!!!//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

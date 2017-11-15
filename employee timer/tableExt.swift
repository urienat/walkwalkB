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
    
        if pickerData.count == 0 {
        print ("indexpath4\([pickerData])")
        }
        
        chooseEmployer.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        chooseEmployer.titleLabel?.textAlignment = NSTextAlignment.center
        chooseEmployer.setTitle( dogData[indexPath.row] + " " + pickerData[indexPath.row] + " ▽", for: UIControlState.normal)
        petFile.title = "\(pickerData[indexPath.row])'s file"
        records.title =  "\(pickerData[indexPath.row])'s Sessions"

        
        employerToS = pickerData[indexPath.row]
        
       
        if pickerData[indexPath.row] == "Add new dog" {
        ViewController.checkSubOnce = 1
        addDog = 1
        
        DispatchQueue.main.async {
       self.checkSubs()
        }
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
        print (ViewController.checkSubOnce!)
 
        if ViewController.checkSubOnce == 2 {
        print (self.employerToS)
            
            self.records.isEnabled = false;self.employerToS = "Add new dog" ; self.performSegue(withIdentifier: "employerForDogFile", sender: self.employerToS) }
        }//end of dispatch
        }//end of if
            
        else{
        recordInProcess = pickerIP[indexPath.row]
        employerIDToS = employerIdArray2[indexPath.row] as! String
        bringEmployerData()
        bringCoordninates()
        
        // reset varibales on select
        poo  = "No"
        pee = "No"
        //employeeCounter = 0
                    
        //manage the view
        PooSwitch.onTintColor = brownColor
        peeSwitch.onTintColor = yellowColor
        
        
        if recordInProcess != "" {
            bringRecord()
            
            }
        else{
            
            if activeData[indexPath.row] != "0" {self.thinking2.stopAnimating(); preStartView()}
            else {petFile.isEnabled = true; chooseEmployer.isUserInteractionEnabled = true; self.thinking2.stopAnimating()}
           }//end of else
        
        //set variable for Segue
        //employerToS = String(describing:chooseEmployer.currentTitle!)
        employerToS = pickerData[indexPath.row]

        print (employerToS)
        
        print("vv")
        
        chooseEmployer.isHidden = false
        }//end of else of  == add new dog

        }   //end of did select
    
    
        func tableView(_ employerList: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pickerData.count
        }
    
        func tableView(_ employerList: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            tableRowHeight = 55
            return CGFloat(tableRowHeight!)
        }
    
        func tableView(_ employerList: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell2 = employerList.dequeueReusableCell(withIdentifier: "employerList", for: indexPath) as! employerCellTableViewCell
            print (employerIdArray2)
            print (dogData)
            print (pickerData)
          
            print (employerToS)
            print (pickerData[indexPath.row])

    
            if pickerData[indexPath.row] != "Add new dog" {cell2.employerName.textColor = blueColor;            cell2.backgroundColor = UIColor.clear
                

            cell2.employerName?.text = "\(pickerData[indexPath.row])" ;cell2.employerDog.isHidden = false} else
            //change add dof to account
            {cell2.employerName.textColor = blueColor;cell2.employerName?.text = "New Account ✚" ;cell2.employerDog.isHidden = true;            cell2.backgroundColor = UIColor.clear
}
            

        if pickerIP[indexPath.row] != "" { activeSign = " In session..." ;cell2.employerDog.textColor = redColor}
        else {activeSign = ""; cell2.employerDog.textColor = blueColor}
            
       if activeData[indexPath.row] == "0" { cell2.employerName.alpha = 0.4;cell2.employerDog.alpha = 0.4} else{ cell2.employerName.alpha = 1; cell2.employerDog.alpha = 1}
          
            cell2.employerDog?.text =  dogData[indexPath.row] + activeSign

            
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
                self.paymentUpdate = String(describing: snapshot.childSnapshot(forPath: "fPayment").value!) as String!
                print(self.paymentUpdate)
                
                if self.paymentUpdate == "Normal" {
                    
                    
                } else if self.paymentUpdate == "Round" {
                    
                }
                if   self.paymentUpdate == "Normal" {self.startButton.setTitle("Start", for: .normal);self.startImage.image = self.sandwtchImageBig} else {self.startButton.setTitle("Session", for: .normal);self.startImage.image = self.roundImageBig}

                
                self.RateUpdate = Double(snapshot.childSnapshot(forPath: "fEmployerRate").value! as! Double)
                if self.RateUpdate != 0.0 { } else {}
                
                
            })
        }}//end of dbrefemployers

}//end of ext!!!!!!!!!!//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

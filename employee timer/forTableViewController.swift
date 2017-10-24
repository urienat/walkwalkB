//
//  forTableViewController.swift
//  employee timer
//
//  Created by אורי עינת on 1.10.2016.
//  Copyright © 2016 אורי עינת. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class forTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    let cellId =  "cellId"
    var employerFromMain: String?
    
    let dbRef = FIRDatabase.database().reference().child("fRecords")
    
    
    var records = [recordsStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // let titleLbl = employerFromMain! + "'s Records"
      //  self.title = titleLbl
        
        //   func fetchRecord() {
        
        
       // dbRef.queryOrdered(byChild: "fEmployer").queryEqual(toValue: employerFromMain).observe(.
        dbRef.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let record = recordsStruct()
                record.setValuesForKeys(dictionary)
                self.records.append(record)
              //self.tableView
                
            }
            }, withCancel: nil)
    }
    //}
    
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return records.count
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        
return 1
   }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //   let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! newTableCell
        
        
        let record = records[indexPath.row]
        
        
        //changing the Total for presentation
        if let recordToInt = Double(record.fTotal!) {
            let (h,m) = secondsTo(seconds: Int(recordToInt))
            cell.l13.text = String(h) + "h : " + String (m) + "m"
        }
        else {
            cell.l13.text = "   N/A"
        }
        
        
        //changing the dates for prentation
        if let fInToDate = record.fIn {
            
            
            cell.l11.text = fInToDate
        }
        else { cell.l11.text = "N/A"
            
        }
        
        
        cell.l12.text = record.fOut
        
        cell.l14.text = record.fIndication
        
        
        
        
        
        // Configure the cell...
        
        return cell
    }
    
    
    
    
    
    
    
    // func for transforming int to h:m:"
    func secondsTo (seconds : Int) -> (Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60)
        
    }
    
    
}

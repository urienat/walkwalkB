//
//  TableViewController.swift
//  employee timer
//
//  Created by אורי עינת on 24.9.2016.
//  Copyright © 2016 אורי עינת. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class recordsFetch: UITableViewController {

let cellId =  "cellId"
    var employerFromMain: String?
 
    let dbRef = FIRDatabase.database().reference().child("fRecords")

  
var records = [recordsStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let titleLbl = employerFromMain! + "'s Records"
        self.title = titleLbl
        
     //   func fetchRecord() {

        
        
                    dbRef.queryOrdered(byChild: "fEmployer").queryEqual(toValue: employerFromMain).observe(.childAdded, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                    let record = recordsStruct()
                    record.setValuesForKeys(dictionary)
                    self.records.append(record)
                    self.tableView.reloadData()
                }
                    }, withCancel: nil)
        }
    //}


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return records.count
    }
    
    //override func numberOfSections(in tableView: UITableView) -> Int {
     //   return 2
   // }
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     //   let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! newTableCell
        
        
        let record = records[indexPath.row]
        

        //changing the Total for presentation
        if let recordToInt = Double(record.fTotal!) {
            let (h,m) = secondsTo(seconds: Int(recordToInt))
            cell.l3.text = String(h) + "h : " + String (m) + "m"
        }
        else {
            cell.l3.text = "   N/A"
        }

        
        //changing the dates for prentation
        if let fInToDate = record.fIn {
        
        
        cell.l1.text = fInToDate
        }
        else { cell.l1.text = "N/A"
        
        }
        
        
        cell.l2.text = record.fOut
        
        cell.l4.text = record.fIndication
        

        


        // Configure the cell...

        return cell
    }
    
  
  
    
   /* class recordCell: UITableViewCell {
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style:.default, reuseIdentifier: reuseIdentifier)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
*/
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // func for transforming int to h:m:"
    func secondsTo (seconds : Int) -> (Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60)
        
    }
 
    
}

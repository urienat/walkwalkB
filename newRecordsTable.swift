//
//  newRecordsTable.swift
//  employee timer
//
//  Created by אורי עינת on 15.9.2016.
//  Copyright © 2016 אורי עינת. All rights reserved. 
//
//

import UIKit
import FirebaseDatabase
import Firebase
class newRecordsTable: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var newDataTable: UITableView!
    @IBOutlet weak var newTimeLabel: UILabel!
    let recordsdates = ["2.6.16", "9.6.16", "16.6.16", "19.6.16"]
    let recordsTime = ["4h22m", "6h13m", "5h34m", "3h33m"]
    let ref = FIRDatabase.database().reference()

    //let employerVC = ""
   @IBOutlet weak var employerVcLbl: UILabel!
    
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.title = "Records"
        print ("ddd")


        // Do any additional setup after loading the view.
    }

   /* override func viewDidAppear(_ animated: Bool) {
        let recordRef = ref.child("record")
        let recievedRecord = ["fIn" : "22", "fOut" : "22" , "fTotal" : "22", "fEmployer": "22"]

    }
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordsdates.count
        
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let newCellForRecord = self.newDataTable.dequeueReusableCell(withIdentifier: "prototype2", for: indexPath) as! newTableCell
        
        
        
        //newCellForRecord.newDateLabel.text = recordsdates[indexPath.row]
        //newCellForRecord.newTimeLabel.text = recordsTime[indexPath.row]

        
        
        return newCellForRecord
        
        
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

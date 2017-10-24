//
//  recordsTable.swift
//  employee timer
//
//  Created by אורי עינת on 8.9.2016.
//  Copyright © 2016 אורי עינת. All rights reserved.
//

import UIKit

class recordsTable: UIViewController, UITableViewDelegate,UITableViewDataSource {
   
    
   
    @IBOutlet weak var recordsTable: UITableView!
    
    let recordsdates = ["2.6.16", "9.6.16", "16.6.16"]
    let recordsTime = ["4h22m", "6h13m", "5h34m"]


    //@IBOutlet weak var alertBackground: UIView!
    
    //@IBAction func XisPressed(_ sender: AnyObject) {
     // alertBackground.isHidden = false
        
    //}
    
    class veryNewCell: UITableViewCell {
        
        
        @IBOutlet weak var nnn: UILabel!
        
    }
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.recordsTable.dataSource = self
        //self.recordsTable.delegate = self
        
        
        
        
        // Do any additional setup after loading the view.
    }

   
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return recordsdates.count
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.recordsTable.dequeueReusableCell(withIdentifier: "prototype1", for: indexPath) as! veryNewCell
        
        
       // netTime = recordsdates[indexPath.row]

        //cell.textLabel?.text = recordsdates[indexPath.row] + "   " + recordsTime[indexPath.row]
        cell.nnn?.text = recordsdates[indexPath.row]
        
        
        return cell;
    }
    
    
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

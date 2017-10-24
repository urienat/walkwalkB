//
//  billCell.swift
//  employee timer
//
//  Created by אורי עינת on 19.2.2017.
//  Copyright © 2017 אורי עינת. All rights reserved.
//



import UIKit
import FirebaseDatabase

class billCell: UITableViewCell {
    let dbRef = FIRDatabase.database().reference().child("fRecords")
    
    
    //var checkBoxCell=newVCTable.checkBox
    
    let Vimage = UIImage(named: "due")
    let nonVimage = UIImage(named: "emptyV")
    let paidImage = UIImage(named: "paid")
    let billedImage = UIImage(named: "locked")
    let billIcon = UIImage(named: "bill")
    
    @IBOutlet weak var l1: UILabel!
    @IBOutlet weak var l2: UILabel!
    @IBOutlet weak var l3: UILabel!
    @IBOutlet weak var l4: UILabel!
    @IBOutlet weak var l5: UILabel!
    @IBOutlet weak var l6: UILabel!
    @IBOutlet weak var l7: UILabel!
    @IBOutlet weak var approval: UIButton!
    
    
    //approval button
    @IBAction func approval(_ sender: Any) {
        switch newVCTable.checkBox {
        //pre
        case 0:  approval.setImage(paidImage, for: .normal) //
        //Approved
        case 1: approval.setImage(Vimage, for: .normal) //
        //Paid
                //default
        default: break
            ////
        } //end of switch
        
    }//end of approval button
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
}///////////end!!!!////////////////////////////////////////////////////////////////////////////////////////////

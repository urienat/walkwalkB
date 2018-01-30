//
//  newTableCell.swift
//  employee timer
//
//  Created by אורי עינת on 15.9.2016.
//  Copyright © 2016 אורי עינת. All rights reserved.
//

import UIKit
import FirebaseDatabase

class newTableCell: UITableViewCell {
    let dbRef = FIRDatabase.database().reference().child("fRecords")
   
    
    //var checkBoxCell=newVCTable.checkBox
    
    let Vimage = UIImage(named: "nakedV")
    
    let nonVimage =  UIImage(named: "emptyV")//UIImage(named: "emptyV")
    let paidImage = UIImage(named: "paid")
    let billedImage = UIImage(named: "locked")
    let billIcon = UIImage(named: "bill")

    
    @IBOutlet weak var l1: UILabel!
    @IBOutlet weak var l7: UILabel!
    @IBOutlet weak var l8: UIImageView!
    @IBOutlet weak var l9: UILabel!
   
    @IBOutlet weak var approval: UIButton!
    @IBOutlet weak var cellBtnExt: UIButton!
    
    //approval button
        @IBAction func approval(_ sender: Any) {
        print("checkBoxcell\(newVCTable.checkBox)")
        switch newVCTable.checkBox {
        //pre
        case 0:  cellBtnExt.setImage(nonVimage, for: .normal) //
        //Approved
        case 1: cellBtnExt.setImage(Vimage, for: .normal) //
        //Paid
        case 2: cellBtnExt.setImage(billedImage, for: .normal) //
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

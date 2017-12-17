//
//  taxerCell.swift
//  perSession
//
//  Created by Uri Enat on 12/17/17.
//  Copyright © 2017 אורי עינת. All rights reserved.
//

import Foundation
import UIKit

class taxerCell: UITableViewCell{
    
    
    //var checkBoxCell=newVCTable.checkBox
    
    let nonVimage = UIImage(named: "emptyV")
    let paidImage = UIImage(named: "paid")
    let billedImage = UIImage(named: "locked")
    let billIcon = UIImage(named: "bill")
    let canceledImage = UIImage(named: "cancelled")
    
    
    @IBOutlet weak var l1: UILabel!
    @IBOutlet weak var l3: UILabel!
    @IBOutlet weak var l4: UILabel!
    @IBOutlet weak var l6: UILabel!
    
    @IBOutlet weak var approval: UIButton!
    
    
    @IBAction func approval(_ sender: Any) {
        if approval.image (for: .normal) != canceledImage {
            if approval.image(for: .normal) == nonVimage {biller.checkBoxBiller = 0 } else {biller.checkBoxBiller = 1}
            if biller.checkBoxBiller == 0 {biller.checkBoxBiller = 1} else {biller.checkBoxBiller = 0}
            
            
            //approval button
            
            switch biller.checkBoxBiller {
            //pre
            case 0:  approval.setImage(nonVimage, for: .normal) //
            //Paid
            case 1: approval.setImage(paidImage, for: .normal) //
            //default
            default: break
                ////
            }//end of switch
        }else{
            print ("it is cancelled")
            approval.setImage(canceledImage, for: .normal)
        }
        
    }//end of approval button
    
    
    
}


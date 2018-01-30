//
//  billerCell.swift
//  employee timer
//
//  Created by אורי עינת on 19.2.2017.
//  Copyright © 2017 אורי עינת. All rights reserved.
//

import Foundation
import UIKit

class billerCell: UITableViewCell{
    
    
    //var checkBoxCell=newVCTable.checkBox
    
    let nonVimage = UIImage(named: "emptyV")
    let paidImage = UIImage(named: "paid")
    let billedImage = UIImage(named: "locked")
    let billIcon = UIImage(named: "bill")
    let canceledImage = UIImage(named: "cancelled")
    let billDocument = UIImage(named: "billDocument")
    let partially = UIImage(named: "partially")

    
    @IBOutlet weak var l1: UILabel!
    @IBOutlet weak var l3: UILabel!
    @IBOutlet weak var l4: UILabel!
    @IBOutlet weak var l6: UILabel!
    @IBOutlet weak var cellBtnExt: UIButton!
    @IBOutlet weak var approvalImage: UIImageView!
    
    
    @IBAction func cellBtnExt(_ sender: Any) {
    
        if approvalImage.image != canceledImage {
        if approvalImage.image == billDocument || approvalImage.image == partially {biller.checkBoxBiller = 0 } else {biller.checkBoxBiller = 1}
        if biller.checkBoxBiller == 0 {biller.checkBoxBiller = 1} else {biller.checkBoxBiller = 0}
        
        //approval button

        switch biller.checkBoxBiller {
        //pre
        //case 0:  approval.setImage(nonVimage, for: .normal) //
        //Paid
        case 1: approvalImage.image = paidImage
        //default
        default: break
            ////
        }//end of switch
        }else{
            print ("it is cancelled")
           approvalImage.image = canceledImage
            }

        }//end of approval button
    
    
    
        }

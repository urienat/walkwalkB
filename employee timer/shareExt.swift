//
//  shareExt.swift
//  perSession
//
//  Created by uri enat on 30/01/2018.
//  Copyright © 2018 אורי עינת. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import MessageUI

extension(UIViewController){
    
    func pdfDataWithTableView2(tableView: UITableView,pageHeight: Int, totalBG:UIView, Closing:NSString,distance:Double ) -> NSMutableData{
        let textFontAttributes = [
            NSForegroundColorAttributeName: UIColor.red
        ]
        var pages = 0
        let priorBounds = tableView.bounds
        let fittedSize = tableView.sizeThatFits(CGSize(width:priorBounds.size.width, height:tableView.contentSize.height))
        tableView.bounds = CGRect(x:0, y:0, width:fittedSize.width, height:fittedSize.height+72)//added 72
        let pdfPageBounds = CGRect(x:0, y:0, width:Int(tableView.frame.width), height:(pageHeight))//instead of self.view.frame.height) //to make it fits nicelty in page
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageBounds,nil)
        var pageOriginY: CGFloat = 0
        while pageOriginY < fittedSize.height {
            UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil)
            UIGraphicsGetCurrentContext()!.saveGState()
            UIGraphicsGetCurrentContext()!.translateBy(x: 0, y: -pageOriginY)
            tableView.layer.render(in: UIGraphicsGetCurrentContext()!)
            
            UIGraphicsGetCurrentContext()!.restoreGState()
            pageOriginY += pdfPageBounds.size.height
            pages += 1
        }
        
        
        // the closing report
        if (Int(fittedSize.height)-(((pages-1) * pageHeight)) + Int(distance*2.0)) < pageHeight {
        UIGraphicsGetCurrentContext()!.translateBy(x: 0, y: CGFloat(Int(fittedSize.height)-(((pages-1) * pageHeight)))
        )
        totalBG.layer.render(in: UIGraphicsGetCurrentContext()!)
        totalBG.layer.draw(in: UIGraphicsGetCurrentContext()!)
        print (distance)
            print (Closing)
            
        Closing.draw(at: CGPoint.init(x: 0.0, y: distance), withAttributes: textFontAttributes)

       
            

            
        } else {
        UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil)
        totalBG.layer.render(in: UIGraphicsGetCurrentContext()!)
        totalBG.layer.draw(in: UIGraphicsGetCurrentContext()!)
        Closing.draw(at: CGPoint.init(x: 0.0, y: distance), withAttributes: textFontAttributes)
        }
        
        UIGraphicsEndPDFContext()
        tableView.bounds = priorBounds
        var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        docURL = docURL.appendingPathComponent("myDocument.pdf")
        pdfData.write(to: docURL as URL, atomically: true)
        return pdfData
    }
    
   
    
    ////////////alerts/////////////////////////////////////
    
    func alert101(printItem:NSMutableData,mailFunction:MFMailComposeViewController){
        let alertController5 = UIAlertController(title: ("Share") , message: "", preferredStyle: .alert)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            //do nothing
        }
        
        let mailAction = UIAlertAction(title: "Mail", style: .default) { (UIAlertAction) in
        let mailComposeViewController1 = mailFunction
         if MFMailComposeViewController.canSendMail() {
         self.present(mailComposeViewController1, animated: true, completion: nil)
         } //end of if
         else{ //self.showSendmailErrorAlert()
         
         }
         // navigationController!.popViewController(animated: true)
         }
        
        let printAction = UIAlertAction(title: "Print", style: .default) { (UIAlertAction) in
            let printInfo = UIPrintInfo(dictionary:nil)
            printInfo.outputType = UIPrintInfoOutputType.general
            printInfo.jobName = "My Print Job"
            
            let printController = UIPrintInteractionController.shared
            printController.printInfo = printInfo
            printController.printingItem =  printItem
            
            
            
            printController.present(animated: true) { (controller, success, error) -> Void in
                if success {
                    // Printed successfully
                    
                    self.navigationController!.popViewController(animated: true)
                    
                    
                } else {
                    // Printing failed, report error ...
                }
            }//end of present
            
        }
        
        alertController5.addAction(mailAction)
        alertController5.addAction(printAction)
        alertController5.addAction(CancelAction)
        self.present(alertController5, animated: true, completion: nil)
    }
}//end of ext


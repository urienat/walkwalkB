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
   
/*
    func pdfDataWithTableView(tableView: UITableView) -> NSMutableData {
        let frameRect = CGRect(x: 72, y: 72, width: 468, height: 600);
        let imageRect = CGRect(x: 500, y: 660, width: 100, height: 100);
        
         let paperA4 = CGRect(x: 0, y: 0, width: 712, height: 992)
        let pageWithMargin = CGRect(x: -72, y: 72, width:568, height: (600));
        let paperRect = CGRect(x: 30, y: 30, width: 512, height:(781.8))
        var firstpage = true
        let Head = "Head"
        let font = UIFont(name: "Helvetica Bold", size: 14.0)
        let textRect = CGRect(x: 5, y: 5, width: 125, height: 18)
        var paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.alignment = NSTextAlignment.left
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        var grayColor = UIColor(red :235/255.0, green: 235/255.0, blue: 235/255.0, alpha: 1)
        let textColor = UIColor.red
        
        let textFontAttributes = [
            NSFontAttributeName: font!,
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        
        let text:NSString = "Hello world"
        
        
        /////////
        let priorBounds = tableView.bounds
        let fittedSize = tableView.sizeThatFits(CGSize(width:pageWithMargin.size.width,height:pageWithMargin.size.height)) //width:priorBounds.size.width, height:tableView.contentSize.height))
        tableView.bounds = CGRect(x:0, y:0, width:fittedSize.width, height:fittedSize.height)
        let pdfPageBounds = CGRect(x:0, y:0, width:frameRect.width, height:frameRect.height)
        let pdfDataTable = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfDataTable, pageWithMargin,nil)
        var pageOriginY: CGFloat = 0
        while pageOriginY < fittedSize.height {
            
            UIGraphicsBeginPDFPageWithInfo(pageWithMargin, nil)
            ///
            let currentContext = UIGraphicsGetCurrentContext()
            currentContext?.textMatrix = CGAffineTransform.identity;
            currentContext?.setFillColor(grayColor.cgColor)
            currentContext?.fill(paperA4)
            if firstpage == true {
                text.draw(in: textRect, withAttributes: textFontAttributes)
                ;firstpage = false
            }
            ///
            UIGraphicsGetCurrentContext()!.saveGState()
            UIGraphicsGetCurrentContext()!.translateBy(x: 0, y: -pageOriginY)
            
            
            tableView.layer.render(in: UIGraphicsGetCurrentContext()!)
            UIGraphicsGetCurrentContext()!.restoreGState()
            pageOriginY += pageWithMargin.size.height
        }
        UIGraphicsEndPDFContext()
        tableView.bounds = priorBounds
        var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        docURL = docURL.appendingPathComponent("myDocument.pdf")
        pdfDataTable.write(to: docURL as URL, atomically: true)
        
        return pdfDataTable
    }

   func pdfDataWithTableView(tableView: UITableView) -> NSMutableData {
        let pdfDataTable = NSMutableData()
        let paperA4 = CGRect(x: 0, y: 0, width: 712, height: 992)
        let pageWithMargin = CGRect(x: -72, y: 72, width:568, height: (600));
        let priorBounds = tableView.bounds
        let fittedSize = tableView.sizeThatFits(CGSize(width:priorBounds.size.width, height:tableView.contentSize.height))//width:priorBounds.size.width-280
    
   //     self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.contentSize.width, self.contentSize.height)
    
        print (tableView.contentSize.height)//still working on the height
            
        tableView.bounds = CGRect(x:0, y:0, width:fittedSize.width, height:fittedSize.height)
        
       // let pdfData = NSMutableData()
    
          let pdfPageBounds = CGRect(x:0, y:0, width:tableView.frame.width, height:tableView.contentSize.height)//view.frame.height)
        UIGraphicsBeginPDFContextToData(pdfDataTable, pdfPageBounds,nil)
        var pageOriginY: CGFloat = 0
        while pageOriginY < fittedSize.height {
            UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil)
            UIGraphicsGetCurrentContext()!.saveGState()
            UIGraphicsGetCurrentContext()!.translateBy(x: 0, y: -pageOriginY)
            tableView.layer.render(in: UIGraphicsGetCurrentContext()!)
            UIGraphicsGetCurrentContext()!.restoreGState()
            pageOriginY += pdfPageBounds.size.height
            }
    
        UIGraphicsEndPDFContext()
        tableView.bounds = priorBounds
        var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        docURL = docURL.appendingPathComponent("myDocument.pdf")
        pdfDataTable.write(to: docURL as URL, atomically: true)
    return pdfDataTable
    }
  */
     func pdfDataWithTableView(tableView: UITableView) -> NSMutableData {
       
        // Don't include scroll indicators in file
        tableView.showsVerticalScrollIndicator = false
        
        // Creates a mutable data object for updating with binary data, like a byte array
        let pdfData = NSMutableData()
        
        // Change the frame size to include all data
        let originalFrame = tableView.frame
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.contentSize.width, height:tableView.contentSize.height)
        CGRect(x: -72, y: 72, width:568, height: (600))
        // Points the pdf converter to the mutable data object and to the UIView to be converted
        UIGraphicsBeginPDFContextToData(pdfData, tableView.bounds, nil)
        UIGraphicsBeginPDFPage()
        let pdfContext = UIGraphicsGetCurrentContext();
        
        // Draws rect to the view and thus this is captured by UIGraphicsBeginPDFContextToData
        tableView.layer.render(in: pdfContext!)
        
        // Remove PDF rendering context
        UIGraphicsEndPDFContext()
        
        // Retrieves the document directories from the iOS device
       /// let documentDirectories: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
       /// let documentDirectory = documentDirectories.objectAtIndex(0)
       /// let documentDirectoryFilename = documentDirectory.stringByAppendingPathComponent(fileName);
        
        // Instructs the mutable data object to write its context to a file on disk
       /// pdfData.writeToFile(documentDirectoryFilename, atomically: true)
        
        // Back to normal size
        tableView.frame = originalFrame
        
        // Put back the scroll indicator
        tableView.showsVerticalScrollIndicator = true
        
       return pdfData
    }
    
    ////////////alerts/////////////////////////////////////
    
    func alert101(printItem:NSMutableData){
        let alertController5 = UIAlertController(title: ("Share") , message: "", preferredStyle: .alert)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            //do nothing
        }
        /*
         let mailAction = UIAlertAction(title: "Mail", style: .default) { (UIAlertAction) in
         let mailComposeViewController1 = configuredMailComposeViewController2()
         if MFMailComposeViewController.canSendMail() {
         self.present(mailComposeViewController1, animated: true, completion: nil)
         } //end of if
         else{ //self.showSendmailErrorAlert()
         
         }
         // navigationController!.popViewController(animated: true)
         }
         */
        let printAction = UIAlertAction(title: "Print", style: .default) { (UIAlertAction) in
            let printInfo = UIPrintInfo(dictionary:nil)
            printInfo.outputType = UIPrintInfoOutputType.general
            printInfo.jobName = "My Print Job"
            
            let printController = UIPrintInteractionController.shared
            printController.printInfo = printInfo
            printController.printingItem =  printItem
            
            
            //var viewpf:UIViewPrintFormatter = self.documentsFileName.viewPrintFormatter()
            // var viewpf:UIViewPrintFormatter = self.billerConnect.viewPrintFormatter()
            //printController.printFormatter = viewpf
            printController.present(animated: true) { (controller, success, error) -> Void in
                if success {
                    // Printed successfully
                    
                    self.navigationController!.popViewController(animated: true)
                    
                    
                } else {
                    // Printing failed, report error ...
                }
            }//end of present
            
        }
        
        //alertController5.addAction(mailAction)
        alertController5.addAction(printAction)
        alertController5.addAction(CancelAction)
        self.present(alertController5, animated: true, completion: nil)
    }
}//end of ext


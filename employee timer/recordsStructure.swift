//
//  recordsStructure2.swift
//  employee timer
//
//  Created by uri enat on 06/11/2017.
//  Copyright © 2017 אורי עינת. All rights reserved.
//

import Foundation

class recordsStruct: NSObject{
    
    var fEmployer: String?
    var fEmployeeRef: String?
    var fEmployerRef: String?
    var fIn: String?
    var fIndication3: String?
    var fStatus:String?
    var fBill:  String?
    var fSpecialAmount : String?
    var fSpecialItem : String?
    var fSessionCreated : String?

    
    
}

class employersStruct: NSObject{
    var fEmployer: String?
    var fEmployerRate: String?
    var fImageRef: String?
    var fActive: Bool?
    var fLast: String?
    var fName: String?
    var fCell: String?
    var fParent: String?
    var fAddress: String?
    var fmail: String?
     var fSesQty : String?

}

class billStruct: NSObject{
    var fBill: String?
    var fBillDate: String?
    var fBillStatus: String?
    var fBillEmployer: String?
    var fBillEventRate: String?
    var fBillEvents: String?
    var fBillSum: String?
    var fBillCurrency: String?
    var fBillEmployerName: String?
    var fBillMailSaver: String?
    var fBillRecieptMailSaver: String?
    var fBillTax: String?
    var fBillTotalTotal: String?
    var fBillStatusDate: String?
    var fPaymentMethood: String?
    var fPaymentReference: String?
    var fDocumentName: String?
    var fRecieptDate: String?
    var fBalance: String?
    var fRecieptCounter : String?

    
    
}

class employerListStruct : NSObject{
    static var cheeckbox: Int?
}

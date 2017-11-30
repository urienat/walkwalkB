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
    var fOut: String?
    var fIndication3: String?
    var fStatus:String?
    var fTotal: String?
    //var fId: String?
    var fPoo: String?
    var fPee: String?
    var fBill:  String?
    
    
}

class employersStruct: NSObject{
    var fEmployer: String?
    var fPayment: String?
    var fMethood: String?
    var fEmployerRate: String?
    var fImageRef: String?
    var fActive: Bool?
    var fConnect: String?
    var cName: String?

}

class billStruct: NSObject{
    var fBill: String?
    var fBillDate: String?
    var fBillStatus: String?
    var fBillEmployer: String?
    var fBillPayment: String?
    var fBillEventRate: String?
    var fBillHourRate: String?
    var fBillEvents: String?
    var fBillTotalTime: String?
    var fBillSum: String?
    var fBillCurrency: String?
    var fBillEmployerName: String?
    var fBillMailSaver: String?
    //var fBillCanceled: String?
    var fBillTax: String?
    var fBillTotalTotal: String?
    var fBillStatusDate: String?
    
    
    
    
}

class employerListStruct : NSObject{
    static var cheeckbox: Int?
}

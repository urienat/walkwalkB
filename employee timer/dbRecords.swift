//
//  dbRecords.swift
//  
//
//  Created by אורי עינת on 21.9.2016.
//
//

import Foundation
import FirebaseDatabase

struct dbRecord {
    let timeIn:String!
    let timeOut:String!
    let recordRef:FIRDatabaseReference?
    
    init  (timeIn:String,timeOut:String) {
        self.timeIn = timeIn
        self.timeOut = timeOut
        self.recordRef = nil
        
    }
    
    init (snapshot: FIRDataSnapshot) {
        timeIn = snapshot.key
        recordRef = snapshot.ref
        timeOut = snapshot.value(forKey: "timeOut") as! String
        
    
            
            
        
       // } else {timeOut = ""}
        
        
    }
    func toAnyObject() -> AnyObject{
        return []
    }
    
}

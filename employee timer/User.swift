//
//  User.swift
//  employee timer
//
//  Created by אורי עינת on 21.9.2016.
//  Copyright © 2016 אורי עינת. All rights reserved.
//

import Foundation
import FirebaseAuth




struct User  {
    let uid:String
    //let cell: String
    
    init(userData:FIRUser) {
        uid = userData.uid
    
        
    }
    
    init (uid:String){
        self.uid = uid
        
    }
    
    
}

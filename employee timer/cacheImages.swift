//
//  cacheImages.swift
//  employee timer
//
//  Created by אורי עינת on 14.12.2016.
//  Copyright © 2016 אורי עינת. All rights reserved.
//

import Foundation
import UIKit

class MyImageCache {
    
    static let sharedCache: NSCache = { () -> NSCache<AnyObject, AnyObject> in 
        let cache = NSCache<AnyObject, AnyObject>()
        cache.name = "MYImageCache"
        cache.countLimit = 20 //max images in memory
        cache.totalCostLimit = 20*1024*1024 //max10MB
        return cache
        
        
        
    }()
}//end of class

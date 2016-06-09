//
//  Pin.swift
//  Virtual Travel
//
//  Created by Unathi Chonco on 2016/05/30.
//  Copyright © 2016 Unathi Chonco. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Pin: NSManagedObject {
    
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Page = "current_page"
        static let Photos = "photos"
    }

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        latitude = dictionary[Keys.Latitude] as! Double
        longitude = dictionary[Keys.Longitude] as! Double
        current_page = dictionary[Keys.Page] as! Int
    }

}

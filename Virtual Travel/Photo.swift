//
//  Photo.swift
//  Virtual Travel
//
//  Created by Unathi Chonco on 2016/05/30.
//  Copyright © 2016 Unathi Chonco. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {

    struct Keys {
        static let URL = "url"
        static let Pin = "pin"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        url = dictionary[Keys.URL] as? String
    }

}

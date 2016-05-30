//
//  Photo+CoreDataProperties.swift
//  Virtual Travel
//
//  Created by Unathi Chonco on 2016/05/30.
//  Copyright © 2016 Unathi Chonco. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var url: String
    @NSManaged var image: NSData?
    @NSManaged var id: NSNumber?
    @NSManaged var server_id: NSNumber?
    @NSManaged var farm_id: NSNumber?
    @NSManaged var secret: String?
    @NSManaged var pin: Pin?

}

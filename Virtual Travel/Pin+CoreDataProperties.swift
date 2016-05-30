//
//  Pin+CoreDataProperties.swift
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

extension Pin {

    @NSManaged var latitude: NSNumber?
    @NSManaged var current_page: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var photos: NSOrderedSet?

}

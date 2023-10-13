//
//  Contact+CoreDataProperties.swift
//  TheNewDialer
//
//  Created by vluz on 2019-11-15.
//  Copyright © 2019 Chaoqun Ding. All rights reserved.
//
//

import Foundation
import CoreData


extension Contact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var contactName: String?
    @NSManaged public var number: String?
    @NSManaged public var timeStamp: String

}

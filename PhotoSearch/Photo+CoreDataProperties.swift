//
//  Photo+CoreDataProperties.swift
//  PhotoSearch
//
//  Created by Mingyan Wei on 19/9/17.
//  Copyright © 2017 Mingyan Wei. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var text: String?
    @NSManaged public var thumbnail: NSData?
    @NSManaged public var thumb: NSManagedObject?

}

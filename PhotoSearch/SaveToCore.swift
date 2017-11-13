//
//  SaveToCore.swift
//  PhotoSearch
//
//  Created by Mingyan Wei on 4/9/17.
//  Copyright © 2017 Mingyan Wei. All rights reserved.
//

import Foundation

import UIKit
import CoreData

extension ViewController {
    // Check if photo with the exact same text has already been saved
    func checkForDuplicate(text : String) -> Bool {
        var matches : [Photo] = []
        let request : NSFetchRequest<Photo> = Photo.fetchRequest()
        request.predicate = NSPredicate(format: "text = %@", text)
        
        do {
            matches = try managedContext?.fetch(request) as! [Photo]
            if (matches.count) > 0 {
                return true
            }
        } catch {
            fatalError("Failed to fetch photo: \(error)")
        }
        return false
    }
    
    func prepareImageForSaving(image : UIImage, text : String) {
        // create NSData from UIImage
        guard let imageData = UIImageJPEGRepresentation(image, 1) else {
            // handle failed conversion
            print("jpg error")
            return
        }
        
        if self.checkForDuplicate(text: text) {
            return
        }
        
        // scale image down to thumbnail
        let thumbnail = image.resizePhoto(toSize: self.view.frame.size)
        
        guard let thumbnailData  = UIImageJPEGRepresentation(thumbnail, 0.7) else {
            // handle failed conversion
            print("jpg error")
            return
        }
        
        self.saveData(imageData, thumbnailData: thumbnailData, text: text)
    }
    
    func saveData(_ imageData:Data, thumbnailData:Data, text: String) {
        
        self.managedContext?.perform {
            guard let photo = NSEntityDescription.insertNewObject(forEntityName: "Photo",  into: self.managedContext!) as? Photo else {
                // handle failed new object in MOC (ManagedObjectContext)
                print("MOC error")
                return
            }
            
            photo.image = imageData as NSData
            photo.thumbnail = thumbnailData as NSData
            photo.text = text
            
            do {
                try self.managedContext!.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
        
    }
}

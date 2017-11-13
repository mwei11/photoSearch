//
//  UIImageExtension.swift
//  PhotoSearch
//
//  Created by Mingyan Wei on 4/9/17.
//  Copyright © 2017 Mingyan Wei. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {

    // resize the photo to target size
    func resizePhoto(toSize newSize:CGSize) -> UIImage {
        // make sure the new size has the correct aspect ratio
        let aspectFill = self.size.resizeFill(newSize)
        
        UIGraphicsBeginImageContextWithOptions(aspectFill, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: aspectFill.width, height: aspectFill.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}

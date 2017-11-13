//
//  ProcessImage.swift
//  PhotoSearch
//
//  Created by Mingyan Wei on 4/9/17.
//  Copyright © 2017 Mingyan Wei. All rights reserved.
//

import Foundation
import UIKit

extension CGSize {
    
    // calculate the scaled size with the same aspect ratio
    func resizeFill(_ toSize: CGSize) -> CGSize {
        let scale : CGFloat = (self.height / self.width) < (toSize.height / toSize.width) ? (self.height / toSize.height) : (self.width / toSize.width)
        return CGSize(width: (self.width / scale), height: (self.height / scale))
    }
}

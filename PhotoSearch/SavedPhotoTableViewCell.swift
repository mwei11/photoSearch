//
//  SavedPhotoTableViewCell.swift
//  PhotoSearch
//
//  Created by Mingyan Wei on 5/9/17.
//  Copyright © 2017 Mingyan Wei. All rights reserved.
//

import UIKit

class SavedPhotoTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

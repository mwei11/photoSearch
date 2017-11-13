//
//  FullSizeView.swift
//  PhotoSearch
//
//  Created by Mingyan Wei on 12/9/17.
//  Copyright © 2017 Mingyan Wei. All rights reserved.
//

import UIKit

class FullSizeView: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var text : String?
    var image : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.imageView.image = image
        self.textView.text = text
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.zoomScale = 1.0
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func shareImage(_ sender: Any) {
        let activityViewController = UIActivityViewController(
            activityItems: [image as! UIImage],
            applicationActivities: nil
        )
        present(activityViewController, animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

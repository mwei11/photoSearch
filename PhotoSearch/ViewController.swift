//
//  ViewController.swift
//  PhotoSearch
//
//  Created by Mingyan Wei on 3/8/17.
//  Copyright © 2017 Mingyan Wei. All rights reserved.
//

import UIKit
import TesseractOCR
import BSImagePicker
import CoreData
import Photos


class ViewController: UIViewController, G8TesseractDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // get context for core data
    var managedContext : NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var start : DispatchTime?   // time to start processing
    var end : DispatchTime?     // time to finish processing
    
    // let users to select pictures from photo library
    @IBAction func pick(_ sender: UIButton) {
        let imagePicker = BSImagePickerViewController()
        bs_presentImagePickerController(imagePicker, animated: true,
                                        select: { (asset: PHAsset) -> Void in
        },
                                        deselect: { (asset: PHAsset) -> Void in
        },
                                        cancel: { (assets: [PHAsset]) -> Void in
        },
                                        finish: { (assets: [PHAsset]) -> Void in
                                            DispatchQueue.main.async {
                                                self.spinner.startAnimating()
                                                self.view.addSubview(self.spinner)
                                                self.start = DispatchTime.now()
                                            }
                                            self.loopImages(assets : assets)
                                            
        }, completion: nil)
    }
    
    // capture a picture with camera (not available for simulator)
    @IBAction func takePhoto(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // process multiple photos concurrently with multithreads
    func loopImages(assets: [PHAsset])  {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        
        DispatchQueue.concurrentPerform(iterations: assets.count) { i in
            var img = UIImage()
            let imageSize = CGSize(width: assets[i].pixelWidth, height: assets[i].pixelHeight)
            manager.requestImage(for: assets[i], targetSize: imageSize, contentMode: .aspectFit, options: option, resultHandler: {(result, info) -> Void in
                img = result!
            })
            self.scanImage(image: img)
        }
        // update UI and calculate processing time
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.end = DispatchTime.now()
            let nanoTime = self.end?.uptimeNanoseconds.unsafeSubtracting((self.start?.uptimeNanoseconds)!)
            let timeInterval = Double(nanoTime!) / 1000000000
            print("Time to import photos: \(timeInterval)")
        }
    }
    
    // perform OCR on image
    func scanImage( image : UIImage){
        var text : String?
        if let tesseract = G8Tesseract(language: "eng") {
            tesseract.delegate = self
            tesseract.image = image.g8_grayScale()
            tesseract.recognize()
            text = tesseract.recognizedText
        }
        self.prepareImageForSaving(image: image, text: text!)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.start = DispatchTime.now()
        scanImage(image: image!)
        self.end = DispatchTime.now()
        let nanoTime = self.end?.uptimeNanoseconds.unsafeSubtracting((self.start?.uptimeNanoseconds)!)
        let timeInterval = Double(nanoTime!) / 1000000000
        print("Time to import photos: \(timeInterval)")

        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func progressImageRecognition(for tesseract: G8Tesseract!) {
        print("Recognition progress \(tesseract.progress) %")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // load photos from core data
    func loadPhotos() -> [Photo] {
        var fetchedPhotos : [Photo] = []
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        
        do {
            fetchedPhotos = try managedContext?.fetch(request) as! [Photo]
        } catch {
            fatalError("Failed to fetch thumbnail: \(error)")
        }
        return fetchedPhotos
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchText" {
            if let searchPhotoTVC = segue.destination as? SearchView {
                searchPhotoTVC.managedObjectContext = self.managedContext
                searchPhotoTVC.photos = self.loadPhotos()
            }
        }
    }
}


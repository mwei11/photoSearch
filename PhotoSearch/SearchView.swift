//
//  SearchView.swift
//  PhotoSearch
//
//  Created by Mingyan Wei on 12/9/17.
//  Copyright © 2017 Mingyan Wei. All rights reserved.
//

import UIKit
import CoreData

class SearchView: UITableViewController, UISearchBarDelegate {
    var photos : [Photo] = []
    var filteredPhotos = [Photo]()
    var managedObjectContext : NSManagedObjectContext?
    var searchActive = false
    var deleteIndexPath : IndexPath?
    
    @IBOutlet var thumbnailView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") {
            searchActive = false
        } else {
            filteredPhotos = self.photos.filter({ (t) -> Bool in
                let temp = t.text! as NSString
                let range = temp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound})
            searchActive = true
        }
        self.thumbnailView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        searchBar.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // show relevant photos when user is searching, else show all photos
        if searchActive {
            return self.filteredPhotos.count
        } else {
            return self.photos.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "thumbnailCell", for: indexPath) as? SavedPhotoTableViewCell
        // Configure the cell...
        if cell == nil {
            tableView.register(SavedPhotoTableViewCell.classForCoder(), forCellReuseIdentifier: "thumbnailCell")
            cell = SavedPhotoTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "thumbnailCell")
        }
        if searchActive {
            cell?.textView.text = filteredPhotos[indexPath.row].text
            let thumbnail = filteredPhotos[indexPath.row].thumbnail
            cell?.thumbnailImage.image = UIImage(data: thumbnail! as Data, scale: 1.0)
        } else {
            cell?.textView.text = photos[indexPath.row].text
            let thumbnail = photos[indexPath.row].thumbnail
            cell?.thumbnailImage.image = UIImage(data: thumbnail! as Data, scale: 1.0)
        }
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "showFullSize" {
            let controller = segue.destination as! FullSizeView
            let indexPath = self.thumbnailView.indexPath(for: sender as! UITableViewCell)! as NSIndexPath
            var photo : Photo
            if searchActive {
                photo = filteredPhotos[indexPath.row]
            } else {
                photo = photos[indexPath.row]
            }
            controller.image = UIImage(data: photo.image! as Data, scale: 1.0)
            controller.text = photo.text
        }
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.deleteIndexPath = indexPath
            self.confirmDelete()
        }
    }
    
    func confirmDelete() {
        let alert = UIAlertController(title: "Delete Photo", message: "Delete this photo permanently?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeletePhoto)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeletePhoto)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width/2.0, y: self.view.bounds.size.height/2.0, width: 1.0, height: 1.0)
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleDeletePhoto(_ alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteIndexPath {
            var matches : [Photo] = []
            let request : NSFetchRequest<Photo> = Photo.fetchRequest()
            let photoTodelete : Photo?
            if searchActive {
                photoTodelete = filteredPhotos[(deleteIndexPath?.row)!]
            }
            else{
                photoTodelete = photos[(deleteIndexPath?.row)!]
            }
            request.predicate = NSPredicate(format: "text = %@", (photoTodelete?.text!)!)
            
            do{
                // find the photo in core data
                matches = try managedObjectContext?.fetch(request) as! [Photo]
                if (matches.count) > 0 {
                    // delete from core data
                    for photo in matches {
                        managedObjectContext?.delete(photo)
                    }
                }
            } catch {
                fatalError("Failed to fetch photo: \(error)")
            }
            
            do {
                // update core data after deletion
                try managedObjectContext?.save()
            } catch {
                fatalError("Failed to save photos: \(error)")
            }
            // update tableview
            thumbnailView.beginUpdates()
            
            if searchActive {
                self.filteredPhotos.remove(at: (deleteIndexPath?.row)!)
            }
            // find the entry from tableview
            var index = -1
            for i in 0..<photos.count {
                if photos[i].text == photoTodelete?.text {
                    index = i
                    break
                }
            }
            if index >= 0 {
                photos.remove(at: index)
            }
            // delete the entry from tableview
            thumbnailView.deleteRows(at: [indexPath], with: .automatic)
            deleteIndexPath = nil
            thumbnailView.endUpdates()
        }
    }
    
    func cancelDeletePhoto(_ alertAction: UIAlertAction!) -> Void {
        self.deleteIndexPath = nil
    }
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

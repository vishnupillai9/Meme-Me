//
//  SentMemesTableViewController.swift
//  Meme Me
//
//  Created by Vishnu on 14/03/15.
//  Copyright (c) 2015 Vishnu Pillai. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var memes: [Meme]!
    
    var filePath: String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent("objectArray").path
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        // Shared model
        memes = appDelegate.memes
        // Update tableview
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let array = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [Meme] {
            appDelegate.memes = array
        }
    }
    
    // MARK: - Table View Delegate
    
    // Return the number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    // Display the memed image and text for every cell in the tableview
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeCell")!
        cell.imageView?.image = memes[(indexPath as NSIndexPath).row].memedImage
        cell.textLabel?.text = memes[(indexPath as NSIndexPath).row].topText! + " " + memes[(indexPath as NSIndexPath).row].bottomText!
        return cell
    }
    
    // Segue to another view and show detail for every cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object: AnyObject = storyboard!.instantiateViewController(withIdentifier: "DetailVC")
        let detailVC = object as! DetailViewController
        detailVC.memes = memes
        detailVC.key = (indexPath as NSIndexPath).row
        navigationController!.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            memes.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Update model after deletion
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.memes = memes
            
            // Save
            let memesToBeSaved = appDelegate.memes as [Meme]
            NSKeyedArchiver.archiveRootObject(memesToBeSaved, toFile: filePath)
        }
    }
    
}

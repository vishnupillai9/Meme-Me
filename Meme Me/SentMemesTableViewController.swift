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
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        return url.URLByAppendingPathComponent("objectArray").path!
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Life Cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        //shared model
        self.memes = appDelegate.memes
        //update tableview
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if let array = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [Meme] {
            appDelegate.memes = array
        }
    }
    
    //MARK: - Table View Delegate
    
    //return the number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    //display the memed image and text for every cell in the tableview
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("MemeCell") as! UITableViewCell
        cell.imageView?.image = memes[indexPath.row].memedImage
        cell.textLabel?.text = memes[indexPath.row].topText! + " " + memes[indexPath.row].bottomText!
        return cell
    }
    
    //segue to another view and show detail for every cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let object: AnyObject = self.storyboard!.instantiateViewControllerWithIdentifier("DetailVC")
        let detailVC = object as! DetailViewController
        detailVC.memes = self.memes
        detailVC.key = indexPath.row
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            memes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            //Update model after deletion
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.memes = self.memes
            
            //Save
            let memesToBeSaved = appDelegate.memes as [Meme]
            NSKeyedArchiver.archiveRootObject(memesToBeSaved, toFile: filePath)
        }
    }
    
}

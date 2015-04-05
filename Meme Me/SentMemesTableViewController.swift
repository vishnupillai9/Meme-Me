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
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL
        return url.URLByAppendingPathComponent("objectArray").path!
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        if let array = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [Meme] {
            appDelegate.memes = array
        }
    }
    
    //return the number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    //display the memed image and text for every cell in the tableview
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("MemeCell") as UITableViewCell
        cell.imageView?.image = memes[indexPath.row].memedImage
        cell.textLabel?.text = memes[indexPath.row].topText! + " " + memes[indexPath.row].bottomText!
        return cell
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as AppDelegate
        //shared model
        self.memes = appDelegate.memes
        //update tableview
        self.tableView.reloadData()
    }
    
    //segue to another view and show detail for every cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let object: AnyObject = self.storyboard!.instantiateViewControllerWithIdentifier("DetailVC")
        let detailVC = object as DetailViewController
        detailVC.memes = self.memes
        detailVC.key = indexPath.row
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
    
    
}

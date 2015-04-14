//
//  SentMemesCollectionViewController.swift
//  Meme Me
//
//  Created by Vishnu on 15/03/15.
//  Copyright (c) 2015 Vishnu Pillai. All rights reserved.
//

import UIKit

class SentMemesCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var memes: [Meme]!
    
    var filePath: String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        return url.URLByAppendingPathComponent("objectArray").path!
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if let array = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [Meme] {
            appDelegate.memes = array
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        //shared model
        self.memes = appDelegate.memes
        //update collection view
        self.collectionView.reloadData()
    }
    
    //return the number of rows
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    //display the memed image and text for every cell in the collectionview
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCell", forIndexPath: indexPath) as! CustomMemeCell
        cell.cellImage.image = memes[indexPath.row].memedImage
        //cell.cellLabel.text = memes[indexPath.row].topText! + " " + memes[indexPath.row].bottomText!
        return cell
    }
    
    //segue to another view and show detail for every cell
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let object: AnyObject = self.storyboard!.instantiateViewControllerWithIdentifier("DetailVC")
        let detailVC = object as! DetailViewController
        detailVC.memes = self.memes
        detailVC.key = indexPath.item
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
    
    //Changing the size of the cell depending on the width of the device
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = self.view.frame.size.width / 3.33
        let height = self.view.frame.size.height / 3.33
        return CGSizeMake(width, height)
        
    }
    
    //Setting the left and right inset for cells
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)

    }
    
}

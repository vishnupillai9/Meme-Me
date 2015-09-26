//
//  SentMemesCollectionViewController.swift
//  Meme Me
//
//  Created by Vishnu on 15/03/15.
//  Copyright (c) 2015 Vishnu Pillai. All rights reserved.
//

import UIKit

class SentMemesCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    var memes: [Meme]!
    var currentIndex: NSIndexPath?
    
    var filePath: String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        return url.URLByAppendingPathComponent("objectArray").path!
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        // Shared model
        memes = appDelegate.memes
        // Update collection view
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if let array = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [Meme] {
            appDelegate.memes = array
        }
        
        // Long press gesture recognizer for cells
        let lgpr = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lgpr.minimumPressDuration = 0.5
        lgpr.delegate = self
        collectionView.addGestureRecognizer(lgpr)
        
    }
    
    // MARK: - Collection View Delegate
    
    // Return the number of rows
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    // Display the memed image and text for every cell in the collectionview
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCell", forIndexPath: indexPath) as! CustomMemeCell
        cell.cellImage.image = memes[indexPath.row].memedImage
        //cell.cellLabel.text = memes[indexPath.row].topText! + " " + memes[indexPath.row].bottomText!
        return cell
    }
    
    // Segue to another view and show detail for every cell
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("DetailVC")
        let detailVC = object as! DetailViewController
        detailVC.memes = memes
        detailVC.key = indexPath.item
        navigationController!.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - Collection View Delegate Flow Layout
    
    // Changing the size of the cell depending on the width of the device
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = view.frame.size.width / 3.33
        let height = view.frame.size.height / 3.33
        return CGSizeMake(width, height)
        
    }
    
    // Setting the left and right inset for cells
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)

    }
    
    // MARK: - Actions
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizerState.Ended {
            return
        }
        let point: CGPoint = gestureRecognizer.locationInView(collectionView)
        let indexPath: NSIndexPath? = collectionView.indexPathForItemAtPoint(point)
        
        if indexPath == nil {
            print("Couldn't find indexPath")
        } else {
            currentIndex = indexPath
            
            var alertControllerForDeletingMeme: UIAlertController
            
            alertControllerForDeletingMeme = UIAlertController(title: "This meme will be deleted from the collection.", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            alertControllerForDeletingMeme.addAction(UIAlertAction(title: "Delete Meme", style: UIAlertActionStyle.Destructive, handler: deleteMeme))
            alertControllerForDeletingMeme.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            
            presentViewController(alertControllerForDeletingMeme, animated: true, completion: nil)
        }
    }
    
    func deleteMeme(sender: UIAlertAction!) -> Void {
        let index = currentIndex
        
        memes.removeAtIndex(index!.row)
        collectionView.deleteItemsAtIndexPaths([index!])
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.memes = memes
        
        let memesToBeSaved = appDelegate.memes as [Meme]
        NSKeyedArchiver.archiveRootObject(memesToBeSaved, toFile: filePath)
        
        collectionView.reloadData()
    }
    
}

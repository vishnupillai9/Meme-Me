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
    var currentIndex: IndexPath?
    
    var filePath: String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent("objectArray").path
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        // Shared model
        memes = appDelegate.memes
        // Update collection view
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let array = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [Meme] {
            appDelegate.memes = array
        }
        
        // Long press gesture recognizer for cells
        let lgpr = UILongPressGestureRecognizer(target: self, action: #selector(SentMemesCollectionViewController.handleLongPress(_:)))
        lgpr.minimumPressDuration = 0.5
        lgpr.delegate = self
        collectionView.addGestureRecognizer(lgpr)
        
    }
    
    // MARK: - Collection View Delegate
    
    // Return the number of rows
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    // Display the memed image and text for every cell in the collectionview
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCell", for: indexPath) as! CustomMemeCell
        cell.cellImage.image = memes[(indexPath as NSIndexPath).row].memedImage
        //cell.cellLabel.text = memes[indexPath.row].topText! + " " + memes[indexPath.row].bottomText!
        return cell
    }
    
    // Segue to another view and show detail for every cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let object: AnyObject = storyboard!.instantiateViewController(withIdentifier: "DetailVC")
        let detailVC = object as! DetailViewController
        detailVC.memes = memes
        detailVC.key = (indexPath as NSIndexPath).item
        navigationController!.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - Collection View Delegate Flow Layout
    
    // Changing the size of the cell depending on the width of the device
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.size.width / 3.33
        let height = view.frame.size.height / 3.33
        return CGSize(width: width, height: height)
        
    }
    
    // Setting the left and right inset for cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)

    }
    
    // MARK: - Actions
    
    func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizerState.ended {
            return
        }
        let point: CGPoint = gestureRecognizer.location(in: collectionView)
        let indexPath: IndexPath? = collectionView.indexPathForItem(at: point)
        
        if indexPath == nil {
            print("Couldn't find indexPath")
        } else {
            currentIndex = indexPath
            
            var alertControllerForDeletingMeme: UIAlertController
            
            alertControllerForDeletingMeme = UIAlertController(title: "This meme will be deleted from the collection.", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            alertControllerForDeletingMeme.addAction(UIAlertAction(title: "Delete Meme", style: UIAlertActionStyle.destructive, handler: deleteMeme))
            alertControllerForDeletingMeme.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            
            present(alertControllerForDeletingMeme, animated: true, completion: nil)
        }
    }
    
    func deleteMeme(_ sender: UIAlertAction!) -> Void {
        let index = currentIndex
        
        memes.remove(at: (index! as NSIndexPath).row)
        collectionView.deleteItems(at: [index!])
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes = memes
        
        let memesToBeSaved = appDelegate.memes as [Meme]
        NSKeyedArchiver.archiveRootObject(memesToBeSaved, toFile: filePath)
        
        collectionView.reloadData()
    }
    
}

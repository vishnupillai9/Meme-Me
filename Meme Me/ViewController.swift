//
//  ViewController.swift
//  Meme Me
//
//  Created by Vishnu on 14/03/15.
//  Copyright (c) 2015 Vishnu Pillai. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var filePath: String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        return url.URLByAppendingPathComponent("objectArray").path!
    }
    
    //Setting the text attributes for the textfields
    let memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor.blackColor(), NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -2.0
    ]
    
    //action to dismiss the view
    @IBAction func dismissAction(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        //changing the default attributes for the textfields
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
        
        //disable the share button until an image is selected
        shareButton.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        //enable the camera button if camera is available
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        //subscribe to keyboard notifications to shift view up when keyboard is shown
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        //unsubscribe from keyboard notifications
        self.unsubscribeFromKeyboardNotifications()
    }
    
    @IBOutlet weak var pickButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var toolbar: UIToolbar!
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //clear the textfield if the text is top or bottom
        switch textField.text {
        case "TOP": fallthrough
        case "BOTTOM": textField.text = ""
        default: break
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //enable return key
        textField.resignFirstResponder()
        return true
    }
    
    //Setting the view's image as the one picked
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            imageView.contentMode = .ScaleAspectFit
            shareButton.enabled = true
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Dismissing VC if no image is picked
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //To pick an existing image
    @IBAction func pickImageFromAlbum (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //To use the camera to capture a new image
    @IBAction func captureImage (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //share action
    @IBAction func share (sender: AnyObject) {
        let objectsToShare = [generateMemedImage()]
        let avc = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        avc.excludedActivityTypes = [UIActivityTypeAddToReadingList, UIActivityTypeAirDrop]
        //to bring up the activity view controller
        self.presentViewController(avc, animated: true, completion: nil)
        avc.completionWithItemsHandler = { activity, success, items, error in
            //save and dismiss the avc
            self.save()
            self.dismissViewControllerAnimated(true, completion: nil)
        }

    }
    
    //save the meme
    func save() {
        var dictionary = [String:AnyObject]()
        
        dictionary[Meme.Keys.TopText] = topTextField.text!
        dictionary[Meme.Keys.BottomText] = bottomTextField.text!
        dictionary[Meme.Keys.Image] = imageView.image
        dictionary[Meme.Keys.MemedImage] = generateMemedImage()
        
        var meme = Meme(dictionary: dictionary)
        
        //append the meme to the shared model
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        
        let memesToBeSaved = appDelegate.memes as [Meme]
        NSKeyedArchiver.archiveRootObject(memesToBeSaved, toFile: filePath)
    }
    
    func generateMemedImage() -> UIImage {
        //hide the toolbar for image generation
        toolbar.hidden = true
        
        //Image is genereated here
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //toolbar shown after image is generated
        toolbar.hidden = false
        return memedImage
    }
    
    //Moving up view when keyboard is on screen
    func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    //Moving down view when keyboard is off screen
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    //gets the keyboard height
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        if bottomTextField.editing {
            return keyboardSize.CGRectValue().height
        } else {
            return 0
        }
        
    }
    
    func subscribeToKeyboardNotifications() {
        //keyboardWillShow method is called when keyboard is on screen
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        //keyboardWillHide method is called when keyboard is off screen
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //unsubscribe from notifications once view disappears
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
}


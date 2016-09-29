//
//  CreateMemeViewController.swift
//  Meme Me
//
//  Created by Vishnu on 14/03/15.
//  Copyright (c) 2015 Vishnu Pillai. All rights reserved.
//

import UIKit

class CreateMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var filePath: String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent("objectArray").path
    }
    
    // Setting the text attributes for the textfields
    let memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor.black, NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -2.0
    ] as [String : Any]
    
    @IBOutlet weak var pickButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var toolbar: UIToolbar!
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        // Enable the camera button if camera is available
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        // Subscribe to keyboard notifications to shift view up when keyboard is shown
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        // Changing the default attributes for the textfields
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        
        // Disable the share button until an image is selected
        shareButton.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Unsubscribe from keyboard notifications
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: - Text Field Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Clear the textfield if the text is top or bottom
        switch textField.text! {
        case "TOP": fallthrough
        case "BOTTOM": textField.text = ""
        default: break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Enable return key
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Image Picker Controller Delegate
    
    // Setting the view's image as the one picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            shareButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    // Dismissing VC if no image is picked
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    // To pick an existing image
    @IBAction func pickImageFromAlbum (_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // To use the camera to capture a new image
    @IBAction func captureImage (_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Share action
    @IBAction func share (_ sender: AnyObject) {
        let objectsToShare = [generateMemedImage()]
        let avc = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        avc.excludedActivityTypes = [UIActivityType.addToReadingList, UIActivityType.airDrop]
        // To bring up the activity view controller
        present(avc, animated: true, completion: nil)
        avc.completionWithItemsHandler = { activity, success, items, error in
            // Save and dismiss the avc
            self.save()
            self.dismiss(animated: true, completion: nil)
        }

    }
    
    // Action to dismiss the view
    @IBAction func dismissAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    // Save the meme
    func save() {
        var dictionary = [String:AnyObject]()
        
        dictionary[Meme.Keys.TopText] = topTextField.text! as AnyObject?
        dictionary[Meme.Keys.BottomText] = bottomTextField.text! as AnyObject?
        dictionary[Meme.Keys.Image] = imageView.image
        dictionary[Meme.Keys.MemedImage] = generateMemedImage()
        
        let meme = Meme(dictionary: dictionary)
        
        // Append the meme to the shared model
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        
        let memesToBeSaved = appDelegate.memes as [Meme]
        NSKeyedArchiver.archiveRootObject(memesToBeSaved, toFile: filePath)
    }
    
    func generateMemedImage() -> UIImage {
        // Hide the toolbar for image generation
        toolbar.isHidden = true
        
        // Image is genereated here
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Toolbar shown after image is generated
        toolbar.isHidden = false
        return memedImage
    }
    
    // MARK: - Notification Center
    
    // Moving up view when keyboard is on screen
    func keyboardWillShow(_ notification: Notification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    // Moving down view when keyboard is off screen
    func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    // Gets the keyboard height
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        if bottomTextField.isEditing {
            return keyboardSize.cgRectValue.height
        } else {
            return 0
        }
        
    }
    
    func subscribeToKeyboardNotifications() {
        // keyboardWillShow method is called when keyboard is on screen
        NotificationCenter.default.addObserver(self, selector: #selector(CreateMemeViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        // keyboardWillHide method is called when keyboard is off screen
        NotificationCenter.default.addObserver(self, selector: #selector(CreateMemeViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // Unsubscribe from notifications once view disappears
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}


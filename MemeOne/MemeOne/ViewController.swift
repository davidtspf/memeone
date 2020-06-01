//
//  ViewController.swift
//  ImagePickerExperiment
//
//  Created by DT on 5/25/20.
//  Copyright © 2020 DT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // all the views, text fields, and buttons
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraPickerView: UIBarButtonItem!
    @IBOutlet weak var textFieldTop: UITextField!
    @IBOutlet weak var textFieldBottom: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    // will activate right after the view loads
    override func viewDidLoad() {
        
        let memeParagraphAttributes = NSMutableParagraphStyle()
        memeParagraphAttributes.alignment = NSTextAlignment.center
        
        shareButton?.isEnabled = false
        
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.paragraphStyle: memeParagraphAttributes,
            NSAttributedString.Key.strokeColor: UIColor.blue,
            NSAttributedString.Key.foregroundColor: UIColor.green,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: 3.0
        ]
        
        self.textFieldTop.delegate = self
        self.textFieldBottom.delegate = self
        
        super.viewDidLoad()
        textFieldTop.text = "TOP"
        textFieldTop.textAlignment = .center
        textFieldTop.defaultTextAttributes = memeTextAttributes
        textFieldBottom.text = "BOTTOM"
        textFieldBottom.textAlignment = .center
        textFieldBottom.defaultTextAttributes = memeTextAttributes
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
          
    }
    
    // notifies the view controller that its view is about to be added to a view hierarchy
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraPickerView.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    // erases given text when someone clicks on the text field
    func textFieldDidBeginEditing(_ textField: UITextField){
            if textFieldTop.text == "TOP" && textField == textFieldTop {
                textFieldTop.text = ""
            }
            if textFieldBottom.text == "BOTTOM" && textField == textFieldBottom {
                textFieldBottom.text = ""
            }
    }
    
    // the keyboard will show when the user is in one of the text fields
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if textFieldBottom.isEditing, view.frame.origin.y == 0 {
               view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    // the keyboard will hide when the user is in one of the text fields
    @objc func keyboardWillHide(_ notification: NSNotification) {
        if textFieldBottom.isEditing, view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    // called when 'return' key pressed. return NO to ignore
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    // allows the user to pick an image from a given albulm
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // allows the user to get an image from the camera
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    // right after the user clicks on an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        shareButton?.isEnabled = true
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
             imagePickerView.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // the user clicked cancel and the program dismisses what's on screen
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // the structure of a "Meme"
    struct Meme {
        var topText: String
        var bottomText: String
        var originalImage: UIImage
        var memedImage: UIImage
    }

    // grab an image context and let it render the view hierarchy (image & textfields in this case) into a UIImage object
    func generateMemedImage() -> UIImage {
        // Code to hide toolbar and tab bar goes here.
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
       
        // Code to un-hide toolbar and tab bar goes here.
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = false
        
        return memedImage
    }

    // save the Meme; will be used in Meme 2.0
    func save() {
        let _ = Meme(topText: textFieldTop.text!,
             bottomText: textFieldBottom.text!,
             originalImage: imagePickerView.image!,
             memedImage: generateMemedImage())
    }
    

    // lets the share button create a meme and send it
    @IBAction func shareButton(_ sender: Any) {
        let memedImage: UIImage = generateMemedImage()
        
        // generate a meme
        let shareSheet = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        shareSheet.completionWithItemsHandler = {
            activity, success, items, error in
                if (success) {
                    self.save()
                }
        }
        
        present(shareSheet, animated: true, completion: nil)
    
    }
    
    // allows the cancel button to delete the image and set the text fields to default text
    @IBAction func cancelButton(_ sender: Any) {
        shareButton.isEnabled = false
        imagePickerView.image = nil
        textFieldTop.text = "TOP"
        textFieldBottom.text = "BOTTOM"
    }
    
}

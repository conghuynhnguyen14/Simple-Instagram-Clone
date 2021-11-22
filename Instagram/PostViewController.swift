//
//  PostViewController.swift
//  Instagram
//
//  Created by Nguyen Cong Huynh on 22/11/2021.
//

import UIKit
import Parse

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var comment: UITextField!
    @IBAction func chooseImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func postImage(_ sender: Any) {
        if let image = imageView.image {
            let post = PFObject(className: "Post")
            post["messages"] = comment.text
            post["userId"] = PFUser.current()?.objectId
            if let imageData = image.pngData() {
                let imageFile = PFFileObject(name: "image.png", data: imageData)
                post["imageFile"] = imageFile
                post.saveInBackground { (success, error) in
                    if success {
                        self.displayAlert(title: "Image Posted", message: "Your image has been posted successfully")
                        self.comment.text = ""
                        self.imageView.image = nil
                    } else {
                        self.displayAlert(title: "Image could not be posted", message: "Please try again later")
                    }
                }
            }
        }
       
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    


}

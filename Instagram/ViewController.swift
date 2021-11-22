//
//  ViewController.swift
//  Instagram
//
//  Created by Nguyen Cong Huynh on 20/11/2021.
//

import UIKit
import Parse

class ViewController: UIViewController {

    var signUpMode = true
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            performSegue(withIdentifier: "showUserTable", sender: self)
        }
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func signUp(_ sender: Any) {
        if email.text == "" || password.text == "" {
            displayAlert(title: "Error", message: "Please enter all infomation")
        } else {
            if signUpMode {
                print("Signing up...")
                let user = PFUser()
                user.username = email.text
                user.password = password.text
                user.email = email.text
                user.signUpInBackground { (success, error) in
                    if let error = error {
                        self.displayAlert(title: "Could Not sign up", message: error.localizedDescription)
                    } else {
                        print("Sign Up success")
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                    }
                }
            } else {
                PFUser.logInWithUsername(inBackground: email.text! , password:password.text!) { (user, error) in
                    if user != nil {
                        print("Log in succesful")
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                    } else {
                        var errorText = "Unknown error: please try again"
                        if error != nil {
                            errorText = error!.localizedDescription
                        }
                        self.displayAlert(title: "Could not log in", message: errorText)
                    }
                }
                }
            }
        }
    
    @IBAction func logIn(_ sender: Any) {
        if signUpMode {
            signUpMode = false
            logInButton.setTitle("Sign Up", for: [])
            signUpButton.setTitle("Log In", for: [])
        } else {
            signUpMode = true
            logInButton.setTitle("Log In", for: [])
            signUpButton.setTitle("Sign Up", for: [])
        }
    }
}


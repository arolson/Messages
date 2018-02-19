//
//  ViewController.swift
//  Messages
//
//  Created by Andrew Olson on 1/31/18.
//  Copyright © 2018 Andrew Olson. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import UserNotifications
import FirebaseInstanceID
import FirebaseMessaging

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    var userUid:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        setupButtons()
        addTapGesture()
    }
    // Subscribe to Keyboard notifications
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
    }
    // Checks if the uid is set then moves to Messages
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: DatabaseConstants.uid) {
            performSegue(withIdentifier: SegueConstants.toMessages, sender: nil)
        }
        unsubscribeToKeyboardNotifications()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueConstants.toSignUp {
            if let destination = segue.destination as? SignUpViewController {
                if self.userUid != nil {
                    destination.userUid = userUid
                }
                if let email = self.emailField.text {
                    destination.email = email
                }
                if let password = self.passwordField.text {
                    destination.password = password
                }
            }
        }
    }
    // Sign in
    @IBAction func SignIn(_ sender: AnyObject) {
        if let email = emailField.text, let password = passwordField.text {
            if email.isEmail && password.isPassword {
                signIn(email: email, password: password)
            } else {
                invalidEmailOrPassword()
            }
        }
    }
    // Sign up
    @IBAction func signUp(_ sender: AnyObject) {
        if let email = emailField.text, let password = passwordField.text {
            if email.isEmail && password.isPassword {
                print("Going to sign up")
                self.performSegue(withIdentifier: SegueConstants.toSignUp, sender: nil)
            } else {
                invalidEmailOrPassword()
            }
        }
    }
    // reset password
    @IBAction func passwordReset(_ sender: Any) {
        guard let email = emailField.text, email.isEmail else {
            displayAlert("Please enter a valid email")
            return
        }
        resetPassword(email: email)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
extension LoginViewController {
    
    // Authentication method for signing in
    func signIn(email: String, password: String) {
        startIndicator()
        Auth.auth().signIn(withEmail: email, password: password, completion: {
            (user, error) in
            if error == nil {
                self.userUid = user?.uid
                KeychainWrapper.standard.set(self.userUid, forKey: DatabaseConstants.uid)
                
                if AppDelegate.deviceId != "" {
                    let reference = Database.database().reference().child(DatabaseConstants.users).child(self.userUid)
                    reference.updateChildValues(
                        [DatabaseConstants.fromDevice: AppDelegate.deviceId]
                    )
                }
                
                self.performSegue(withIdentifier: SegueConstants.toMessages, sender: nil)
            } else {
                let errorMessage = "Email and password do not match"
                self.displayAlert(errorMessage)
                self.stopIndicator()
            }
            self.stopIndicator()
        })
    }
    
    func invalidEmailOrPassword() {
        let errorMessage = "Email must be valid, and password must conform to the following: \n Have at least one uppercase letter \n At least one digit \n At least one lowercase \n And have at least 8 characters total"
        self.displayAlert(errorMessage)
    }
    
    func setupButtons() {
        activityIndicator.isHidden = true
        signInButton.layer.cornerRadius = 5
        signInButton.layer.masksToBounds = true
        signUpButton.layer.cornerRadius = 5
        signUpButton.layer.masksToBounds = true
    }
    // Start Indicator
    func startIndicator(){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    // Stop Indicator
    func stopIndicator(){
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    // Password reset
    func resetPassword(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error != nil {
                self.displayAlert(error!.localizedDescription)
            } else {
                self.displayAlert("We have sent you an email for password reset")
            }
        }
    }
}


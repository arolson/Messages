//
//  SignUpViewController.swift
//  Messages
//
//  Created by Andrew Olson on 1/31/18.
//  Copyright © 2018 Andrew Olson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper
import Eureka

class SignUpViewController: FormViewController, UINavigationControllerDelegate, UITextFieldDelegate {

    var userUid: String!
    var email: String!
    var password: String!
    var username: String!
    var image: UIImage!
    
    let errorMessage = "Please complete all fields.\n Password must \n have at least one uppercase letter, \n at least one digit, \n at least one lowercase, \n and have at least 8 characters total"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buidForm()
        addTapGesture()
    }
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
    }
  
    override func viewDidDisappear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: DatabaseConstants.uid) {
            performSegue(withIdentifier: SegueConstants.toMessages, sender: nil)
        }
        unsubscribeToKeyboardNotifications()
    }
    
    func createAccount() {
        
        if accountSetup {
            Auth.auth().createUser(withEmail: self.email, password: self.password, completion: {
                (user, error) in
                if error != nil {
                    self.displayErrorAlert(error!.localizedDescription)
                } else {
                    if let user = user {
                        self.userUid = user.uid
                        self.uploadImg()
                    }
                }
            })
        } else {
            self.displayErrorAlert(errorMessage)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension SignUpViewController {
    
    
    func uploadImg() {
        if let imgData = UIImageJPEGRepresentation(image, 0.2) {
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            Storage.storage().reference().child(imgUid).putData(imgData, metadata: metadata) {
                (metadata, error) in
                if error != nil {
                    print("Error: \(error!.localizedDescription)")
                    self.displayErrorAlert(error!.localizedDescription)
                } else {
                    print("Upload")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.setUser(img: url)
                    }
                }
            }
        }
    }
    
    func setUser(img: String) {
        let userData = [
            DatabaseConstants.username : username!,
            DatabaseConstants.userImg : img
        ]
        KeychainWrapper.standard.set(userUid, forKey: DatabaseConstants.uid)
        let location = Database.database().reference().child(DatabaseConstants.users).child(userUid)
        location.setValue(userData)
        dismiss(animated: true, completion: nil)
    }
    
    //To delete a user
    func deleteProfile() {
        if let currentUserId = Auth.auth().currentUser?.uid {
            Database.database().reference().child(DatabaseConstants.users).child(currentUserId).removeValue(completionBlock:
            { (error, reference) in
                if error != nil {
                    print("\(error!.localizedDescription)")
                } else {
                    print("Account deleted Correctly: \n \(reference)")
                }
            })
        }
    }
    /*
     MARK: Form Builder
     - Name Row
     - Email Row
     - Password Row
     - Image Row
     */
    func buidForm() {
        ImageRow.defaultCellUpdate = { cell, row in
            cell.accessoryView?.layer.cornerRadius = 17
            cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        }
        
        form +++ Section("Account Setup")
            <<< nameRow()
            <<< emailRow()
            <<< passwordRow()
            <<< imageRow()
            <<< ButtonRow(){ row in
                row.title = "Submit"
                }.onCellSelection({ (cell, row) in
                    self.createAccount()
                })
        form +++ Section()
            <<< ButtonRow(){ row in
                row.title = "Cancel"
                }.onCellSelection({ (cell, row) in
                    self.dismiss(animated: true, completion: nil)
                }).cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .red
                })
    }
    
    func nameRow()-> NameRow {
       return NameRow(){ row in
            row.title = "Username"
            row.tag = "username"
            row.placeholder = "Enter text here"
            }
    }
    
    func emailRow()-> EmailRow {
        return EmailRow(){ row in
            row.title = "Email"
            row.tag = "email"
            row.value = self.email
            }
    }
    
    func passwordRow()-> PasswordRow {
        return PasswordRow(){ row in
            row.title = "Password"
            row.tag = "password"
            row.value = self.password
            }
    }
    
    func imageRow()-> ImageRow {
        return ImageRow(){ row in
            row.title = "Profile Image"
            row.tag = "image"
            }.onChange({ (row) in
                row.customUpdateCell()
            })
    }
    var accountSetup: Bool {
        
        let user_row = form.rowBy(tag: "username") as! NameRow
        guard let username = user_row.value, !username.isBlank else {
            print("Username field must be filled out")
            return false
        }
        self.username = username
        
        let email_row = form.rowBy(tag: "email") as! EmailRow
        guard let email = email_row.value, email.isEmail else {
            print("Email must be valid")
            return false
        }
        self.email = email
        
        let password_row = form.rowBy(tag: "password") as! PasswordRow
        guard let password = password_row.value, password.isPassword else {
            print("Password must be valid")
            return false
        }
        self.password = password
        
        let image_row = form.rowBy(tag: "image") as! ImageRow
        guard let image = image_row.value else {
            print("User Profile image needs to be selected")
            return false
        }
        self.image = image
        
        return true
    }
}

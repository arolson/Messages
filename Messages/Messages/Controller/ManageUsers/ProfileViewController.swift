//
//  ProfileViewController.swift
//  Messages
//
//  Created by Andrew Olson on 2/18/18.
//  Copyright © 2018 Andrew Olson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper
import Eureka

class ProfileViewController: FormViewController, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var userUid: String!
    var email: String!
    var password: String!
    var username: String!
    var image: UIImage!

    let errorMessage = "Please complete all fields.\n Password must \n have at least one uppercase letter, \n at least one digit, \n at least one lowercase, \n and have at least 8 characters total"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // DO NOT override these
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: DatabaseConstants.uid) {
            performSegue(withIdentifier: SegueConstants.toMessages, sender: nil)
        }
        unsubscribeToKeyboardNotifications()
    }
    /*
     MARK: Form Builder
     - Name Row
     - Email Row
     - Password Row
     - Image Row
     */
    func buildForm(_ tags: [String : String], completion: @escaping () ->Void) {
        ImageRow.defaultCellUpdate = { cell, row in
            cell.accessoryView?.layer.cornerRadius = 17
            cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        }
        
        form +++ Section("Account Setup")
            <<< nameRow(tags["username"]!)
            <<< emailRow(tags["email"]!)
            <<< passwordRow(tags["password"]!)
            <<< imageRow(tags["image"]!)
            <<< ButtonRow(){ row in
                row.title = "Submit"
                }.onCellSelection({ (cell, row) in
                    completion()
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
    
    func nameRow(_ tag: String)-> NameRow {
        return NameRow(){ row in
            row.title = "Username"
            row.tag = tag
            row.placeholder = "Enter text here"
        }
    }
    
    func emailRow(_ tag: String)-> EmailRow {
        return EmailRow(){ row in
            row.title = "Email"
            row.tag = tag
            row.value = self.email
        }
    }
    
    func passwordRow(_ tag: String)-> PasswordRow {
        return PasswordRow(){ row in
            row.title = "Password"
            row.tag = tag
            row.value = self.password
        }
    }
    
    func imageRow(_ tag: String)-> ImageRow {
        return ImageRow(){ row in
            row.title = "Profile Image"
            row.tag = tag
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
    func sendVerificationEmail() {
        Auth.auth().useAppLanguage()
        Auth.auth().currentUser?.sendEmailVerification { (error) in
            print(error!.localizedDescription)
        }
    }
}

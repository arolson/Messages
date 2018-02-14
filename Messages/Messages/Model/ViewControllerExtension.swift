//
//  ViewControllerExtension.swift
//  Messages
//
//  Created by Andrew Olson on 2/3/18.
//  Copyright © 2018 Andrew Olson. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /*MARK: KeyBoard Delegate*/
    func subscribeToKeyboardNotifications()
    {
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardWillShow(notification:)),name: NSNotification.Name.UIKeyboardWillShow,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardWillHide(notification:)),name: NSNotification.Name.UIKeyboardWillHide,object: nil)
    }
    
    func unsubscribeToKeyboardNotifications()
    {
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name.UIKeyboardWillShow,object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name.UIKeyboardWillHide,object: nil)
    }
    /*Mark: Keyboard Functionality */
    @objc func keyboardWillShow(notification: NSNotification)
    {
        let screenHeight = UIScreen.main.bounds.height
        let height = screenHeight - getKeyboardHeight(notification: notification)
        self.view.frame = newFrame(height: height)
    }
    @objc func keyboardWillHide(notification: NSNotification)
    {
        let screenHeight = UIScreen.main.bounds.height
        self.view.frame = newFrame(height: screenHeight)
    }
    func getKeyboardHeight(notification: NSNotification)-> CGFloat
    {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    func newFrame(height: CGFloat)->CGRect
    {
        let x = self.view.frame.origin.x
        let y = self.view.frame.origin.y
        let height = height
        let width = self.view.frame.width
        let frame = CGRect(x: x,y: y,width: width,height: height)
        return frame
    }
    
    //MARK: Alerts
    func displayActionSheet(title: String,message: String,actions: [UIAlertAction])
    {
        let alert = UIAlertController(title: title, message: message,preferredStyle: .actionSheet)
        for action in actions
        {
            alert.addAction(action)
        }
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayErrorAlert(_ message: String)
    {
        let alert = UIAlertController(title: "Alert",message: message,preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",style: .cancel,handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

//
//  StringExtensions.swift
//  Messages
//
//  Created by Andrew Olson on 2/3/18.
//  Copyright © 2018 Andrew Olson. All rights reserved.
//

import UIKit

extension String {
    //MARK: Email
    var isEmail: Bool {
        if self.isBlank {
            return false
        }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
        let emailTest  = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    /*
     MARK: Password
     at least one uppercase, at least one digit, at least one lowercase, 8 characters total
     */
    var isPassword: Bool {
        if self.isBlank {
            return false
        }
        let passwordRegEx = "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}"
        let passwordTest  = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: self)
    }
    var isBlank: Bool {
        if self == nil {
            return true
        } else if(self == "") {
            return true
        } else {
            return false
        }
    }
}

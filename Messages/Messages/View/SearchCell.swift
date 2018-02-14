//
//  SearchCell.swift
//  Messages
//
//  Created by Andrew Olson on 2/10/18.
//  Copyright © 2018 Andrew Olson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper

class SearchCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var searchDetail: Search!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(searchDetail: Search) {
        self.searchDetail = searchDetail
        nameLabel.text = searchDetail.username
        let reference = Storage.storage().reference(forURL: searchDetail.userImage)
        startIndicator()
        reference.getData(maxSize: 1000000) { (data, error) in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
                self.stopIndicator()
            } else {
                if let imageData = data {
                    if let image = UIImage(data: imageData) {
                        self.profileImage.image = image
                        self.stopIndicator()
                    }
                }
            }
        }
    }
    func startIndicator(){
        profileImage.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    func stopIndicator(){
        profileImage.isHidden = false
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
}

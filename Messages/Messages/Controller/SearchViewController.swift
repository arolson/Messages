//
//  SearchViewController.swift
//  Messages
//
//  Created by Andrew Olson on 2/10/18.
//  Copyright © 2018 Andrew Olson. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var table: UITableView!

    var searchDetail = [Search]()
    var filteredData = [Search]()
    
    var isSearching = false
    var detail: Search!
    var recipient: String!
    var messageId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        loadData()
    }
    @IBAction func goBack(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    //    MARK: TableView Delegat
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return self.filteredData.count
        } else {
         return searchDetail.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchData: Search!
        if isSearching {
            searchData = filteredData[indexPath.row]
        } else {
            searchData = searchDetail[indexPath.row]
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? SearchCell{
            cell.configureCell(searchDetail: searchData)
            return cell
        } else {
            return SearchCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching {
            recipient = filteredData[indexPath.row].userKey
        } else {
            recipient = searchDetail[indexPath.row].userKey
        }
        performSegue(withIdentifier: "toMessage", sender: nil)
    }
    //    MARK: Searchbar Delegat
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            table.reloadData()
        } else {
            isSearching = true
            filteredData = searchDetail.filter({ user in
                let username = user.username.lowercased()
                if let searchbarText = self.searchBar.text?.lowercased() {
                    return username.range(of: searchbarText) != nil
                }
                return false
            })
            table.reloadData()
        }
    }
    //    MARK: Prepare For Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MessageViewController {
            destination.recipient = recipient
            destination.messageId = messageId
        }
    }
}
extension SearchViewController {
    func loadData() {
        let reference = Database.database().reference().child(DatabaseConstants.users)
        reference.observe(.value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                self.searchDetail.removeAll()
                for data in snapshot {
                    if let postDict = data.value as? Dictionary<String, AnyObject> {
                        let key = data.key
                        let post = Search(userKey: key, postData: postDict)
                        self.searchDetail.append(post)
                    }
                }
            }
            self.table.reloadData()
        }
    }
}






















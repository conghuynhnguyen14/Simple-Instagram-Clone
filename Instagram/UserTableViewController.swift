//
//  UserTableViewController.swift
//  Instagram
//
//  Created by Nguyen Cong Huynh on 21/11/2021.
//

import UIKit
import Parse

class UserTableViewController: UITableViewController {
    
    var usernames = [""]
    var objectIds = [""]
    var isFollowing = ["": false]
    var refresher: UIRefreshControl = UIRefreshControl()

    @IBAction func postButton(_ sender: Any) {
        performSegue(withIdentifier: "PostSegue", sender: self)
    }
    
    @IBAction func logOutUser(_ sender: Any) {
        PFUser.logOut()
        performSegue(withIdentifier: "LogOutSegue", sender: self)
    }
    
    @objc func updateTable() {
        let query = PFUser.query()
        query?.whereKey("username", notEqualTo: PFUser.current()?.username as Any)
        query?.findObjectsInBackground(block: { (users, error) in
            if error != nil {
                print(error as Any)
            } else if let users = users {
                self.usernames.removeAll()
                self.objectIds.removeAll()
                self.isFollowing.removeAll()
                for object in users {
                    if let user = object as? PFUser {
                        if let username = user.username{
                            if let objectId = user.objectId {
                                let usernameArray = username.components(separatedBy: "@")
                                self.usernames.append(usernameArray[0])
                                self.objectIds.append(objectId)
                                let query = PFQuery(className: "Following")
                                query.whereKey("follower", equalTo: PFUser.current()?.objectId as Any)
                                query.whereKey("following", equalTo: objectId)
                                query.findObjectsInBackground { (objects, error) in
                                    if let objects = objects {
                                        if objects.count > 0 {
                                            self.isFollowing[objectId] = true
                                        } else {
                                            self.isFollowing[objectId] = false
                                        }
                                        if self.usernames.count == self.isFollowing.count {
                                            self.tableView.reloadData()
                                            self.refresher.endRefreshing()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTable()
        refresher.attributedTitle = NSAttributedString(string: "Refresh")
        refresher.addTarget(self, action: #selector(updateTable) , for: UIControl.Event.valueChanged)
        tableView.addSubview(refresher)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = usernames[indexPath.row]
        if let followsBoolean = isFollowing[objectIds[indexPath.row]]{
            if followsBoolean{
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let followsBoolean = isFollowing[objectIds[indexPath.row]]{
            if followsBoolean{
                isFollowing[objectIds[indexPath.row]] = false
                cell?.accessoryType = UITableViewCell.AccessoryType.none
                let query = PFQuery(className: "Following")
                query.whereKey("follower", equalTo: PFUser.current()?.objectId as Any)
                query.whereKey("following", equalTo: objectIds[indexPath.row])
                query.findObjectsInBackground { (objects, error) in
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                }
            } else {
                isFollowing[objectIds[indexPath.row]] = true
                cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                let following = PFObject(className: "Following")
                following["follower"] = PFUser.current()?.objectId
                following["following"] = objectIds[indexPath.row]
                following.saveInBackground()
            }
        }
        
    }
}

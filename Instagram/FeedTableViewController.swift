//
//  FeedTableViewController.swift
//  Instagram
//
//  Created by Nguyen Cong Huynh on 22/11/2021.
//

import UIKit
import Parse



class FeedTableViewController: UITableViewController {
    
    var users = [String: String]()
    var comments = [String]()
    var usernames = [String]()
    var imageFiles = [PFFileObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let query = PFUser.query()
        query?.whereKey("username", contains: PFUser.current()?.username)
        query?.findObjectsInBackground(block: { (objects, error) in
            if let users = objects {
                for object in users {
                    if let user = object as? PFUser {
                        self.users[user.objectId!] = user.username
                    }
                }
            }
            let getFollowedUserQuery = PFQuery(className: "Following")
            getFollowedUserQuery.whereKey("follower", equalTo: PFUser.current()?.objectId as Any)
            getFollowedUserQuery.findObjectsInBackground { (objects, error) in
                if let followers = objects  {
                    for follower in followers {
                        if let followedUser = follower["following"] {
                            let query = PFQuery(className: "Post")
                            query.whereKey("userId", equalTo: followedUser)
                            query.findObjectsInBackground { (objects, error) in
                                if let posts = objects {
                                    for post in posts {
                                        self.comments.append(self.users[post["messages"] as! String]!)
                                        self.usernames.append(self.users[post["userId"] as! String]!)
                                        self.imageFiles.append(post["imageFile"] as! PFFileObject)
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height/3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return comments.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FeedTableViewCell
        imageFiles[indexPath.row].getDataInBackground { (data, error) in
            if let imageData = data {
                if let imageToDisplay = UIImage(data: imageData){
                    cell.imageShow.image = imageToDisplay
                }
            }
        }
        cell.commentLabel.text = comments[indexPath.row]
        cell.usernameLabel.text = usernames[indexPath.row]
        return cell
    }



}

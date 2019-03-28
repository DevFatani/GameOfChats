//
//  NewMessageController.swift
//  gameofchats
//
//  Created by Muhammad Fatani on 25/02/2019.
//  Copyright © 2019 Muhammad Fatani. All rights reserved.
//

import UIKit
import Firebase
class NewMessageController: UITableViewController {

    let cellId = "cellId"
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
    }
    
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                let user = User(
                    uid: snapshot.key,
                    name: dictionary["name"] as! String,
                    email: dictionary["email"] as! String,
                    profileImageUrl: dictionary["profileImageUrl"] as? String ?? "https://icon2.kisspng.com/20171221/see/phoenix-logo-vector-design-5a3c31b00e5f48.7862516515138943200589.jpg"
                )
                self.users.append(user)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! UserCell
        
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.name
        
        cell.detailTextLabel?.text = user.email

        cell.profileImageView.loadImageWithCashe(url: user.profileImageUrl)
 

        return cell
    }
    
    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
                let user = self.users[indexPath.row]
            self.messagesController?.showChatControllerFor(user: user)
        }
    }
}

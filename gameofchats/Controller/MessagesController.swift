//
//  ViewController.swift
//  gameofchats
//
//  Created by Muhammad Fatani on 22/02/2019.
//  Copyright © 2019 Muhammad Fatani. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

    
    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "logout", style: .plain, target: self, action: #selector(handelLogout))
        
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(handelNewMessage))
        

        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        
        tableView.allowsSelectionDuringEditing = true

    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     return true
    }
    
    override  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
         let message = messages[indexPath.row]
        if let chatPartnerId = message.chatPartnerId()  {
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue { (error, ref) in
                if error != nil {
                    return
                }
                self.messageDictionary.removeValue(forKey: chatPartnerId)
                
                self.attemptReloadOfTable()
//                self.messages.remove(at: indexPath.row)
//                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        
        
       
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkIfUserIsLoggedIn()
    }
    

    var messages =  [Message]()
    var messageDictionary = [String: Message]()

    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
             return
        }
        
        let ref = Database
            .database()
            .reference()
            .child("user-messages")
            .child(uid)
        
        ref.observe(.childAdded) { (sapshot) in
            
                let userId = sapshot.key
                
                Database
                    .database()
                    .reference()
                    .child("user-messages")
                    .child(uid)
                    .child(userId).observe(.childAdded, with: { (snapshot2) in
                        let messageId = snapshot2.key
                        self.fetchMessageWith(messageId: messageId)
                    })
            
            ref.observe(.childRemoved, with: { (deleteSnapshot) in
                self.messageDictionary.removeValue(forKey: deleteSnapshot.key)
                self.attemptReloadOfTable()
            })
                
        }
    }
    
    private func fetchMessageWith(messageId: String) {
        Database
            .database()
            .reference()
            .child("messages")
            .child(messageId)
            .observeSingleEvent(of: .value, with: { (snapshot3) in
                if let dictionary = snapshot3.value as? [String: Any] {
                    let message = Message(dictionary: dictionary)
                    if let chatPartnerId = message.chatPartnerId() {
                        self.messageDictionary[chatPartnerId] = message
                    }
                    self.attemptReloadOfTable()
                }
            })
    }
    
    private func attemptReloadOfTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleTimer), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    @objc func handleTimer() {
        self.messages = Array(self.messageDictionary.values)
        self.messages.sort(by: { (m1, m2) -> Bool in
            return m1.timestamp!.intValue > m2.timestamp!.intValue
        })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        Database.database().reference().child("users").child(chatPartnerId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {
                return
            }
            
            let user = User(
                uid: chatPartnerId,
                name: dictionary["name"] as! String,
                email: dictionary["email"] as! String,
                profileImageUrl: dictionary["profileImageUrl"] as? String ?? "https://icon2.kisspng.com/20171221/see/phoenix-logo-vector-design-5a3c31b00e5f48.7862516515138943200589.jpg"
            )

            self.showChatControllerFor(user: user)
            
        }

    }
    
    
    @objc func handelNewMessage () {
        
        let newMessageController = NewMessageController()
        newMessageController.messagesController =  self
        
        self.present(UINavigationController(rootViewController: newMessageController), animated: true, completion: nil)
    }

    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handelLogout))
        }else {
          fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database
            .database()
            .reference()
            .child("users")
            .child(uid)
            .observeSingleEvent(of: .value) { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any] {
                    let user = User(
                        uid: snapshot.key,
                        name: dictionary["name"] as! String,
                        email: dictionary["email"] as! String,
                        profileImageUrl: dictionary["profileImageUrl"] as? String ?? "https://icon2.kisspng.com/20171221/see/phoenix-logo-vector-design-5a3c31b00e5f48.7862516515138943200589.jpg"
                    )
                    self.setupNavBarWithUser(user: user)
                }
        }
    }
    
    func setupNavBarWithUser(user:User) {
        
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.backgroundColor = .red
        
        let profileImageView = UIImageView()
        profileImageView.loadImageWithCashe(url: user.profileImageUrl)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        
        titleView.addSubview(profileImageView)
        
        
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
                profileImageView.leftAnchor.constraint(equalTo: titleView.leftAnchor),
                profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
                profileImageView.widthAnchor.constraint(equalToConstant: 40),
                profileImageView.heightAnchor.constraint(equalToConstant: 40),
                
                nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8),
                nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
                nameLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor),
                nameLabel.heightAnchor.constraint(equalToConstant: 40)
                
        ])
        
        self.navigationItem.titleView = titleView
        
    }
    
    func showChatControllerFor(user: User) {
        let chatLog = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLog.user = user
        self.navigationController?.pushViewController(chatLog , animated: true)
    }
    
    @objc func handelLogout() {
        
        do {
            try Auth.auth().signOut()
            
        } catch let logoutError{
            print(logoutError)
        }
        let nxView = LoginController()
        nxView.messagesController = self
        self.present(nxView, animated: true, completion: nil)
    }

}


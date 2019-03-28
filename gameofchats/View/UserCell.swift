//
//  UserCell.swift
//  gameofchats
//
//  Created by Muhammad Fatani on 13/03/2019.
//  Copyright © 2019 Muhammad Fatani. All rights reserved.
//

import UIKit
import Firebase

class UserCell : UITableViewCell {
    
    var message: Message? {
        didSet {
            
            setupNameAndProfileImage()
            
            self.detailTextLabel?.text = message?.text
            
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate)
            }
            
        }
    }
    
    private func setupNameAndProfileImage() {
        
        if let id = message?.chatPartnerId() {
            Database.database().reference().child("users").child(id).observe(.value) { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any] {
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageWithCashe(url: profileImageUrl)
                    }else {
                        self.profileImageView.loadImageWithCashe(url: "https://icon2.kisspng.com/20171221/see/phoenix-logo-vector-design-5a3c31b00e5f48.7862516515138943200589.jpg")
                    }
                }
            }
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "add")
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 20
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    

    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            profileImageView.heightAnchor.constraint(equalToConstant: 48),
            profileImageView.widthAnchor.constraint(equalToConstant: 48),
            
            timeLabel.rightAnchor.constraint(equalTo: rightAnchor),
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            timeLabel.widthAnchor.constraint(equalToConstant: 100),
            timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



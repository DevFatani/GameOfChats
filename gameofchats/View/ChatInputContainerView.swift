//
//  ChatInputContainerView.swift
//  gameofchats
//
//  Created by Muhammad Fatani on 29/03/2019.
//  Copyright © 2019 Muhammad Fatani. All rights reserved.
//

import UIKit

class ChatInputContainerView : UIView , UITextFieldDelegate {
    
    let sendBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("send", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
       return btn
    }()
    
    let uploadImageView : UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "logo")
        
        return iv
    }()
    
    var chatLog: ChatLogController? {
        didSet {
            sendBtn.addTarget(chatLog, action: #selector(chatLog?.handleSend), for: .touchUpInside)
                    uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLog, action: #selector(chatLog?.handleUploadTap)))

        }
    }
    
    lazy var inputTf:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Message ..."
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.delegate = self
        tf.backgroundColor = .white
        return tf
    }()
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       chatLog?.handleSend()
        return true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
  
        
        let speratorLineView = UIView()
        speratorLineView.translatesAutoresizingMaskIntoConstraints = false
        speratorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        
        addSubview(sendBtn)
        addSubview(inputTf)
        addSubview(uploadImageView)
        addSubview(speratorLineView)
        
        
        NSLayoutConstraint.activate([
            sendBtn.rightAnchor.constraint(equalTo: rightAnchor),
            sendBtn.centerYAnchor.constraint(equalTo: centerYAnchor),
            sendBtn.widthAnchor.constraint(equalToConstant: 80),
            sendBtn.heightAnchor.constraint(equalToConstant: 50),
            
            inputTf.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8),
            inputTf.centerYAnchor.constraint(equalTo: centerYAnchor),
            inputTf.rightAnchor.constraint(equalTo: sendBtn.leftAnchor),
            inputTf.heightAnchor.constraint(equalToConstant: 50),
            
            speratorLineView.topAnchor.constraint(equalTo: topAnchor),
            speratorLineView.leftAnchor.constraint(equalTo: leftAnchor),
            speratorLineView.widthAnchor.constraint(equalTo: widthAnchor),
            speratorLineView.heightAnchor.constraint(equalToConstant: 1),
            
            uploadImageView.leftAnchor.constraint(equalTo: leftAnchor),
            uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            uploadImageView.widthAnchor.constraint(equalToConstant: 44),
            uploadImageView.heightAnchor.constraint(equalToConstant: 44),
            ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

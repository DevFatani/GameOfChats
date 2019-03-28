//
//  ChatMessageCell.swift
//  gameofchats
//
//  Created by Muhammad Fatani on 16/03/2019.
//  Copyright © 2019 Muhammad Fatani. All rights reserved.
//

import UIKit
import AVFoundation
class ChatMessageCell: UICollectionViewCell {
    
    var chatLog: ChatLogController? = nil
    
    var message: Message?
    
    let activityIndicatorView: UIActivityIndicatorView = {
       let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    lazy var  playButton: UIButton = {
        let btn = UIButton(type: .system)
        let image = UIImage(named: "logo")
        btn.tintColor = .white
        btn.setImage(image, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handlePlay), for: .touchDown)
        return btn
    }()
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    @objc func handlePlay() {
        if let videoUrl = message?.videoUrl, let url =  URL(string: videoUrl) {
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            player?.play()
            
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
            
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
    
    let textView: UITextView = {
       let tv = UITextView()
        tv.text = "Fuck fuck"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.isEditable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        return tv
    }()
    
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    static let blueColor = UIColor(r: 0, g: 137, b: 249)
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    lazy var messsageImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 16
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return iv
    }()
    
    
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        if message?.videoUrl != nil { return }
        guard let imageView = tapGesture.view as? UIImageView else {
            return
        }
        chatLog?.performZoomInFor(imageView: imageView)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        bubbleView.addSubview(messsageImageView)
        bubbleView.addSubview(playButton)
        bubbleView.addSubview(activityIndicatorView)
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        
        NSLayoutConstraint.activate([
            
                profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
                profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 8),
                profileImageView.widthAnchor.constraint(equalToConstant: 32),
                profileImageView.heightAnchor.constraint(equalToConstant: 32),
            
                bubbleViewRightAnchor!,
                bubbleView.topAnchor.constraint(equalTo: topAnchor),
                bubbleWidthAnchor!,
                bubbleView.heightAnchor.constraint(equalTo: heightAnchor),
            
                textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8),
                textView.topAnchor.constraint(equalTo: topAnchor),
                textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor),
                textView.heightAnchor.constraint(equalTo: heightAnchor),
                
                
                messsageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor),
                messsageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                messsageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor),
                messsageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor),
                
                
                playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
                playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
                playButton.widthAnchor.constraint(equalToConstant: 50),
                playButton.heightAnchor.constraint(equalToConstant: 50),
                
                activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
                activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
                activityIndicatorView.widthAnchor.constraint(equalToConstant: 50),
                activityIndicatorView.heightAnchor.constraint(equalToConstant: 50),
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

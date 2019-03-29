//
//  ChatLogController.swift
//  gameofchats
//
//  Created by Muhammad Fatani on 09/03/2019.
//  Copyright © 2019 Muhammad Fatani. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation
class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let cellId = "cellId"
    
    var messages = [Message]()
    
    
    var user: User?{
        didSet {
            self.navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    func observeMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.uid else {
            return
        }
        
        Database.database().reference().child("user-messages").child(uid).child(toId).observe(.childAdded) { (snapshot) in
            let messageId = snapshot.key
            
            Database.database().reference().child("messages").child(messageId).observeSingleEvent(of: .value, with: { (snapshot2) in
                
                guard let dictionary = snapshot2.value as? [String: Any] else { return }
                
                let message = Message(dictionary: dictionary)
            
                self.messages.append(message)
                    
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
                
            })
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
//        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 58, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        setupKeyboardObservers()
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification , object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated:  true)
        }
    }
    
    
    lazy var inputContainerView: ChatInputContainerView = {
        let chatInputContainerView = ChatInputContainerView(frame:  CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.chatLog = self
        return chatInputContainerView
    }()
    
    @objc func handleUploadTap() {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePickerController, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            handleVideoSelectedFor(xxxUrl: videoUrl)
        }else {
           handleImageSelectedFor(info: info)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSelectedFor(xxxUrl: URL) {
        let filename = UUID().uuidString + ".mov"
        let storageRef = Storage.storage().reference().child("message_movies").child(filename)
        
        let uploadTask = storageRef.putFile(from: xxxUrl, metadata: nil, completion: { (metadata, uploadError) in
            if uploadError != nil { return }
            storageRef.downloadURL(completion: { (url, urlError) in
                guard let videoUrl = url?.absoluteString else { return }
                print(videoUrl , "🤩🤩🤩")
                if let thumbnailImage = self.thumbnailImageFor(videoUrl: xxxUrl) {
                    
                    self.uploadToFirebaseStoreage(image: thumbnailImage, completion: { (imageUrlFucking) in
                        let properties: [String: Any] = [
                            
                            "imageWidth": thumbnailImage.size.width,
                            "imageHeight": thumbnailImage.size.height,
                            "imageUrl": imageUrlFucking,
                            "videoUrl": videoUrl
                        ]
                       
                        self.sendMessageWith(properties: properties)
                    })
                
                }
            })
            
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUnitCount)
            }
        }
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
        
    }
    
    private func thumbnailImageFor(videoUrl: URL) -> UIImage? {
        let asset = AVAsset(url: videoUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
       
             let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil)
            
            return UIImage(cgImage: thumbnailCGImage)
        }catch let err {
            print(err)
        }
       
        return nil
    }
    
    private func handleImageSelectedFor(info: [UIImagePickerController.InfoKey: Any]) {
        var selectedImage:UIImage?
        if let editImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = editImage
        }else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectedImage = originalImage
        }
        
        
        if let shitImage = selectedImage {
            uploadToFirebaseStoreage(image: shitImage) { (imageUrl) in
                self.sendMessageWith(imageUrl: imageUrl, image: shitImage)
            }
        }
    }
    
    private func uploadToFirebaseStoreage(image: UIImage, completion: @escaping (_ imageUrl:String) -> ()) {
        let uploadData = image.jpegData(compressionQuality: 0.1)!
        let storageRef = Storage
            .storage()
            .reference()
            .child("message_images")
            .child("\(UUID().uuidString).png")
            
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, uploadError) in
                if uploadError != nil {
                    return
                }
            
                storageRef.downloadURL(completion: { (url, urlError) in
                    if let imageUrl = url?.absoluteString {
                       completion(imageUrl)
                    }
                })
            
        })
    }
    
    override var inputAccessoryView: UIView? {
        get {
         return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
   
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell

        let message = messages[indexPath.row]
        cell.message = message
        cell.textView.text = message.text
        cell.chatLog = self
        setup(cell: cell, forMessage: message)
        
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameFor(text: text).width + 32
            cell.textView.isHidden = false
        }else if message.messageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
  
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat  = 80
        
        let message = messages[indexPath.row]
        if let text = message.text {
                height = estimateFrameFor(text: text).height + 20
        }else if let imageWidth = message.imageWidth?.floatValue,
            let imageHeight = message.imageHeight?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        

        return CGSize(width: view.frame.width, height: height)
    }
    
    
    func setup(cell: ChatMessageCell, forMessage message: Message) {
    
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageWithCashe(url: profileImageUrl)
        }
        
        
        if message.fromId == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        }else {
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        if let messageImageUrl = message.messageUrl {
            cell.messsageImageView.loadImageWithCashe(url: messageImageUrl)
            cell.messsageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear
        }else {
            cell.messsageImageView.isHidden = true
    
        }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func estimateFrameFor(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        
        
        return NSString(string: text).boundingRect(with: size, options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    
   
    @objc func handleSend() {
        let values: [String : Any] = ["text": inputContainerView.inputTf.text!]
        sendMessageWith(properties: values)
    }
    
    private func sendMessageWith(imageUrl:String, image:UIImage) {
        
        let values: [String : Any] = [
            "imageUrl": imageUrl,
            "imageWidth": image.size.width,
            "imageHeight": image.size.height
        ]
        
        sendMessageWith(properties: values)
    }
    
    private func sendMessageWith(properties: [String: Any]) {
        let ref = Database.database().reference().child("messages").childByAutoId()
        let toId = user!.uid
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(NSDate().timeIntervalSince1970)
        var values:  [String : Any] = [
            "toId": toId,
            "fromId": fromId,
            "timestamp": timestamp]
        
        properties.forEach({ values[$0] = $1 })
        
        ref.updateChildValues(values) { (error, snapshot) in
            if error != nil {
                return
            }
            
            self.inputContainerView.inputTf.text = nil
            
            let messageId = ref.key!
            Database.database().reference().child("user-messages").child(fromId).child(toId).updateChildValues([messageId: 1])
            
            Database.database().reference().child("user-messages").child(toId).child(fromId).updateChildValues([messageId: 1])
        }
    }
   
    
    
    var startingFrame: CGRect?
    var blackBgView : UIView?
    var startingImageView: UIImageView?
    
    func performZoomInFor(imageView: UIImageView) {
        
        self.startingImageView = imageView
        self.startingImageView?.isHidden = true
        
        
        startingFrame = imageView.superview?.convert(imageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = imageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            
            blackBgView = UIView(frame: keyWindow.frame)
            blackBgView?.backgroundColor = .black
            blackBgView?.alpha = 0
            
            keyWindow.addSubview(blackBgView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBgView?.alpha = 1
                
                self.inputContainerView.alpha = 0
                
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            }, completion: nil)
        }
    }
    
    @objc func handleZoomOut(tapGes: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGes.view {
            
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBgView?.alpha = 0
                self.inputContainerView.alpha = 1
            }, completion: { _ in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
                
            })
        }
    }
}

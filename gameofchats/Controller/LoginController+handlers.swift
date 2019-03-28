//
//  LoginController+handlers.swift
//  gameofchats
//
//  Created by Muhammad Fatani on 27/02/2019.
//  Copyright © 2019 Muhammad Fatani. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage:UIImage?
        if let editImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = editImage
        }else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectedImage = originalImage
        }
        
        profileImageView.image = selectedImage
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleRegister() {
        guard let email = emailTf.text,
            let password = passwordTf.text,
            let name = nameTf.text else {
                print("data not valid")
                return
        }
        
        Auth.auth().createUser(withEmail:email, password: password) {(user, error) in
            if error != nil {
                print("error: \(error)")
                return
            }
            
            guard let uid = user?.user.uid else {return}
            
            
            let storageRef = Storage.storage().reference().child("profile_images").child("\(UUID().uuidString).png")
            let uploadData = self.profileImageView.image!.jpegData(compressionQuality: 0.1)!

           
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, uploadError) in
                if uploadError != nil {
                    return
                }
                
                storageRef.downloadURL(completion: { (url, urlError) in
                    if let  imageUrl = url?.absoluteString {
                        self.registerUserInfoDatabase(uid: uid, values: [
                            "name": name,
                            "email": email,
                            "profileImageUrl": imageUrl
                        ])
                    }
                })
              
            })
            
            
        }
    }
    
    func registerUserInfoDatabase(uid:String, values: [String:Any]) {
        let ref = Database
            .database()
            .reference()
            .child("users/\(uid)")
        ref.updateChildValues(values, withCompletionBlock: { (err, response) in
            if err != nil {
                print("err: \(err?.localizedDescription)")
                return
                
            }
            
            let user = User(
                uid: uid,
                name: values["name"] as! String,
                email: values["email"] as! String,
                profileImageUrl: values["profileImageUrl"] as? String ?? "https://icon2.kisspng.com/20171221/see/phoenix-logo-vector-design-5a3c31b00e5f48.7862516515138943200589.jpg"
            )
            self.messagesController?.setupNavBarWithUser(user: user)
            self.dismiss(animated: true, completion: nil)
        })
    }
}

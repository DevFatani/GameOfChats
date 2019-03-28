//
//  LoginController.swift
//  gameofchats
//
//  Created by Muhammad Fatani on 22/02/2019.
//  Copyright © 2019 Muhammad Fatani. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import Firebase

class LoginController: UIViewController {
    
    var messagesController: MessagesController?
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    lazy var loginRegisterBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor  = UIColor(r: 80, g: 101, b: 161)
        btn.setTitle("Register", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return btn
    }()
    
    
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        }else {
            handleRegister()
        }
    }
    
    func handleLogin() {
        
        guard let email = emailTf.text,
            let password = passwordTf.text else {
                print("data not valid")
                return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error)
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    let nameTf: UITextField = {
        let tf = UITextField()
        tf.placeholder = "name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSepratorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    
    let emailTf: UITextField = {
        let tf = UITextField()
        tf.placeholder = "email"
        tf.keyboardType = .emailAddress
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSepratorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    let passwordTf: UITextField = {
        let tf = UITextField()
        tf.placeholder = "password"
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
 
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = .white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    @objc func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterBtn.setTitle(title, for: .normal)
        inputContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex  == 0 ? 100 : 150
        
        nameTextFiledHeightAnchor?.isActive = false
        nameTextFiledHeightAnchor = nameTf.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier:loginRegisterSegmentedControl.selectedSegmentIndex  == 0 ? 0 : 1 / 3)
        nameTextFiledHeightAnchor?.isActive = true
        
        
        emailTextFiledHeightAnchor?.isActive = false
        emailTextFiledHeightAnchor = emailTf.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier:loginRegisterSegmentedControl.selectedSegmentIndex  == 0 ? 1/2 : 1 / 3)
        emailTextFiledHeightAnchor?.isActive = true
        
        passwordTextFiledHeightAnchor?.isActive = false
        passwordTextFiledHeightAnchor = passwordTf.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier:loginRegisterSegmentedControl.selectedSegmentIndex  == 0 ? 1/2 : 1 / 3)
        passwordTextFiledHeightAnchor?.isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterBtn)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        
        setupContainerView()
        setupLoginRegisterBtn()
        setupProfileImageView()
        setupLoginRegisterSegmentedControl()
    }
    
    func setupLoginRegisterSegmentedControl() {
        NSLayoutConstraint.activate([
                loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12),
                loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1),
                loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36)
            
        ])
    }
    
    func setupProfileImageView() {
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12),
            profileImageView.widthAnchor.constraint(equalToConstant: 150),
            profileImageView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    var inputContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFiledHeightAnchor: NSLayoutConstraint?
     var emailTextFiledHeightAnchor: NSLayoutConstraint?
     var passwordTextFiledHeightAnchor: NSLayoutConstraint?
    
    func setupContainerView() {
        inputContainerViewHeightAnchor =  inputsContainerView.heightAnchor.constraint(equalToConstant: 150)

        NSLayoutConstraint.activate([
            inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24),
            inputContainerViewHeightAnchor!
        ])
        
        inputsContainerView.addSubview(nameTf)
        inputsContainerView.addSubview(nameSepratorView)
        
        inputsContainerView.addSubview(emailTf)
        inputsContainerView.addSubview(emailSepratorView)
        
        inputsContainerView.addSubview(passwordTf)
        
        
        
        nameTextFiledHeightAnchor = nameTf.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        
        NSLayoutConstraint.activate([
            nameTf.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12),
            nameTf.topAnchor.constraint(equalTo: inputsContainerView.topAnchor),
            nameTf.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
            nameTextFiledHeightAnchor!
        ])
        
        NSLayoutConstraint.activate([
            nameSepratorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor),
            nameSepratorView.topAnchor.constraint(equalTo: nameTf.bottomAnchor),
            nameSepratorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
            nameSepratorView.heightAnchor.constraint(equalToConstant: 1)
            ])
        
        emailTextFiledHeightAnchor = emailTf.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        
        NSLayoutConstraint.activate([
            emailTf.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12),
            emailTf.topAnchor.constraint(equalTo: nameTf.bottomAnchor),
            emailTf.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
            emailTextFiledHeightAnchor!
            ])
        
        
        
        NSLayoutConstraint.activate([
            emailSepratorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor),
            emailSepratorView.topAnchor.constraint(equalTo: emailTf.bottomAnchor),
            emailSepratorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
            emailSepratorView.heightAnchor.constraint(equalToConstant: 1)
            ])
        
        
        passwordTextFiledHeightAnchor =  passwordTf.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        NSLayoutConstraint.activate([
            passwordTf.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12),
            passwordTf.topAnchor.constraint(equalTo: emailTf.bottomAnchor),
            passwordTf.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
            passwordTextFiledHeightAnchor!
        ])
    }
    
    func setupLoginRegisterBtn() {
        NSLayoutConstraint.activate([
            loginRegisterBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginRegisterBtn.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12),
            loginRegisterBtn.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
            loginRegisterBtn.heightAnchor.constraint(equalToConstant: 45)
            
            ])
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b:CGFloat) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
    }
}

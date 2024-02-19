//
//  SignUpViewController.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 17.02.2024.
//

import UIKit
import SafariServices

class SignUpViewController: UIViewController {
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .lightGray
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 45
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    private let usernameField: iNSTextField = {
        let field = iNSTextField()
        field.placeholder = "Username"
        field.returnKeyType = .next
        field.autocorrectionType = .no
        
        return field
    }()

    private let emailField: iNSTextField = {
        let field = iNSTextField()
        field.placeholder = "Email Address"
        field.keyboardType = .emailAddress
        field.returnKeyType = .next
        field.autocorrectionType = .no
        
        return field
    }()
    
    private let passwordField: iNSTextField = {
        let field = iNSTextField()
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        field.keyboardType = .default
        field.returnKeyType = .continue
        field.autocorrectionType = .no
        
        return field
    }()

    private let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = .systemPink
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        
        return button
    }()
    
    private let termsOfUseButton: UIButton = {
        let button = UIButton()
        button.setTitle("Terms of Use", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        
        return button
    }()
    
    private let dataPolicyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Data Policy", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        
        return button
    }()

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        view.backgroundColor = .secondarySystemBackground
        view.addSubviews(avatarImageView, usernameField, emailField, passwordField, signUpButton,termsOfUseButton, dataPolicyButton)
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        addButtonActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imageSize: CGFloat = 90
        avatarImageView.frame = CGRect(
            x: (view.width - imageSize) / 2,
            y: view.safeAreaInsets.top + 15,
            width: imageSize,
            height: imageSize
        )
        usernameField.frame = CGRect(
            x: 25,
            y: avatarImageView.bottom + 20,
            width: view.width - 50,
            height: 50
        )
        emailField.frame = CGRect(
            x: 25,
            y: usernameField.bottom + 20,
            width: view.width - 50,
            height: 50
        )
        passwordField.frame = CGRect(
            x: 25,
            y: emailField.bottom + 20,
            width: view.width - 50,
            height: 50
        )
        signUpButton.frame = CGRect(
            x: 25,
            y: passwordField.bottom + 40,
            width: view.width - 50,
            height: 50
        )
        termsOfUseButton.frame = CGRect(
            x: 25,
            y: view.height - view.safeAreaInsets.bottom - 40,
            width: (view.width - 50) / 2,
            height: 50
        )
        dataPolicyButton.frame = CGRect(
            x: (view.width - termsOfUseButton.right + 5),
            y: view.height - view.safeAreaInsets.bottom - 40,
            width: (view.width - termsOfUseButton.right - 25),
            height: 50
        )
    }
    
    //MARK: - Private
    private func addButtonActions() {
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        termsOfUseButton.addTarget(self, action: #selector(didTapTermsOfUse), for: .touchUpInside)
        dataPolicyButton.addTarget(self, action: #selector(didTapDataPolicy), for: .touchUpInside)
    }
    
    @objc private func didTapSignUp() {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text, let password = passwordField.text,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 8 else {
            
            return
        }
        // Sign In
    }

    @objc private func didTapTermsOfUse() {
        guard let url = URL(string: "https://help.instagram.com/581066165581870") else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    @objc private func didTapDataPolicy() {
        guard let url = URL(string: "https://help.instagram.com/155833707900388") else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            didTapSignUp()
        }
        return true
    }
}

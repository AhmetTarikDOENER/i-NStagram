//
//  SignUpViewController.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 17.02.2024.
//

import UIKit
import SafariServices

class SignUpViewController: UIViewController {
    
    public var completion: (() -> Void)?
    
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
        addAvatarGesture()
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
    private func addAvatarGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapAvatar))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tap)
    }
    
    @objc private func didTapAvatar() {
        let actionSheet = UIAlertController(
            title: "Profile Picture",
            message: "Set a picture to help your friends to find you.",
            preferredStyle: .actionSheet
        )
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: {
            [weak self] _ in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.allowsEditing = true
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: {
            [weak self] _ in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        
        present(actionSheet, animated: true)
    }
    
    private func addButtonActions() {
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        termsOfUseButton.addTarget(self, action: #selector(didTapTermsOfUse), for: .touchUpInside)
        dataPolicyButton.addTarget(self, action: #selector(didTapDataPolicy), for: .touchUpInside)
    }
    
    @objc private func didTapSignUp() {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text, let password = passwordField.text,
              let username = usernameField.text,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              !username.trimmingCharacters(in: .whitespaces).isEmpty,
              username.trimmingCharacters(in: .alphanumerics).isEmpty,
              password.count >= 8,
              username.count >= 2 else {
            let alert = UIAlertController(
                title: "Woops!",
                message: "Please make sure to fill all field and have a password longers than 8 characters.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            present(alert, animated: true)
            return
        }
        // Sign Up
        AuthManager.shared.signUp(
            email: email,
            username: username,
            password: password,
            profilePictureData: avatarImageView.image?.pngData()
        ) {
            [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    UserDefaults.standard.setValue(user.email, forKey: "email")
                    UserDefaults.standard.setValue(user.username, forKey: "username")
                    self?.navigationController?.popToRootViewController(animated: true)
                    self?.completion?()
                case .failure(let error):
                    print("\n\nSign Up Error: \(error)")
                }
            }
        }
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

//MARK: - UITextFieldDelegate
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

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let avatar = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        avatarImageView.image = avatar
    }
}

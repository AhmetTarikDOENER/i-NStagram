//
//  SignInViewController.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 17.02.2024.
//

import UIKit
import SafariServices

class SignInViewController: UIViewController {
    
    private let headerView = SignInHeaderView()
    
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

    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        
        return button
    }()
    
    private let createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create Account", for: .normal)
        button.setTitleColor(.label, for: .normal)
        
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
        title = "Sign In"
        view.backgroundColor = .secondarySystemBackground
        view.addSubviews(headerView, emailField, passwordField, signInButton, createAccountButton, termsOfUseButton, dataPolicyButton)
        emailField.delegate = self
        passwordField.delegate = self
        addButtonActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.width,
            height: (view.height  - view.safeAreaInsets.top) / 3
        )
        emailField.frame = CGRect(
            x: 25,
            y: headerView.bottom + 20,
            width: view.width - 50,
            height: 50
        )
        passwordField.frame = CGRect(
            x: 25,
            y: emailField.bottom + 10,
            width: view.width - 50,
            height: 50
        )
        signInButton.frame = CGRect(
            x: 25,
            y: passwordField.bottom + 20,
            width: view.width - 50,
            height: 50
        )
        createAccountButton.frame = CGRect(
            x: 25,
            y: signInButton.bottom + 20,
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
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        termsOfUseButton.addTarget(self, action: #selector(didTapTermsOfUse), for: .touchUpInside)
        dataPolicyButton.addTarget(self, action: #selector(didTapDataPolicy), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccount), for: .touchUpInside)
    }
    
    @objc private func didTapSignIn() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text, let password = passwordField.text,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 8 else {
            
            return
        }
        // Sign In
        AuthManager.shared.signIn(
            email: email,
            password: password
        ) {
            [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    HapticsManager.shared.vibrate(for: .success)
                    let vc = TabBarViewController()
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true)
                case .failure:
                    HapticsManager.shared.vibrate(for: .error)
                }
            }
        }
    }
    
    @objc private func didTapCreateAccount() {
        let vc = SignUpViewController()
        vc.completion = {
            [weak self] in
            DispatchQueue.main.async {
                let tabVC = TabBarViewController()
                tabVC.modalPresentationStyle = .fullScreen
                self?.present(tabVC, animated: true)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
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

extension SignInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            didTapSignIn()
        }
        return true
    }
}

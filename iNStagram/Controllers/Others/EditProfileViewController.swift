//
//  EditProfileViewController.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 25.02.2024.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    public var completion: (() -> Void)?
    
    private let nameField: iNSTextField = {
        let field = iNSTextField()
        field.placeholder = "Name.."
        
        return field
    }()
    
    private let bioTextView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        textView.backgroundColor = .secondarySystemBackground
        
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Profile"
        view.backgroundColor = .systemBackground
        view.addSubviews(nameField, bioTextView)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(didTapSave)
        )
        guard let username = UserDefaults.standard.string(forKey: "username") else { return }
        DatabaseManager.shared.getUserInfo(username: username) {
            [weak self] info in
            DispatchQueue.main.async {
                if let info = info {
                    self?.nameField.text = info.name
                    self?.bioTextView.text = info.bio
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nameField.frame = CGRect(
            x: 20,
            y: view.safeAreaInsets.top + 10,
            width: view.width - 40,
            height: 50
        )
        bioTextView.frame = CGRect(
            x: 20,
            y: nameField.bottom + 10,
            width: view.width - 40,
            height: 120
        )
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    @objc private func didTapSave() {
        let name = nameField.text ?? ""
        let bio = bioTextView.text ?? ""
        let newInfo = UserInfo(name: name, bio: bio)
        DatabaseManager.shared.setUserInfo(userInfo: newInfo) {
            [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.completion?()
                    self?.didTapClose()
                }
            }
        }
    }
}

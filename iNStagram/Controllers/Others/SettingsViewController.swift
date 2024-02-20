//
//  SettingsViewController.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 17.02.2024.
//

import UIKit

class SettingsViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return tableView
    }()

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
        createTableFooter()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    private func createTableFooter() {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 50))
        footer.clipsToBounds = true
        let button = UIButton(frame: footer.bounds)
        footer.addSubview(button)
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(.systemPink, for: .normal)
        button.addTarget(self, action: #selector(didTapSignOut), for: .touchUpInside)
        tableView.tableFooterView = footer
    }
    
    @objc private func didTapSignOut() {
        let actionSheet = UIAlertController(
            title: "Sign Out",
            message: "Are you sure to sign out?",
            preferredStyle: .actionSheet
        )
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: {
            _ in
            AuthManager.shared.signOut {
                [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        let vc = SignInViewController()
                        let navVC = UINavigationController(rootViewController: vc)
                        navVC.modalPresentationStyle = .fullScreen
                        self?.present(navVC, animated: true)
                    }
                }
            }
        }))
        present(actionSheet, animated: true)
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
    
}

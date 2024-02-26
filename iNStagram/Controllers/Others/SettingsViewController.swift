//
//  SettingsViewController.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 17.02.2024.
//

import UIKit
import SafariServices

class SettingsViewController: UIViewController {
    
    private var sections: [SettingsSection] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return tableView
    }()

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        configureModels()
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
    
    private func configureModels() {
        sections.append(
            SettingsSection(
                title: "App",
                options: [
                    SettingOptions(
                        title: "Rate App",
                        image: UIImage(systemName: "star"),
                        color: .systemPink,
                        handler: {
                            guard let url = URL(string: "https://www.instagram.com/") else { return }
                            DispatchQueue.main.async {
                                UIApplication.shared.open(url, options: [:])
                            }
                        }
                    ),
                    SettingOptions(
                        title: "Share App",
                        image: UIImage(systemName: "square.and.arrow.up"),
                        color: .systemYellow,
                        handler: {
                            [weak self] in
                            guard let url = URL(string: "https://www.instagram.com/") else { return }
                            DispatchQueue.main.async {
                                let vc = UIActivityViewController(
                                    activityItems: [url],
                                    applicationActivities: []
                                )
                                self?.present(vc, animated: true)
                            }
                        }
                    )
                ]
            )
        )
        sections.append(
            SettingsSection(
                title: "Information",
                options: [
                    SettingOptions(
                        title: "Terms of Use",
                        image: UIImage(systemName: "doc"),
                        color: .systemGreen,
                        handler: {
                            [weak self] in
                            guard let url = URL(string: "https://help.instagram.com/581066165581870") else { return }
                            DispatchQueue.main.async {
                                let vc = SFSafariViewController(url: url)
                                self?.present(vc, animated: true)
                            }
                        }
                    ),
                    SettingOptions(
                        title: "Data Policy",
                        image: UIImage(systemName: "hand.raised"),
                        color: .systemBlue,
                        handler: {
                            [weak self] in
                            guard let url = URL(string: "https://help.instagram.com/155833707900388") else { return }
                            DispatchQueue.main.async {
                                let vc = SFSafariViewController(url: url)
                                self?.present(vc, animated: true)
                            }
                        }
                    ),
                    SettingOptions(
                        title: "Get Help",
                        image: UIImage(systemName: "message"),
                        color: .systemPurple,
                        handler: {
                            [weak self] in
                            guard let url = URL(string: "https://help.instagram.com/") else { return }
                            DispatchQueue.main.async {
                                let vc = SFSafariViewController(url: url)
                                self?.present(vc, animated: true)
                            }
                        }
                    )
                ]
            )
        )
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        cell.imageView?.image = model.image
        cell.imageView?.tintColor = model.color
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }
    
}

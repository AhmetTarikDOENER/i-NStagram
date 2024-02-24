//
//  NotificationsViewController.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 17.02.2024.
//

import UIKit

class NotificationsViewController: UIViewController {
    
    private var viewModels: [NotificationCellType] = []
    private var models: [IGNotification] = []

    private let noActivityLabel: UILabel = {
        let label = UILabel()
        label.text = "No Notifications"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.isHidden = true
        tableView.register(LikeNotificationTableViewCell.self, forCellReuseIdentifier: LikeNotificationTableViewCell.identifier)
        tableView.register(CommentNotificationTableViewCell.self, forCellReuseIdentifier: CommentNotificationTableViewCell.identifier)
        tableView.register(FollowNotificationTableViewCell.self, forCellReuseIdentifier: FollowNotificationTableViewCell.identifier)
        
        return tableView
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        view.backgroundColor = .systemBackground
        view.addSubviews(tableView, noActivityLabel)
        tableView.delegate = self
        tableView.dataSource = self
        fetchNotifications()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noActivityLabel.sizeToFit()
        noActivityLabel.center = view.center
    }
    
    private func fetchNotifications() {
        NotificationsManager.shared.getNotifications {
            [weak self] models in
            DispatchQueue.main.async {
                self?.models = models
                self?.createViewModels()
            }
        }
    }
    
    private func createViewModels() {
        models.forEach {
            model in
            guard let type = NotificationsManager.IGType(rawValue: model.notificationType) else { return }
            let username = model.username
            guard let profilePictureURL = URL(string: model.profilePictureURL) else { return }
            switch type {
            case .like:
                guard let postURL = URL(string: model.postURL ?? "") else { return }
                viewModels.append(
                    .like(
                        viewModel: .init(
                            username: username,
                            profilePictureURL: profilePictureURL,
                            postURL: postURL
                        )
                    )
                )
            case .comment:
                guard let postURL = URL(string: model.postURL ?? "") else { return }
                viewModels.append(
                    .comment(
                        viewModel: .init(
                            username: username,
                            profilePictureURL: profilePictureURL,
                            postURL: postURL
                        )
                    )
                )
            case .follow:
                guard let isFollowing = model.isFollowing else { return }
                viewModels.append(
                    .follow(
                        viewModel: .init(
                            username: username,
                            profilePictureURL: profilePictureURL,
                            isCurrentUserFollowing: isFollowing
                        )
                    )
                )
            }
        }
        if viewModels.isEmpty {
            noActivityLabel.isHidden = false
            tableView.isHidden = true
        } else {
            noActivityLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    private func mockData() {
        tableView.isHidden = false
        guard let postURL = URL(string: "https://picsum.photos/200/300?random=8") else { return }
        guard let iconURL = URL(string: "https://picsum.photos/200/300?random=14") else { return }
        viewModels = [
            .like(
                viewModel: .init(
                    username: "kanyewest",
                    profilePictureURL: iconURL,
                    postURL: postURL
                )
            ),
            .comment(
                viewModel: .init(
                    username: "arianagrande",
                    profilePictureURL: iconURL,
                    postURL: postURL
                )
            ),
            .follow(
                viewModel: .init(
                    username: "willsmith",
                    profilePictureURL: iconURL,
                    isCurrentUserFollowing: true
                )
            )
        ]
        tableView.reloadData()
    }
    
    private func openPost(with index: Int, username: String) {
        guard index < models.count else { return }
        let model = models[index]
        let username = username
        guard let postID = model.postID else { return }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = viewModels[indexPath.row]
        switch cellType {
        case .follow(let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FollowNotificationTableViewCell.identifier, for: indexPath) as? FollowNotificationTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        case .like(let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LikeNotificationTableViewCell.identifier, for: indexPath) as? LikeNotificationTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        case .comment(let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentNotificationTableViewCell.identifier, for: indexPath) as? CommentNotificationTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellType = viewModels[indexPath.row]
        let username: String
        switch cellType {
        case .follow(let viewModel):
            username = viewModel.username
        case .like(let viewModel):
            username = viewModel.username
        case .comment(let viewModel):
            username = viewModel.username
        }
        #warning("Update func to use username -below for email-")
        
        DatabaseManager.shared.findUser(with: username) {
            [weak self] user in
            guard let user else { return }
            DispatchQueue.main.async {
                let vc = ProfileViewController(user: user)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension NotificationsViewController: FollowNotificationTableViewCellDelegate {
    func followNotificationTableViewCell(
        _ cell: FollowNotificationTableViewCell,
        didTapButton newState: Bool,
        viewModel: FollowNotificationCellViewModel
    ) {
        let username = viewModel.username
//        DatabaseManager.shared.updateRleaitonship(state: isFollowing ? .follow : .unfollow, for: username) {
//            success in
//
//        }
    }
}

extension NotificationsViewController: LikeNotificationTableViewCellDelegate {
    func likeNotificationTableViewCell(
        _ cell: LikeNotificationTableViewCell,
        didTapPostWith viewModel: LikeNotificationCellViewModel
    ) {
        guard let index = viewModels.firstIndex(where: {
            switch $0 {
            case .follow, .comment:
                return false
            case .like(let current):
                return current == viewModel
            }
        }) else { return }
        openPost(with: index, username: viewModel.username)
    }
}

extension NotificationsViewController: CommentNotificationTableViewCellDelegate {
    func commentNotificationTableViewCell(
        _ cell: CommentNotificationTableViewCell,
        didTapCommentWith viewModel: CommentNotificationCellViewModel
    ) {
        guard let index = viewModels.firstIndex(where: {
            switch $0 {
            case .follow, .like:
                return false
            case .comment(let current):
                return current == viewModel
            }
        }) else { return }
        openPost(with: index, username: viewModel.username)
    }
}

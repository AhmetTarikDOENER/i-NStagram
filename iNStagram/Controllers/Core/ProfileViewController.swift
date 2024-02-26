//
//  ProfileViewController.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 17.02.2024.
//

import UIKit

class ProfileViewController: UIViewController {

    private let user: User
    
    private var isCurrentUser: Bool {
        user.username.lowercased() == UserDefaults.standard.string(forKey: "username")?.lowercased() ?? ""
    }
    
    private var collectionView: UICollectionView?
    private var headerViewModel: ProfileHeaderViewModel?
    private var posts: [Post] = []
    private var observer: NSObjectProtocol?
    
    //MARK: - Init
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = user.username.uppercased()
        view.backgroundColor = .systemBackground
        configureNavBar()
        configureCollectionView()
        fetchProfileInfo()
        if isCurrentUser {
            observer = NotificationCenter.default.addObserver(
                forName: .didPostNotification,
                object: nil,
                queue: .main,
                using: {
                    [weak self] _ in
                    self?.posts.removeAll()
                    self?.fetchProfileInfo()
                }
            )
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    private func configureNavBar() {
        if isCurrentUser {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "gear"),
                style: .done,
                target: self,
                action: #selector(didTapSettings)
            )
        }
    }
    
    private func fetchProfileInfo() {
        let username = user.username
        let group = DispatchGroup()
        // Fetch Posts
        group.enter()
        DatabaseManager.shared.getPosts(for: username) {
            [weak self] result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let posts):
                self?.posts = posts
            case .failure(let error):
                break
            }
        }
        // Fetch profile header Info
        var profilePictureURL: URL?
        var buttonType: ProfileButtonType = .edit
        var followers = 0
        var followings = 0
        var posts = 0
        var name: String?
        var bio: String?
        
        // Counts -> 3
        group.enter()
        DatabaseManager.shared.getUserCounts(username: user.username) {
            result in
            defer {
                group.leave()
            }
            posts = result.posts
            followers = result.followers
            followings = result.following
        }
        // Bio, name
        DatabaseManager.shared.getUserInfo(username: user.username) {
            userInfo in
            name = userInfo?.name ?? ""
            bio = userInfo?.bio ?? ""
        }
        
        // Profile Picture URL
        group.enter()
        StorageManager.shared.profilePictureURL(for: user.username) {
            url in
            defer {
                group.leave()
            }
            profilePictureURL = url
        }
        // if not current user get follow state
        if !isCurrentUser {
            // Get follow state
            group.enter()
            DatabaseManager.shared.isFollowing(targetUsername: user.username) {
                isFollowing in
                defer {
                    group.leave()
                }
                buttonType = .follow(isFollowing: isFollowing)
            }
        }
        group.notify(queue: .main) {
            self.headerViewModel = ProfileHeaderViewModel(
                profilePictureURL: profilePictureURL,
                followerCount: followers,
                followingCount: followings,
                postCount: posts,
                buttonType: buttonType,
                bio: bio,
                name: name
            )
            self.collectionView?.reloadData()
        }
    }
    
    @objc private func didTapSettings() {
        let vc = SettingsViewController()
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

extension ProfileViewController {
    private func configureCollectionView() {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(
                sectionProvider: {
                    index,
                    _ -> NSCollectionLayoutSection? in
                    let item = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .fractionalHeight(1.0)
                        )
                    )
                    item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
                    let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .fractionalWidth(0.33)
                        ),
                        subitem: item,
                        count: 3
                    )
                    let section = NSCollectionLayoutSection(group: group)
                    section.boundarySupplementaryItems = [
                        NSCollectionLayoutBoundarySupplementaryItem(
                            layoutSize: NSCollectionLayoutSize(
                                widthDimension: .fractionalWidth(1.0),
                                heightDimension: .fractionalWidth(0.66)
                            ),
                            elementKind: UICollectionView.elementKindSectionHeader,
                            alignment: .top
                        )
                    ]
                    return section
                }
            )
        )
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        collectionView.register(
            ProfileHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier
        )
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        self.collectionView = collectionView
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: URL(string: posts[indexPath.row].postURLString))
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier,
                for: indexPath
              ) as? ProfileHeaderCollectionReusableView else { fatalError() }
        if let viewModel = headerViewModel {
            headerView.configure(with: viewModel)
            headerView.countContainerView.delegate = self
        }
        headerView.delegate = self
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let post = posts[indexPath.row]
        let vc = PostViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - ProfileHeaderCollectionReusableViewDelegate
extension ProfileViewController: ProfileHeaderCollectionReusableViewDelegate {
    func profileHeaderCollectionReusableViewDidTapProfilePicture(_ header: ProfileHeaderCollectionReusableView) {
        guard isCurrentUser else { return }
        let actionSheet = UIAlertController(
            title: "Change Picture",
            message: "Update your photo to reflect your best self.",
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
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let avatar = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        StorageManager.shared.uploadProfilePicture(
            username: user.username,
            data: avatar.pngData()
        ) { 
            [weak self] success in
            if success {
                self?.headerViewModel = nil
                self?.posts = []
                self?.fetchProfileInfo()
            }
        }
    }
}

//MARK: - ProfileHeaderCountViewDelegate
extension ProfileViewController: ProfileHeaderCountViewDelegate {
    func profileHeaderCollectionReusableViewDidTapFollowers(_ containerView: ProfileHeaderCountView) {
        let vc = ListViewController(type: .followers(user: user))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func profileHeaderCollectionReusableViewDidTapFollowing(_ containerView: ProfileHeaderCountView) {
        let vc = ListViewController(type: .following(user: user))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func profileHeaderCollectionReusableViewDidTapPosts(_ containerView: ProfileHeaderCountView) {
        guard posts.count >= 18 else { return }
        collectionView?.setContentOffset(
            CGPoint(
                x: 0,
                y: view.width * 0.45
            ),
            animated: true
        )
    }
    
    func profileHeaderCollectionReusableViewDidTapEditProfile(_ containerView: ProfileHeaderCountView) {
        let vc = EditProfileViewController()
        vc.completion = {
            [weak self] in
            self?.headerViewModel = nil
            self?.fetchProfileInfo()
            // Refetch header info
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    func profileHeaderCollectionReusableViewDidTapFollow(_ containerView: ProfileHeaderCountView) {
        DatabaseManager.shared.updateRelationship(state: .follow, for: user.username) {
            [weak self] success in
            if !success {
                print("Failed to follow")
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                }
            }
        }
    }
    
    func profileHeaderCollectionReusableViewDidTapUnFollow(_ containerView: ProfileHeaderCountView) {
        DatabaseManager.shared.updateRelationship(state: .unfollow, for: user.username) {
            [weak self] success in
            if !success {
                print("Failed to follow")
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                }
            }
        }
    }
}

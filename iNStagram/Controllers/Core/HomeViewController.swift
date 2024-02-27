//
//  ViewController.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 17.02.2024.
//

import UIKit

class HomeViewController: UIViewController {
    
    private var collectionView: UICollectionView?
    private var observer: NSObjectProtocol?
    private var allPosts: [(posts: Post, owner: String)] = []
    private var viewModels = [[HomeFeedCellType]]()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "i-NStagram"
        view.backgroundColor = .systemBackground
        configureCollectionView()
        fetchPosts()
        observer = NotificationCenter.default.addObserver(
            forName: .didPostNotification,
            object: nil,
            queue: .main,
            using: {
                [weak self] _ in
                self?.viewModels.removeAll()
                self?.fetchPosts()
            }
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    //MARK: - Private
    private func fetchPosts() {
        guard let username = UserDefaults.standard.string(forKey: "username") else { return }
        let userGroup = DispatchGroup()
        userGroup.enter()
        var allPosts: [(posts: Post, owner: String)] = []
        DatabaseManager.shared.getFollowings(for: username) {
            usernames in
            defer {
                userGroup.leave()
            }
            let users = usernames + [username]
            for currentUsername in users {
                userGroup.enter()
                DatabaseManager.shared.getPosts(for: currentUsername) {
                    result in
                    DispatchQueue.main.async {
                        defer {
                            userGroup.leave()
                        }
                        switch result {
                        case .success(let posts):
                            allPosts.append(contentsOf: posts.compactMap({
                                (posts: $0, owner: currentUsername)
                            }))
                        case .failure:
                            break
                        }
                    }
                }
            }
        }
        userGroup.notify(queue: .main) {
            let group = DispatchGroup()
            self.allPosts = allPosts
            allPosts.forEach {
                model in
                group.enter()
                self.createViewModel(
                    model: model.posts,
                    username: model.owner) {
                        success in
                        defer {
                            group.leave()
                        }
                        if !success { print("failed to create viewmodel") }
                    }
            }
            group.notify(queue: .main) {
                self.sortData()
                self.collectionView?.reloadData()
            }
        }
    }
    
    private func sortData() {
        allPosts = allPosts.sorted(by: {
            first, second in
            let date1 = first.posts.date
            let date2 = second.posts.date
            return date1 > date2
        })
        viewModels = viewModels.sorted(by: {
            first, second in
            var date1: Date?
            var date2: Date?
            first.forEach {
                type in
                switch type {
                case .timestamp(let vm):
                    date1 = vm.date
                default:
                    break
                }
            }
            second.forEach {
                type in
                switch type {
                case .timestamp(let vm):
                    date2 = vm.date
                default:
                    break
                }
            }
            if let date1 = date1, let date2 = date2 {
                return date1 > date2
            }
            return false
        })
    }
    
    private func createViewModel(
        model: Post,
        username: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
        StorageManager.shared.profilePictureURL(for: username) {
            [weak self] profilePictureURL in
            guard let postUrl = URL(string: model.postURLString),
                  let profilePhotoURL = profilePictureURL else { return }
            let isLiked = model.likers.contains(currentUsername)
            let postData: [HomeFeedCellType] = [
                .poster(
                    viewModel: .init(
                        username: username,
                        profilePictureURL: profilePhotoURL
                    )
                ),
                .post(viewModel: .init(postURL: postUrl)),
                .action(viewModel: .init(isLiked: isLiked)),
                .likeCount(viewModel: .init(likers: model.likers)),
                .caption(
                    viewModel: .init(
                        username: username,
                        caption: model.caption
                    )
                ),
                .timestamp(viewModel: .init(date: DateFormatter.formatter.date(from: model.postedDate) ?? Date()))
            ]
            self?.viewModels.append(postData)
            completion(true)
        }
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModels[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = viewModels[indexPath.section][indexPath.row]
        switch cellType {
        case .poster(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterCollectionViewCell.identifier, for: indexPath) as? PosterCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel, index: indexPath.section)
            return cell
        case .post(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel, index: indexPath.section)
            return cell
        case .action(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostActionsCollectionViewCell.identifier, for: indexPath) as? PostActionsCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel, index: indexPath.section)
            return cell
        case .likeCount(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostLikesCollectionViewCell.identifier, for: indexPath) as? PostLikesCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel, index: indexPath.section)
            return cell
        case .caption(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCaptionCollectionViewCell.identifier, for: indexPath) as? PostCaptionCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel)
            return cell
        case .timestamp(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostDateTimeCollectionViewCell.identifier, for: indexPath) as? PostDateTimeCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
        }
    }
}

extension HomeViewController {
    private func configureCollectionView() {
        let sectionHeight: CGFloat = 240 + view.width
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: {
                index,
                _ -> NSCollectionLayoutSection? in
                // Items
                let posterItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(60)
                    )
                )
                let postItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalWidth(1.0)
                    )
                )
                let actionsItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(40)
                    )
                )
                let likeCountItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(40)
                    )
                )
                let captionItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(60)
                    )
                )
                let timestampsItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(40)
                    )
                )
                // Group
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(sectionHeight)
                    ),
                    subitems: [
                        posterItem, postItem, actionsItem, likeCountItem, captionItem, timestampsItem
                    ]
                )
                // Sections
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 3,
                    leading: 0,
                    bottom: 15,
                    trailing: 0
                )
                return section
            })
        )
        view.addSubviews(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            PosterCollectionViewCell.self,
            forCellWithReuseIdentifier: PosterCollectionViewCell.identifier
        )
        collectionView.register(
            PosterCollectionViewCell.self,
            forCellWithReuseIdentifier: PosterCollectionViewCell.identifier
        )
        collectionView.register(
            PostCollectionViewCell.self,
            forCellWithReuseIdentifier: PostCollectionViewCell.identifier
        )
        collectionView.register(
            PostActionsCollectionViewCell.self,
            forCellWithReuseIdentifier: PostActionsCollectionViewCell.identifier
        )
        collectionView.register(
            PostLikesCollectionViewCell.self,
            forCellWithReuseIdentifier: PostLikesCollectionViewCell.identifier
        )
        collectionView.register(
            PostCaptionCollectionViewCell.self,
            forCellWithReuseIdentifier: PostCaptionCollectionViewCell.identifier
        )
        collectionView.register(
            PostDateTimeCollectionViewCell.self,
            forCellWithReuseIdentifier: PostDateTimeCollectionViewCell.identifier
        )
        self.collectionView = collectionView
    }
}

//MARK: - PosterCollectionViewCellDelegate
extension HomeViewController: PosterCollectionViewCellDelegate {
    func posterCollectionViewCellDidTapMore(_ cell: PosterCollectionViewCell, index: Int) {
        let actionSheet = UIAlertController(
            title: "Post Actions",
            message: nil,
            preferredStyle: .actionSheet
        )
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Share Post", style: .default, handler: {
            [weak self] _ in
            let section = self?.viewModels[index] ?? []
            section.forEach {
                cellType in
                switch cellType {
                case .post(let viewModel):
                    let vc = UIActivityViewController(
                        activityItems: ["Check out this post.", viewModel.postURL],
                        applicationActivities: []
                    )
                    self?.present(vc, animated: true)
                default:
                    break
                }
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: {
            _ in
            
        }))
        present(actionSheet, animated: true)
    }
    
    func posterCollectionViewCellDidTapUsername(_ cell: PosterCollectionViewCell) {
        let vc = ProfileViewController(user: User(username: "ahmettarik", email: "ahmettarik@gmail.com"))
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - PostCollectionViewCellDelegate
extension HomeViewController: PostCollectionViewCellDelegate {
    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell, index: Int) {
        let tuple = allPosts[index]
        DatabaseManager.shared.updateLikeState(
            state: .like,
            postID: tuple.posts.id,
            owner: tuple.owner
        ) {
            success in
            guard success else {
                print("Failed to like")
                return
            }
        }
    }
}

extension HomeViewController: PostActionsCollectionViewCellDelegate {
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool, index: Int) {
        let tuple = allPosts[index]
        DatabaseManager.shared.updateLikeState(
            state: isLiked ? .like: .unlike,
            postID: tuple.posts.id,
            owner: tuple.owner
        ) {
            success in
            guard success else {
                return
            }
        }
    }
    
    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell, index: Int) {
        let tuple = allPosts[index]
        let vc = PostViewController(post: tuple.posts, owner: tuple.owner)
        vc.title = "Post"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func postActionsCollectionViewCellDidTapShare(_ cell: PostActionsCollectionViewCell, index: Int) {
        let section = viewModels[index]
        section.forEach {
            cellType in
            switch cellType {
            case .post(let viewModel):
                let vc = UIActivityViewController(
                    activityItems: ["Check out this post.", viewModel.postURL],
                    applicationActivities: []
                )
                present(vc, animated: true)
            default:
                break
            }
        }
    }
}
//MARK: - PostLikesCollectionViewCellDelegate
extension HomeViewController: PostLikesCollectionViewCellDelegate {
    func postLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell, index: Int) {
        let vc = ListViewController(type: .likers(username: allPosts[index].posts.likers))
        vc.title = "Liked By"
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - PostCaptionCollectionViewCellDelegate
extension HomeViewController: PostCaptionCollectionViewCellDelegate {
    func postCaptionCollectionViewCellDidTapCaption(_ cell: PostCaptionCollectionViewCell) {
        print("Tapped on caption")
    }
}

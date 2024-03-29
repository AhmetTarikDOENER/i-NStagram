//
//  PostViewController.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 17.02.2024.
//

import UIKit

class PostViewController: UIViewController {

    private let post: Post
    private let owner: String
    private var collectionView: UICollectionView?
    private var viewModels = [SinglePostCellType]()
    private let commentBarView = CommentBarView()
    private var observer: NSObjectProtocol?
    private var hideObserver: NSObjectProtocol?
    
    //MARK: - Init
    init(post: Post, owner: String) {
        self.owner = owner
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Post"
        view.backgroundColor = .systemBackground
        configureCollectionView()
        view.addSubview(commentBarView)
        commentBarView.delegate = self
        fetchPost()
        observeKeyboardFrameChange()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
        commentBarView.frame = CGRect(
            x: 0,
            y: view.height - view.safeAreaInsets.bottom - 80,
            width: view.width,
            height: 70
        )
    }
    
    //MARK: - Private
    private func fetchPost() {
        let username = owner
        DatabaseManager.shared.getPost(with: post.id, from: username) {
            [weak self] post in
            guard let post else {  return }
            self?.createViewModel(
                model: post,
                username: username,
                completion: {
                    success in
                    guard success else { return }
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                }
            )
        }
    }
    
    private func createViewModel(
        model: Post,
        username: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
        StorageManager.shared.profilePictureURL(for: username) {
            [weak self] profilePictureURL in
            guard let strongSelf = self,
                  let postUrl = URL(string: model.postURLString),
                  let profilePhotoURL = profilePictureURL else { 
                completion(false)
                return
            }
            let isLiked = model.likers.contains(currentUsername)
            DatabaseManager.shared.getComments(postID: strongSelf.post.id, owner: strongSelf.owner) {
                comments in
                var postData: [SinglePostCellType] = [
                    .poster(
                        viewModel: .init(
                            username: username,
                            profilePictureURL: profilePhotoURL
                        )
                    ),
                    .post(viewModel: .init(postURL: postUrl)),
                    .action(viewModel: .init(isLiked: isLiked)),
                    .likeCount(viewModel: .init(likers: [])),
                    .caption(
                        viewModel: .init(
                            username: username,
                            caption: model.caption
                        )
                    ),
                ]
                if let comment = comments.first {
                    postData.append(
                        .comment(viewModel: comment)
                    )
                }
                postData.append(
                    .timestamp(viewModel: .init(date: DateFormatter.formatter.date(from: model.postedDate) ?? Date()))
                )
                self?.viewModels = postData
                completion(true)
            }
        }
    }
    
    private func observeKeyboardFrameChange() {
        observer = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) {
            notification in
            guard let userInfo = notification.userInfo,
                  let height = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
            UIView.animate(withDuration: 0.1) {
                self.commentBarView.frame = CGRect(
                    x: 0,
                    y: self.view.height - height - 70,
                    width: self.view.width,
                    height: 70
                )
            }
        }
        hideObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) {
            _ in
            UIView.animate(withDuration: 0.1) {
                self.commentBarView.frame = CGRect(
                    x: 0,
                    y: self.view.height - self.view.safeAreaInsets.bottom - 70,
                    width: self.view.width,
                    height: 70
                )
            }
        }
    }
}

//MARK: - CommentBarViewDelegate
extension PostViewController: CommentBarViewDelegate {
    func commentBarViewDidTapSend(_ commentBarView: CommentBarView, withText text: String) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        DatabaseManager.shared.setComments(
            comment: .init(
                username: currentUsername,
                comment: text,
                dateString: .date(from: Date()) ?? ""
            ),
            postID: post.id,
            owner: owner
        ) {
            success in
            DispatchQueue.main.async {
                guard success else { return }
            }
        }
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = viewModels[indexPath.row]
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
        case .comment(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCollectionViewCell.identifier, for: indexPath) as? CommentCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
        }
    }
}

extension PostViewController {
    private func configureCollectionView() {
        let sectionHeight: CGFloat = 300 + view.width
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
                let commentItem = NSCollectionLayoutItem(
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
                        posterItem, postItem, actionsItem, likeCountItem, captionItem,
                        commentItem, timestampsItem
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
        collectionView.register(
            CommentCollectionViewCell.self,
            forCellWithReuseIdentifier: CommentCollectionViewCell.identifier
        )
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        self.collectionView = collectionView
    }
}

//MARK: - PosterCollectionViewCellDelegate
extension PostViewController: PosterCollectionViewCellDelegate {
    func posterCollectionViewCellDidTapMore(_ cell: PosterCollectionViewCell, index: Int) {
        let actionSheet = UIAlertController(
            title: "Post Actions",
            message: nil,
            preferredStyle: .actionSheet
        )
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Share Post", style: .default, handler: {
            [weak self] _ in
            let cellType = self?.viewModels[index]
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
extension PostViewController: PostCollectionViewCellDelegate {
    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell, index: Int) {
        DatabaseManager.shared.updateLikeState(
            state: .like,
            postID: post.id,
            owner: owner
        ) {
            success in
            guard success else {
                return
            }
        }
    }
}

extension PostViewController: PostActionsCollectionViewCellDelegate {
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool, index: Int) {
        DatabaseManager.shared.updateLikeState(
            state: isLiked ? .like: .unlike,
            postID: post.id,
            owner: owner
        ) {
            success in
            guard success else {
                return
            }
        }
    }
    
    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell, index: Int) {
        commentBarView.field.becomeFirstResponder()
    }
    
    func postActionsCollectionViewCellDidTapShare(_ cell: PostActionsCollectionViewCell, index: Int) {
        let cellType = viewModels[index]
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
//MARK: - PostLikesCollectionViewCellDelegate
extension PostViewController: PostLikesCollectionViewCellDelegate {
    func postLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell, index: Int) {
        let vc = ListViewController(type: .likers(username: []))
        vc.title = "Liked By"
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - PostCaptionCollectionViewCellDelegate
extension PostViewController: PostCaptionCollectionViewCellDelegate {
    func postCaptionCollectionViewCellDidTapCaption(_ cell: PostCaptionCollectionViewCell) {
        print("Tapped on caption")
    }
}

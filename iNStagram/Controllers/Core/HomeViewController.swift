//
//  ViewController.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 17.02.2024.
//

import UIKit

class HomeViewController: UIViewController {
    
    private var collectionView: UICollectionView?
    
    private var viewModels = [[HomeFeedCellType]]()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Instagram"
        view.backgroundColor = .systemBackground
        configureCollectionView()
        fetchPosts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    //MARK: - Private
    private func fetchPosts() {
        // mock data
        let postData: [HomeFeedCellType] = [
            .poster(
                viewModel: .init(
                    username: "ahmettarik",
                    profilePictureURL: URL(string: "https://www.apple.com")!
                )
            ),
            .post(viewModel: .init(postURL: URL(string: "https://www.apple.com")!)),
            .action(viewModel: .init(isLiked: true)),
            .likeCount(viewModel: .init(likers: ["ashley"])),
            .caption(
                viewModel: .init(
                    username: "ahmettarik",
                    caption: "This is an awesome first post to shared."
                )
            ),
            .timestamp(viewModel: .init(date: Date()))
        ]
        viewModels.append(postData)
        collectionView?.reloadData()
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
            break
        case .post(let viewModel):
            break
        case .action(let viewModel):
            break
        case .likeCount(let viewModel):
            break
        case .caption(let viewModel):
            break
        case .timestamp(let viewModel):
            break
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let colors = [
            UIColor.red,
            UIColor.green,
            UIColor.blue,
            UIColor.yellow,
            UIColor.systemPink,
            UIColor.orange
        ]
        cell.contentView.backgroundColor = colors[indexPath.row]
        return cell
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
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.collectionView = collectionView
    }
}

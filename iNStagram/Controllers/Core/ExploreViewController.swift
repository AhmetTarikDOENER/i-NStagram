//
//  ExploreViewController.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 17.02.2024.
//

import UIKit

class ExploreViewController: UIViewController {

    private let searchViewController = UISearchController(searchResultsController: SearchResultsViewController())
    private var posts = [(post: Post, user: User)]()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout {
            index, _ -> NSCollectionLayoutSection in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            let fullItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            let oneThirdItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.33),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .fractionalHeight(1.0)
                ),
                subitem: fullItem,
                count: 2
            )
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(160)
                ),
                subitems: [
                    item,
                    verticalGroup
                ]
            )
            let threeItemGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(160)
                ),
                subitem: oneThirdItem,
                count: 3
            )
            let finalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(320)
                ),
                subitems: [
                    horizontalGroup,
                    threeItemGroup
                ]
            )
            
            return NSCollectionLayoutSection(group: finalGroup)
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        
        return collectionView
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Explore"
        view.backgroundColor = .systemBackground
        (searchViewController.searchResultsController as? SearchResultsViewController)?.delegate = self
        searchViewController.searchBar.placeholder = "Search..."
        searchViewController.searchResultsUpdater = self
        navigationItem.searchController = searchViewController
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func fetchData() {
        DatabaseManager.shared.explorePosts {
            [weak self] posts in
            DispatchQueue.main.async {
                self?.posts = posts
                self?.collectionView.reloadData()
            }
        }
    }

}

//MARK: - UISearchResultsUpdating
extension ExploreViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsVC = searchController.searchResultsController as? SearchResultsViewController,
              let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        DatabaseManager.shared.searchUsers(with: query) {
            users in
            DispatchQueue.main.async {
                resultsVC.update(with: users)
            }
        }
    }
}

//MARK: - SearchResultsViewControllerDelegate
extension ExploreViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewController(_ vc: SearchResultsViewController, didSelectResultsWith user: User) {
        let vc = ProfileViewController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ExploreViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
            fatalError()
        }
        let model = posts[indexPath.row]
        cell.configure(with: URL(string: model.post.postURLString))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let model = posts[indexPath.row]
        let vc = PostViewController(post: model.post, owner: model.user.username)
        navigationController?.pushViewController(vc, animated: true)
    }
}

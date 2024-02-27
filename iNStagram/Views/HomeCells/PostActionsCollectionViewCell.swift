//
//  ActionsCollectionViewCell.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 21.02.2024.
//

import UIKit

protocol PostActionsCollectionViewCellDelegate: AnyObject {
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool, index: Int)
    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell, index: Int)
    func postActionsCollectionViewCellDidTapShare(_ cell: PostActionsCollectionViewCell, index: Int)
}

class PostActionsCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PostActionsCollectionViewCell"
    
    weak var delegate: PostActionsCollectionViewCellDelegate?
    
    private var isLiked = false
    private var index = 0
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(
            systemName: "suit.heart",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 45
            )
        )
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(
            systemName: "message",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 45
            )
        )
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(
            systemName: "paperplane",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 45
            )
        )
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubviews(likeButton, commentButton, shareButton)
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size: CGFloat = contentView.height / 1.25
        likeButton.frame = CGRect(
            x: 10,
            y: (contentView.height - size),
            width: size,
            height: size
        )
        commentButton.frame = CGRect(
            x: likeButton.right + 12,
            y: (contentView.height - size),
            width: size,
            height: size
        )
        shareButton.frame = CGRect(
            x: commentButton.right + 12,
            y: (contentView.height - size),
            width: size,
            height: size
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with viewModel: PostActionsCollectionViewCellViewModel, index: Int) {
        self.index = index
        self.isLiked = viewModel.isLiked
        if viewModel.isLiked {
            let image = UIImage(
                systemName: "suit.heart.fill",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 45
                )
            )
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .systemRed
        }
    }
    
    //MARK: - Private
    @objc private func didTapLike() {
        if self.isLiked {
            let image = UIImage(
                systemName: "suit.heart",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 45
                )
            )
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .label
        } else {
            let image = UIImage(
                systemName: "suit.heart.fill",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 45
                )
            )
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .systemRed
        }
        delegate?.postActionsCollectionViewCellDidTapLike(self, isLiked: !isLiked, index: index)
        self.isLiked = !isLiked
    }
    
    @objc private func didTapComment() {
        delegate?.postActionsCollectionViewCellDidTapComment(self, index: index)
    }
    
    @objc private func didTapShare() {
        delegate?.postActionsCollectionViewCellDidTapShare(self, index: index)
    }
}

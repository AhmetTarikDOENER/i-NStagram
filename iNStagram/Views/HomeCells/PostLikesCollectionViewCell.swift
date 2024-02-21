//
//  PostLikesCollectionViewCell.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 21.02.2024.
//

import UIKit

protocol PostLikesCollectionViewCellDelegate: AnyObject {
    func postLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell)
}

class PostLikesCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PostLikesCollectionViewCell"
    
    weak var delegate: PostLikesCollectionViewCellDelegate?
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.isUserInteractionEnabled = true
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(label)
        addTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 10, y: 0, width: contentView.width - 12, height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    func configure(with viewModel: PostLikesCollectionViewCellViewModel) {
        let users = viewModel.likers
        label.text = "\(users.count) Likes"
    }
    
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapLabel))
        label.addGestureRecognizer(tap)
    }
    
    @objc private func didTapLabel() {
        delegate?.postLikesCollectionViewCellDidTapLikeCount(self)
    }
}

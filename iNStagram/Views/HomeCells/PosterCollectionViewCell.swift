//
//  PosterCollectionViewCell.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 21.02.2024.
//

import UIKit
import SDWebImage

protocol PosterCollectionViewCellDelegate: AnyObject {
    func posterCollectionViewCellDidTapMore(_ cell: PosterCollectionViewCell, index: Int)
    func posterCollectionViewCellDidTapUsername(_ cell: PosterCollectionViewCell)
}

class PosterCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PosterCollectionViewCell"
    private var index = 0
    weak var delegate: PosterCollectionViewCellDelegate?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        
        return label
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton()
        let image = UIImage(
            systemName: "ellipsis",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 25,
                weight: .regular
            )
        )
        button.setImage(image, for: .normal)
        button.tintColor = .label
        
        return button
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubviews(imageView, usernameLabel, moreButton)
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        addTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imagePadding: CGFloat = 4
        let imageSize: CGFloat = contentView.height - (imagePadding * 2)
        imageView.frame = CGRect(x: imagePadding, y: imagePadding, width: imageSize, height: imageSize)
        imageView.layer.cornerRadius = imageSize / 2
        usernameLabel.sizeToFit()
        usernameLabel.frame = CGRect(
            x: imageView.right + 10,
            y: 0,
            width: usernameLabel.width,
            height: contentView.height
        )
        moreButton.frame = CGRect(
            x: contentView.width - 55,
            y: (contentView.height - 50) / 2,
            width: 50,
            height: 50
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
        imageView.image = nil
    }
    
    //MARK: - Private
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapUsername))
        usernameLabel.addGestureRecognizer(tap)
        usernameLabel.isUserInteractionEnabled = true
    }
    
    @objc private func didTapUsername() {
        delegate?.posterCollectionViewCellDidTapUsername(self)
    }
    
    @objc private func didTapMore() {
        delegate?.posterCollectionViewCellDidTapMore(self, index: index)
    }
    
    func configure(with viewModel: PosterCollectionViewCellViewModel, index: Int) {
        self.index = index
        usernameLabel.text = viewModel.username
        imageView.sd_setImage(with: viewModel.profilePictureURL)
    }
}

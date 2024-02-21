//
//  PosterCollectionViewCell.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 21.02.2024.
//

import UIKit
import SDWebImage

class PosterCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PosterCollectionViewCell"
    
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
    
    @objc private func didTapMore() {
        
    }
    
    func configure(with viewModel: PosterCollectionViewCellViewModel) {
        usernameLabel.text = viewModel.username
        imageView.sd_setImage(with: viewModel.profilePictureURL)
    }
}

//
//  ProfileHeaderCollectionReusableView.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 25.02.2024.
//

import UIKit

protocol ProfileHeaderCollectionReusableViewDelegate: AnyObject {
    func profileHeaderCollectionReusableViewDidTapProfilePicture(_ header: ProfileHeaderCollectionReusableView)
}

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    
    weak var delegate: ProfileHeaderCollectionReusableViewDelegate?
        
    static let identifier = "ProfileHeaderCollectionReusableView"
    
    public let countContainerView = ProfileHeaderCountView()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        
        return imageView
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.text = "This is awesome instagram clone."
        
        return label
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(countContainerView, imageView, bioLabel)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePicture))
        imageView.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = (width / 3.5)
        imageView.frame = CGRect(
            x: 5,
            y: 5,
            width: imageSize,
            height: imageSize
        )
        imageView.layer.cornerRadius = imageSize / 2
        countContainerView.frame = CGRect(
            x: imageView.right + 5,
            y: 3,
            width: width - imageView.right - 10,
            height: imageSize
        )
        let bioSize = bioLabel.sizeThatFits(
            bounds.size
        )
        bioLabel.frame = CGRect(
            x: 5,
            y: imageView.bottom + 10,
            width: width - 10,
            height: bioSize.height + 50
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        bioLabel.text = nil
    }
    
    @objc private func didTapProfilePicture() {
        delegate?.profileHeaderCollectionReusableViewDidTapProfilePicture(self)
    }
    
    func configure(with viewModel: ProfileHeaderViewModel) {
        imageView.sd_setImage(with: viewModel.profilePictureURL)
        var text = ""
        if let name = viewModel.name {
            text = name + "\n"
        }
        text += viewModel.bio ?? ""
        bioLabel.text = text
        // Container
        let containerViewModel = ProfileHeaderCountViewViewModel(
            followerCount: viewModel.followerCount,
            followingCount: viewModel.followingCount,
            postsCount: viewModel.postCount,
            actionType: viewModel.buttonType
        )
        countContainerView.configure(with: containerViewModel)
    }
}

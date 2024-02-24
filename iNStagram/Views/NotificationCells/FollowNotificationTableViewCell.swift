//
//  FollowNotificationTableViewCell.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 24.02.2024.
//

import UIKit

protocol FollowNotificationTableViewCellDelegate: AnyObject {
    func followNotificationTableViewCell(_ cell: FollowNotificationTableViewCell, didTapButton newState: Bool, viewModel: FollowNotificationCellViewModel)
}

class FollowNotificationTableViewCell: UITableViewCell {

    static let identifier = "FollowNotificationTableViewCell"
    
    weak var delegate: FollowNotificationTableViewCellDelegate?
    
    private var isFollowing = false
    private var viewModel: FollowNotificationCellViewModel?
    
    private let profilePictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18, weight: .regular)
        
        return label
    }()
    
    private let followButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        
        return button
    }()
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        contentView.addSubviews(profilePictureImageView, label, followButton)
        followButton.addTarget(self, action: #selector(didTapFollow), for: .touchUpInside)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height / 1.5
        profilePictureImageView.frame = CGRect(
            x: 10,
            y: (contentView.height - imageSize) / 2,
            width: imageSize,
            height: imageSize
        )
        profilePictureImageView.layer.cornerRadius = imageSize / 2
        followButton.sizeToFit()
        followButton.frame = CGRect(
            x: contentView.width - followButton.width - 24,
            y: (contentView.height - followButton.height) / 2,
            width: followButton.width + 14,
            height: followButton.height
        )
        let labelSize = label.sizeThatFits(
            CGSize(
                width: contentView.width - profilePictureImageView.width - followButton.width - 44,
                height: contentView.height
            )
        )
        label.frame = CGRect(
            x: profilePictureImageView.right + 10,
            y: 0,
            width: labelSize.width,
            height: contentView.height
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        profilePictureImageView.image = nil
        followButton.setTitle(nil, for: .normal)
        followButton.backgroundColor = nil
    }
    
    func configure(with viewModel: FollowNotificationCellViewModel) {
        self.viewModel = viewModel
        label.text = "\(viewModel.username) started following you."
        profilePictureImageView.sd_setImage(with: viewModel.profilePictureURL)
        isFollowing = viewModel.isCurrentUserFollowing
        updateButton()
    }
    
    @objc private func didTapFollow() {
        guard let vm = viewModel else { return }
        delegate?.followNotificationTableViewCell(self, didTapButton: !isFollowing, viewModel: vm)
        self.isFollowing = !isFollowing
        updateButton()
    }
    
    private func updateButton() {
        followButton.setTitle(isFollowing ? "Unfollow" : "Follow", for: .normal)
        followButton.backgroundColor = isFollowing ? .tertiarySystemBackground : .systemBlue
        followButton.setTitleColor(isFollowing ? .label : .white, for: .normal)
        if isFollowing {
            followButton.layer.borderWidth = 0.5
            followButton.layer.borderColor = UIColor.secondaryLabel.cgColor
        }
    }
}

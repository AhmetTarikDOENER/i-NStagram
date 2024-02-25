//
//  ProfileHeaderCountView.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 25.02.2024.
//

import UIKit

protocol ProfileHeaderCountViewDelegate: AnyObject {
    func profileHeaderCollectionReusableViewDidTapFollowers(_ containerView: ProfileHeaderCountView)
    func profileHeaderCollectionReusableViewDidTapFollowing(_ containerView: ProfileHeaderCountView)
    func profileHeaderCollectionReusableViewDidTapPosts(_ containerView: ProfileHeaderCountView)
    func profileHeaderCollectionReusableViewDidTapEditProfile(_ containerView: ProfileHeaderCountView)
    func profileHeaderCollectionReusableViewDidTapFollow(_ containerView: ProfileHeaderCountView)
    func profileHeaderCollectionReusableViewDidTapUnFollow(_ containerView: ProfileHeaderCountView)
}

class ProfileHeaderCountView: UIView {
    
    private var action = ProfileButtonType.edit
    private var isFollowing = false
    
    weak var delegate: ProfileHeaderCountViewDelegate?

    private let followerCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        
        return button
    }()
    
    private let followingCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        
        return button
    }()
    
    private let postCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        
        return button
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton()
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(followerCountButton, actionButton, followingCountButton, postCountButton)
        addActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonWidth: CGFloat = (self.width - 15) / 3
        followerCountButton.frame = CGRect(
            x: 5,
            y: 5,
            width: buttonWidth,
            height: height / 2
        )
        followingCountButton.frame = CGRect(
            x: followerCountButton.right + 5,
            y: 5,
            width: buttonWidth,
            height: height / 2
        )
        postCountButton.frame = CGRect(
            x: followingCountButton.right + 5,
            y: 5,
            width: buttonWidth,
            height: height / 2
        )
        actionButton.frame = CGRect(
            x: 5,
            y: height - 42,
            width: width - 5,
            height: 40
        )
    }
    
    func configure(with viewModel: ProfileHeaderCountViewViewModel) {
        followerCountButton.setTitle("\(viewModel.followerCount)\nFollowers", for: .normal)
        followingCountButton.setTitle("\(viewModel.followingCount)\nFollowings", for: .normal)
        postCountButton.setTitle("\(viewModel.postsCount)\nPosts", for: .normal)
        self.action = viewModel.actionType
        switch viewModel.actionType {
        case .edit:
            actionButton.backgroundColor = .systemBackground
            actionButton.setTitle("Edit Profile", for: .normal)
            actionButton.setTitleColor(.label, for: .normal)
            actionButton.layer.borderWidth = 0.5
            actionButton.layer.borderColor = UIColor.tertiaryLabel.cgColor
        case .follow(let isFollowing):
            self.isFollowing = isFollowing
            updateFollowButton()
        }
    }
    
    private func updateFollowButton() {
        actionButton.backgroundColor = isFollowing ? .systemBackground : .systemBlue
        actionButton.setTitle(isFollowing ? "Unfollow" : "Follow", for: .normal)
        actionButton.setTitleColor(isFollowing ? .label : .white, for: .normal)
        if isFollowing {
            actionButton.layer.borderWidth = 0.5
            actionButton.layer.borderColor = UIColor.tertiaryLabel.cgColor
        } else {
            actionButton.layer.borderWidth = 0
        }
    }
    
    private func addActions() {
        followerCountButton.addTarget(self, action: #selector(didTapFollowers), for: .touchUpInside)
        followingCountButton.addTarget(self, action: #selector(didTapFollowing), for: .touchUpInside)
        postCountButton.addTarget(self, action: #selector(didTapPosts), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }
    
    @objc private func didTapFollowers() {
        delegate?.profileHeaderCollectionReusableViewDidTapFollowers(self)
    }
    
    @objc private func didTapFollowing() {
        delegate?.profileHeaderCollectionReusableViewDidTapFollowing(self)
    }
    
    @objc private func didTapPosts() {
        delegate?.profileHeaderCollectionReusableViewDidTapPosts(self)
    }
    
    @objc private func didTapActionButton() {
        switch action {
        case .edit:
            delegate?.profileHeaderCollectionReusableViewDidTapEditProfile(self)
        case .follow:
            if self.isFollowing {
                // Unf
                delegate?.profileHeaderCollectionReusableViewDidTapUnFollow(self)
            } else {
                delegate?.profileHeaderCollectionReusableViewDidTapFollow(self)
            }
            self.isFollowing = !isFollowing
            updateFollowButton()
        }
    }
}

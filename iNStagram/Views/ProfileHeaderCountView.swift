//
//  ProfileHeaderCountView.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 25.02.2024.
//

import UIKit

class ProfileHeaderCountView: UIView {

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
        
        switch viewModel.actionType {
        case .edit:
            actionButton.backgroundColor = .systemBackground
            actionButton.setTitle("Edit Profile", for: .normal)
            actionButton.setTitleColor(.label, for: .normal)
            actionButton.layer.borderWidth = 0.5
            actionButton.layer.borderColor = UIColor.tertiaryLabel.cgColor
        case .follow(let isFollowing):
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
    }
    
    private func addActions() {
        
    }
}

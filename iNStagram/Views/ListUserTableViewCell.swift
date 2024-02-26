//
//  ListUserTableViewCell.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 26.02.2024.
//

import UIKit
import SDWebImage

class ListUserTableViewCell: UITableViewCell {

    static let identifier = "ListUserTableViewCell"
    
    private let profilePictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 18)
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        contentView.addSubviews(profilePictureImageView, usernameLabel)
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        usernameLabel.sizeToFit()
        let imageSize: CGFloat = (contentView.height / 1.3)
        profilePictureImageView.frame = CGRect(
            x: 5,
            y: (contentView.height - imageSize) / 2,
            width: imageSize,
            height: imageSize
        )
        profilePictureImageView.layer.cornerRadius = imageSize / 2
        usernameLabel.frame = CGRect(
            x: profilePictureImageView.right + 10,
            y: 0,
            width: usernameLabel.width,
            height: contentView.height
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
        profilePictureImageView.image = nil
    }
    
    func configure(with viewModel: ListUserTableViewCellViewModel) {
        usernameLabel.text = viewModel.username
        StorageManager.shared.profilePictureURL(for: viewModel.username) {
            [weak self] url in
            DispatchQueue.main.async {
                self?.profilePictureImageView.sd_setImage(with: url)
            }
        }
    }

}

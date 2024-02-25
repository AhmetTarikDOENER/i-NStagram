//
//  CommentNotificationTableViewCell.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 24.02.2024.
//

import UIKit

protocol CommentNotificationTableViewCellDelegate: AnyObject {
    func commentNotificationTableViewCell(_ cell: CommentNotificationTableViewCell, didTapCommentWith viewModel: CommentNotificationCellViewModel)
}

class CommentNotificationTableViewCell: UITableViewCell {

    static let identifier = "CommentNotificationTableViewCell"
    
    weak var delegate: CommentNotificationTableViewCellDelegate?
    
    private var viewModel: CommentNotificationCellViewModel?

    private let profilePictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18, weight: .regular)
        
        return label
    }()
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        contentView.addSubviews(profilePictureImageView, label, postImageView, dateLabel)
        postImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapComment))
        postImageView.addGestureRecognizer(tap)
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
        let postSize: CGFloat = contentView.height - 6
        postImageView.frame = CGRect(
            x: contentView.width - postSize - 10,
            y: 3,
            width: postSize,
            height: postSize
        )
        let labelSize = label.sizeThatFits(
            CGSize(
                width: contentView.width - profilePictureImageView.right - 25 - postSize,
                height: contentView.height
            )
        )
        dateLabel.sizeToFit()
        label.frame = CGRect(
            x: profilePictureImageView.right + 10,
            y: 0,
            width: labelSize.width,
            height: contentView.height - dateLabel.height - 10
        )
        dateLabel.frame = CGRect(
            x: profilePictureImageView.right + 10,
            y: contentView.height - dateLabel.height - 10,
            width: dateLabel.width,
            height: dateLabel.height
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        profilePictureImageView.image = nil
        postImageView.image = nil
        dateLabel.text = nil
    }
    
    func configure(with viewModel: CommentNotificationCellViewModel) {
        self.viewModel = viewModel
        profilePictureImageView.sd_setImage(with: viewModel.profilePictureURL)
        postImageView.sd_setImage(with: viewModel.postURL)
        label.text = "\(viewModel.username) commented on your post."
        dateLabel.text = viewModel.dateString
    }
    
    @objc private func didTapComment() {
        guard let vm = viewModel else { return }
        delegate?.commentNotificationTableViewCell(self, didTapCommentWith: vm)
    }
}

//
//  CommentCollectionViewCell.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 27.02.2024.
//

import UIKit

class CommentCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CommentCollectionViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        contentView.addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(
            x: 5,
            y: 0,
            width: contentView.width - 10,
            height: contentView.height
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(with model: Comment) {
        label.text = "\(model.username): \(model.comment)"
    }
}

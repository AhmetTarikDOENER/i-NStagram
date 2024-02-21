//
//  PostCaptionCollectionViewCell.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 21.02.2024.
//

import UIKit

class PostCaptionCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PostCaptionCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with viewModel: PostCaptionCollectionViewCellViewModel) {
        
    }
}

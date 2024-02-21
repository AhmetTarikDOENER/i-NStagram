//
//  PostCaptionCollectionViewCell.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 21.02.2024.
//

import UIKit

protocol PostCaptionCollectionViewCellDelegate: AnyObject {
    func postCaptionCollectionViewCellDidTapCaption(_ cell: PostCaptionCollectionViewCell)
}

class PostCaptionCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PostCaptionCollectionViewCell"
    
    weak var delegate: PostCaptionCollectionViewCellDelegate?
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.isUserInteractionEnabled = true
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(label)
        addTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = label.sizeThatFits(contentView.bounds.size)
        label.frame = CGRect(x: 12, y: 3, width: size.width - 12, height: size.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    func configure(with viewModel: PostCaptionCollectionViewCellViewModel) {
        label.text = "\(viewModel.username): \(viewModel.caption ?? "")"
    }
    
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCaption))
        label.addGestureRecognizer(tap)
    }
    
    @objc private func didTapCaption() {
        
    }
}

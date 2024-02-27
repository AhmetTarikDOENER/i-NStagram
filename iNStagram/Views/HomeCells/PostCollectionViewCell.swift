//
//  PostCollectionViewCell.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 21.02.2024.
//

import UIKit
import SDWebImage

protocol PostCollectionViewCellDelegate: AnyObject {
    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell, index: Int)
}

class PostCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PostCollectionViewCell"
    
    weak var delegate: PostCollectionViewCellDelegate?
    
    private var index = 0
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    private let heartImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.image = UIImage(
            systemName: "suit.heart.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 50)
        )
        imageView.tintColor = .white
        imageView.alpha = 0
        
        return imageView
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubviews(imageView, heartImageView)
        addTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
        let size: CGFloat = contentView.width / 5
        heartImageView.frame = CGRect(
            x: (contentView.width - size) / 2,
            y: (contentView.height - size) / 2,
            width: size,
            height: size
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapToLike))
        tap.numberOfTapsRequired = 2
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
    }
    
    @objc private func didDoubleTapToLike() {
        heartImageView.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.heartImageView.alpha = 1.0
        } completion: {
            done in
            if done {
                UIView.animate(withDuration: 0.4) {
                    self.heartImageView.alpha = 0
                } completion: {
                    done in
                    if done {
                        self.heartImageView.isHidden = true
                    }
                }
            }
        }
        delegate?.postCollectionViewCellDidLike(self, index: index)
    }
    
    func configure(with viewModel: PostCollectionViewCellViewModel, index: Int) {
        self.index = index
        imageView.sd_setImage(with: viewModel.postURL)
    }
}

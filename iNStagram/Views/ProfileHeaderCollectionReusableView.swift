//
//  ProfileHeaderCollectionReusableView.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 25.02.2024.
//

import UIKit

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
        
    static let identifier = "ProfileHeaderCollectionReusableView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemPink
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
    
    func configure(with viewModel: ProfileHeaderViewModel) {
        
    }
}

//
//  CommentBarView.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 27.02.2024.
//

import UIKit

protocol CommentBarViewDelegate: AnyObject {
    func commentBarViewDidTapSend(_ commentBarView: CommentBarView, withText text: String)
}

final class CommentBarView: UIView, UITextFieldDelegate {
    
    weak var delegate: CommentBarViewDelegate?

    private let sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.link, for: .normal)
        
        return button
    }()
    
    private let field: iNSTextField = {
        let field = iNSTextField()
        field.placeholder = "Comment"
        field.backgroundColor = .secondarySystemBackground
        
        return field
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubviews(sendButton, field)
        field.delegate = self
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        backgroundColor = .tertiarySystemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sendButton.sizeToFit()
        sendButton.frame = CGRect(
            x: (width - sendButton.width) - 10,
            y: (height - sendButton.height) / 2,
            width: sendButton.width + 4,
            height: sendButton.height
        )
        field.frame = CGRect(
            x: 2,
            y: (height - 50) / 2,
            width: width - sendButton.width - 12,
            height: 50
        )
    }

    @objc private func didTapSend() {
        guard let text = field.text, 
              !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        delegate?.commentBarViewDidTapSend(self, withText: text)
        field.resignFirstResponder()
        field.text = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        field.resignFirstResponder()
        didTapSend()
        return true
    }
}

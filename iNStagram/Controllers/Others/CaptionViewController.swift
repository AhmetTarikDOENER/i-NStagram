//
//  CaptionViewController.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 17.02.2024.
//

import UIKit

class CaptionViewController: UIViewController {

    private let image: UIImage
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.text = "Add Caption..."
        textView.backgroundColor = .secondarySystemBackground
        textView.textContainerInset = UIEdgeInsets(
            top: 3,
            left: 3,
            bottom: 3,
            right: 3
        )
        textView.font = .systemFont(ofSize: 18)
        
        return textView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    //MARK: - Init
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubviews(imageView, textView)
        imageView.image = image
        textView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Post",
            style: .done,
            target: self,
            action: #selector(didTapPost)
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size: CGFloat = view.width / 4
        imageView.frame = CGRect(
            x: (view.width - size) / 2,
            y: view.safeAreaInsets.top + 10,
            width: size,
            height: size
        )
        textView.frame = CGRect(
            x: 20,
            y: imageView.bottom + 20,
            width: view.width - 40,
            height: 100
        )
    }
    
    @objc private func didTapPost() {
        textView.resignFirstResponder()
        var caption = textView.text ?? ""
        if caption == "Add Caption..." {
            caption = ""
        }
        // Generate post id
        guard let newPostID = createNewPostID(), let dateString = String.date(from: Date()) else { return }
        // Upload post
        StorageManager.shared.uploadPost(data: image.pngData(), id: newPostID) {
            newPostDownloadURL in
            guard let url = newPostDownloadURL else { return }
            let newPost = Post(
                id: newPostID,
                caption: caption,
                postedDate: dateString, 
                postURLString: url.absoluteString,
                likers: []
            )
            // Update database
            DatabaseManager.shared.createPost(newPost: newPost) {
                [weak self] finished in
                guard finished else {
                    return
                }
                DispatchQueue.main.async {
                    self?.tabBarController?.tabBar.isHidden = false
                    self?.tabBarController?.selectedIndex = 0
                    self?.navigationController?.popToRootViewController(animated: false)
                    NotificationCenter.default.post(name: .didPostNotification, object: nil)
                }
            }
        }
    }
    
    private func createNewPostID() -> String? {
        let timestamps = Date().timeIntervalSince1970
        let randomNumber = Int.random(in: 0...1000)
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return nil
        }
        
        return "\(username)_\(randomNumber)_\(timestamps)"
    }
}

//MARK: - UITextViewDelegate
extension CaptionViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Add Caption..." {
            textView.text = nil
        }
    }
}

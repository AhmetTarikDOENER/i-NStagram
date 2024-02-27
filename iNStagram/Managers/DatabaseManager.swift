//
//  DatabaseManager.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 17.02.2024.
//

import Foundation
import FirebaseFirestore

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    private init() {}
    
    private let database = Firestore.firestore()
    
    public func searchUsers(
        with usernamePrefix: String,
        completion: @escaping ([User]) -> Void
    ) {
        let reference = database.collection("users")
        reference.getDocuments {
            snapshot, error in
            guard let users = snapshot?.documents.compactMap ({ User(with: $0.data()) }), error == nil else {
                completion([])
                return
            }
            let subset = users.filter {
                $0.username.lowercased().hasPrefix(usernamePrefix.lowercased())
            }
            completion(subset)
        }
    }
    
    public func getPosts(
        for username: String,
        completion: @escaping (Result<[Post], Error>) -> Void
    ) {
        let reference = database.collection("users").document(username).collection("posts")
        reference.getDocuments {
            snapshot, error in
            guard let posts = snapshot?.documents.compactMap({
                Post(with: $0.data())
            }).sorted(by: {
                $0.date > $1.date
            }), error == nil else { return }
            completion(.success(posts))
        }
    }
    
    public func createUser(newUser: User, completion: @escaping (Bool) -> Void) {
        let reference = database.document("users/\(newUser.username)")
        guard let data = newUser.asDictionary() else { return completion(false) }
        reference.setData(data) {
            error in
            completion(error == nil)
        }
    }
    
    public func createPost(newPost: Post, completion: @escaping (Bool) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }
        let docReference = database.document("users/\(username)/posts/\(newPost.id)")
        guard let data = newPost.asDictionary() else {
            completion(false)
            return
        }
        docReference.setData(data) {
            error in
            completion(error == nil)
        }
    }
    
    public func findUser(with email: String, completion: @escaping (User?) -> Void) {
        let reference = database.collection("users")
        reference.getDocuments {
            snapshot, error in
            guard let users = snapshot?.documents.compactMap ({ User(with: $0.data()) }), error == nil else {
                completion(nil)
                return
            }
            let user = users.first(where: { $0.email == email })
            completion(user)
        }
    }
    
    public func findUser(username: String, completion: @escaping (User?) -> Void) {
        let reference = database.collection("users")
        reference.getDocuments {
            snapshot, error in
            guard let users = snapshot?.documents.compactMap ({ User(with: $0.data()) }), error == nil else {
                completion(nil)
                return
            }
            let user = users.first(where: { $0.username == username })
            completion(user)
        }
    }
    
    public func explorePosts(completion: @escaping ([(post: Post, user: User)]) -> Void) {
        let reference = database.collection("users")
        reference.getDocuments {
            snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }), error == nil else {
                completion([])
                return
            }
            let group = DispatchGroup()
            var aggregatePosts = [(post: Post, user: User)]()
            users.forEach {
                user in
                group.enter()
                let username = user.username
                let postsReference = self.database.collection("users/\(username)/posts")
                postsReference.getDocuments {
                    snapshot, error in
                    defer {
                        group.leave()
                    }
                    guard let posts = snapshot?.documents.compactMap({ Post(with: $0.data()) }), error == nil else {
                        return
                    }
                    aggregatePosts.append(contentsOf: posts.compactMap({
                        (post: $0, user: user)
                    }))
                }
            }
            group.notify(queue: .main) {
                completion(aggregatePosts)
            }
        }
    }
    
    public func getNotifications(completion: @escaping ([IGNotification]) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            completion([])
            return
        }
        let reference = database.collection("users").document(username).collection("notifications")
        reference.getDocuments {
            snapshot, error in
            guard let notifications = snapshot?.documents.compactMap({
                IGNotification(with: $0.data())
            }), error == nil else {
                completion([])
                return
            }
            completion(notifications)
        }
    }
    
    public func insertNotification(
        identifier: String,
        data: [String: Any],
        for username: String
    ) {
        let reference = database.collection("users")
            .document(username)
            .collection("notifications").document(identifier)
        reference.setData(data)
    }
    
    public func getPost(
        with identifier: String,
        from username: String,
        completion: @escaping (Post?) -> Void
    ) {
        let reference = database.collection("users")
            .document(username)
            .collection("posts").document(identifier)
        reference.getDocument {
            snapshot, error in
            guard let data = snapshot?.data(),
                  error == nil else {
                completion(nil)
                return
            }
            completion(Post(with: data))
        }
    }
    
    enum RelationshipState {
        case follow
        case unfollow
    }
    
    public func updateRelationship(
        state: RelationshipState,
        for targetUsername: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }
        
        let currentFollowing = database.collection("users")
            .document(currentUsername)
            .collection("followings")
        
        let targetUserFollowers = database.collection("users")
            .document(targetUsername)
            .collection("followers")
        
        switch state {
        case .unfollow:
            // Remove follower from the currentUser following list
            currentFollowing.document(targetUsername).delete()
            // Remove currentUser from targetUser followers list
            targetUserFollowers.document(currentUsername).delete()
            completion(true)
        case .follow:
            // Add follower for requester following list
            currentFollowing.document(targetUsername).setData(["valid" : "1"])
            // Add currentUser to targetUser followers list
            targetUserFollowers.document(currentUsername).setData(["valid" : "1"])
            completion(true)
        }
    }
    
    public func getUserCounts(
        username: String,
        completion: @escaping ((followers: Int, following: Int, posts: Int)) -> Void
    ) {
        let userReference = database.collection("users")
            .document(username)
        var followers = 0
        var following = 0
        var posts = 0
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        userReference.collection("posts").getDocuments {
            snapshot, error in
            defer {
                group.leave()
            }
            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            posts = count
        }
        userReference.collection("followers").getDocuments {
            snapshot, error in
            defer {
                group.leave()
            }
            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            followers = count
        }
        userReference.collection("followings").getDocuments {
            snapshot, error in
            defer {
                group.leave()
            }
            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            following = count
        }
        group.notify(queue: .global()) {
            let results = (followers: followers, following: following, posts: posts)
            completion(results)
        }
    }
    
    public func isFollowing(
        targetUsername: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }
        let reference = database.collection("users")
            .document(targetUsername)
            .collection("followers")
            .document(currentUsername)
        reference.getDocument {
            snapshot, error in
            guard snapshot != nil, error == nil else {
                // Not following
                completion(false)
                return
            }
            // Following
            completion(true)
        }
    }
    
    public func getFollowers(
        for username: String,
        completion: @escaping ([String]) -> Void
    ) {
        let reference = database.collection("users")
            .document(username)
            .collection("followers")
        reference.getDocuments {
            snapshot, error in
            guard let usernames = snapshot?.documents.compactMap({
                $0.documentID
            }), error == nil else {
                completion([])
                return
            }
            completion(usernames)
        }
    }
    
    public func getFollowings(
        for username: String,
        completion: @escaping ([String]) -> Void
    ) {
        let reference = database.collection("users")
            .document(username)
            .collection("followings")
        reference.getDocuments {
            snapshot, error in
            guard let usernames = snapshot?.documents.compactMap({
                $0.documentID
            }), error == nil else {
                completion([])
                return
            }
            completion(usernames)
        }
    }
    
    public func getUserInfo(
        username: String,
        completion: @escaping (UserInfo?) -> Void
    ) {
        let reference = database.collection("users")
            .document(username)
            .collection("information")
            .document("basics")
        reference.getDocument {
            snapshot, error in
            guard let data = snapshot?.data(),
                  let userInfo = UserInfo(with: data) else {
                completion(nil)
                return
            }
            completion(userInfo)
        }
    }
    
    public func setUserInfo(
        userInfo: UserInfo,
        completion: @escaping (Bool) -> Void
    ) {
        guard let username = UserDefaults.standard.string(forKey: "username"),
              let data = userInfo.asDictionary() else {
            completion(false)
            return
        }
        let reference = database.collection("users")
            .document(username)
            .collection("information")
            .document("basics")
        reference.setData(data) {
            error in
            completion(error == nil)
        }
    }
    
    //MARK: - Comment
    public func getComments(
        postID: String,
        owner: String,
        completion: @escaping ([Comment]) -> Void
    ) {
        let reference = database.collection("users")
            .document(owner)
            .collection("posts")
            .document(postID)
            .collection("comments")
        reference.getDocuments {
            snapshot, error in
            guard let comments = snapshot?.documents.compactMap({
                Comment(with: $0.data())
            }),error == nil else {
                completion([])
                return
            }
            completion(comments)
        }
    }
    
    public func setComments(
        comment: Comment,
        postID: String,
        owner: String,
        completion: @escaping (Bool) -> Void
    ) {
        let newIdentifier = "\(postID)_\(comment.username)_\(Date().timeIntervalSince1970)_\(Int.random(in: 0...1000))"
        let reference = database.collection("users")
            .document(owner)
            .collection("posts")
            .document(postID)
            .collection("comments")
            .document(newIdentifier)
        guard let data = comment.asDictionary() else { return }
        reference.setData(data) {
            error in
            completion(error == nil)
        }
    }
}

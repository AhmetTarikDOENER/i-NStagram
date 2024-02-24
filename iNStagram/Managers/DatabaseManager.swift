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
    
    public func explorePosts(completion: @escaping ([Post]) -> Void) {
        let reference = database.collection("users")
        reference.getDocuments {
            snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }), error == nil else {
                completion([])
                return
            }
            let group = DispatchGroup()
            var aggregatePosts = [Post]()
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
                    aggregatePosts.append(contentsOf: posts)
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
}

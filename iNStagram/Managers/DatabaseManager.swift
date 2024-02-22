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
    
    let database = Firestore.firestore()
    
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
            guard let users = snapshot?.documents.compactMap { User(with: $0.data()) }, error == nil else {
                completion(nil)
                return
            }
            let user = users.first(where: { $0.email == email })
            completion(user)
        }
    }
}

//
//  AuthManager.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 17.02.2024.
//

import Foundation
import FirebaseAuth

final class AuthManager {
    
    static let shared = AuthManager()
    private init() {}
    
    let auth = Auth.auth()
    
    enum AuthError: Error {
        case newUserCreation
        case signedInFailed
    }
    
    public var isSignedIn: Bool {
        auth.currentUser != nil
    }
    
    public func signIn(
        email: String,
        password: String,
        completion: @escaping (Result<User, AuthError>) -> Void
    ) {
        DatabaseManager.shared.findUser(with: email) {
            [weak self] user in
            guard let user = user else {
                completion(.failure(.signedInFailed))
                return
            }
            
            self?.auth.signIn(withEmail: email, password: password) {
                result, error in
                guard result != nil, error == nil else {
                    completion(.failure(.signedInFailed))
                    return
                }
                UserDefaults.standard.setValue(user.username, forKey: "username")
                UserDefaults.standard.setValue(user.email, forKey: "email")
                completion(.success(user))
            }
        }
    }
    
    public func signUp(
        email: String,
        username: String,
        password: String,
        profilePictureData: Data?,
        completion: @escaping (Result<User, AuthError>) -> Void
    ) {
        let newUser = User(username: username, email: email)
        // Create account
        auth.createUser(withEmail: email, password: password) {
            result, error in
            guard result != nil, error == nil else {
                completion(.failure(.newUserCreation))
                return
            }
            DatabaseManager.shared.createUser(newUser: newUser) {
                success in
                if success {
                    StorageManager.shared.uploadProfilePicture(
                        username: username,
                        data: profilePictureData
                    ) {
                        uploadSuccess in
                        if uploadSuccess {
                            completion(.success(newUser))
                        } else {
                            completion(.failure(.newUserCreation))
                        }
                    }
                } else {
                    completion(.failure(.newUserCreation))
                }
            }
        }
    }
    
    public func signOut(completion: @escaping (Bool) -> Void) {
        do {
            try auth.signOut()
            completion(true)
        } catch {
            print(error.localizedDescription)
            completion(false)
        }
    }
}

//
//  StorageManager.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 17.02.2024.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    private init() {}
    
    private let storage = Storage.storage().reference()
    
    public func uploadProfilePicture(
        username: String,
        data: Data?,
        completion: @escaping (Bool) -> Void
    ) {
        guard let data else { return }
        storage.child("\(username)/profile_picture.png").putData(
            data,
            metadata: nil
        ) {
            _, error in
            completion(error == nil)
        }
    }
}

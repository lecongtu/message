//
//  StorageManager.swift
//  MessengerApp
//
//  Created by Lê Công Tú on 18/09/2021.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion){
        storage.child("image/\(fileName)").putData(data, metadata: nil, completion: {metadata, error in
            guard error == nil else {
                print("failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("image/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else{
                    print("Failed to get dowload url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("dowload url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion){
        storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard error == nil else {
                print("failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else{
                    print("Failed to get dowload url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("dowload url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    public func uploadMessageVideo(with fileUrl: URL, fileName: String, completion: @escaping UploadPictureCompletion) {
        let videoURL: String = fileUrl.absoluteString
        let localFile = URL(string: videoURL)!
        
        storage.child("message_videos/\(fileName)").putFile(from: localFile, metadata: nil, completion: { [weak self] metadata, error in
            guard error == nil else {
                // failed
                print("failed to upload video file to firebase for picture")
                print("file name la: \(fileUrl)")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }

            self?.storage.child("message_videos/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }

                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    public func dowloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void){
        let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else{
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            
            completion(.success(url))
        })
    }
    
}

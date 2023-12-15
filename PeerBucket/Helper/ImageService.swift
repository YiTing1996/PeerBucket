//
//  ImageService.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2023/12/15.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class ImageService {
    
    static let shared = ImageService()
    
    private init() {}
    
    private let storage = Storage.storage().reference()
  
    public enum ImageType: String {
        case home = "homeImage"
        case avatar = "avatar"
        case list = "listImage"
        case category = "categoryImage"
    }
    
    func uploadImage(type: ImageType, data: Data, completion: @escaping (String) -> Void) {
        let imageName = (Info.shared.currentUser?.userID ?? "") + "_" + NSUUID().uuidString
        let path = "\(type.rawValue)/\(imageName).png"
        storage.child(path).putData(data, metadata: nil) { _, error in
            guard error == nil else {
                Log.e(error)
                completion("")
                return
            }
            self.downloadImage(from: path) {
                completion($0)
            }
        }
    }
    
    func downloadImage(from path: String, completion: @escaping (String) -> Void) {
        storage.child(path).downloadURL { url, error in
            guard let url = url, error == nil else {
                Log.e(error)
                completion("")
                return
            }
            let urlString = url.absoluteString
            UserDefaults.standard.set(urlString, forKey: "url")
            completion(urlString)
        }
    }
}

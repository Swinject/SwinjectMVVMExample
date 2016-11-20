//
//  ImageEntity.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/21/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import Himotoki

public struct ImageEntity {
    public let id: UInt64
    
    public let pageURL: String
    public let pageImageWidth: Int
    public let pageImageHeight: Int
    
    public let previewURL: String
    public let previewWidth: Int
    public let previewHeight: Int
    
    public let imageURL: String
    public let imageWidth: Int
    public let imageHeight: Int
    
    public let viewCount: Int64
    public let downloadCount: Int64
    public let likeCount: Int64
    public let tags: [String]
    public let username: String
}

// MARK: Decodable
extension ImageEntity: Decodable {
    public static func decode(_ e: Extractor) throws -> ImageEntity {
        let splitCSV: (String) -> [String] = { csv in
            csv.characters
                .split { $0 == "," }
                .map { String($0).trimmingCharacters(in: .whitespaces) }
        }
        
        return try ImageEntity(
            id: e <| "id",
            
            pageURL: e <| "pageURL",
            pageImageWidth: e <| "imageWidth",
            pageImageHeight: e <| "imageHeight",
            
            previewURL: e <| "previewURL",
            previewWidth: e <| "previewWidth",
            previewHeight: e <| "previewHeight",
            
            imageURL: e <| "webformatURL",
            imageWidth: e <| "webformatWidth",
            imageHeight: e <| "webformatHeight",
            
            viewCount: e <| "views",
            downloadCount: e <| "downloads",
            likeCount: e <| "likes",
            tags: (try? e <| "tags").map(splitCSV) ?? [],
            username: e <| "user"
        )
    }
}

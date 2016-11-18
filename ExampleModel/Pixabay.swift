//
//  Pixabay.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

internal struct Pixabay {
    internal static let apiURL = "https://pixabay.com/api/"
    internal static let maxImagesPerPage = 50
    
    internal static var requestParameters: [String: Any] {
        return [
            "key": Config.apiKey,
            "image_type": "photo",
            "safesearch": true,
            "per_page": maxImagesPerPage,
            "page": 1 // Starts with 1.
        ]
    }
    
    internal static func incrementPage(_ parameters: [String: Any]) -> [String: Any] {
        let currentPage = parameters["page"] as? Int ?? 0
        var modifiedParameters = parameters
        modifiedParameters["page"] = currentPage + 1
        return modifiedParameters
    }
}

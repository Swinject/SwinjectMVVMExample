//
//  ImageSearchTableViewCellModel.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import ExampleModel

public final class ImageSearchTableViewCellModel: ImageSearchTableViewCellModeling {
    public let id: UInt64
    public let previewURL: String
    public let pageImageSizeText: String
    public let tagText: String
    
    internal init(image: ImageEntity) {
        id = image.id
        previewURL = image.previewURL
        pageImageSizeText = "\(image.pageImageWidth) x \(image.pageImageHeight)"
        tagText = ", ".join(image.tags)
    }
}

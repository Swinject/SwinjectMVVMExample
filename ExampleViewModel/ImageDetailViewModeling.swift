//
//  ImageDetailViewModeling.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/24/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import ReactiveCocoa
import ExampleModel

public protocol ImageDetailViewModeling {
    var id: PropertyOf<UInt64?> { get }
    var pageImageSizeText: PropertyOf<String?> { get }
    var tagText: PropertyOf<String?> { get }
    var usernameText: PropertyOf<String?> { get }
    var viewCountText: PropertyOf<String?> { get }
    var downloadCountText: PropertyOf<String?> { get }
    var likeCountText: PropertyOf<String?> { get }
    var image: PropertyOf<UIImage?> { get }
    
    func openImagePage()
}

public protocol ImageDetailViewModelModifiable: ImageDetailViewModeling {
    func update(imageEntities: [ImageEntity], atIndex index: Int)
}

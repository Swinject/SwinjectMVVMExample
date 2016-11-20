//
//  ImageDetailViewModeling.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/24/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import ReactiveSwift
import ExampleModel

public protocol ImageDetailViewModeling {
    var id: Property<UInt64?> { get }
    var pageImageSizeText: Property<String?> { get }
    var tagText: Property<String?> { get }
    var usernameText: Property<String?> { get }
    var viewCountText: Property<String?> { get }
    var downloadCountText: Property<String?> { get }
    var likeCountText: Property<String?> { get }
    var image: Property<UIImage?> { get }
    
    func openImagePage()
}

public protocol ImageDetailViewModelModifiable: ImageDetailViewModeling {
    func update(_ imageEntities: [ImageEntity], atIndex index: Int)
}

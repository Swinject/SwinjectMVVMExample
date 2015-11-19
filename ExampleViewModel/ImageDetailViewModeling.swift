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
    var id: AnyProperty<UInt64?> { get }
    var pageImageSizeText: AnyProperty<String?> { get }
    var tagText: AnyProperty<String?> { get }
    var usernameText: AnyProperty<String?> { get }
    var viewCountText: AnyProperty<String?> { get }
    var downloadCountText: AnyProperty<String?> { get }
    var likeCountText: AnyProperty<String?> { get }
    var image: AnyProperty<UIImage?> { get }
    
    func openImagePage()
}

public protocol ImageDetailViewModelModifiable: ImageDetailViewModeling {
    func update(imageEntities: [ImageEntity], atIndex index: Int)
}

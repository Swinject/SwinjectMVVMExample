//
//  ImageDetailViewModel.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/24/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import ReactiveCocoa
import ExampleModel

public final class ImageDetailViewModel: ImageDetailViewModeling {
    public var id: PropertyOf<UInt64?> { return PropertyOf(_id) }
    public var pageImageSizeText: PropertyOf<String?> { return PropertyOf(_pageImageSizeText) }
    public var tagText: PropertyOf<String?> { return PropertyOf(_tagText) }
    public var usernameText: PropertyOf<String?> { return PropertyOf(_usernameText) }
    public var image: PropertyOf<UIImage?> { return PropertyOf(_image) }
    
    private let _id = MutableProperty<UInt64?>(nil)
    private let _pageImageSizeText = MutableProperty<String?>(nil)
    private let _tagText = MutableProperty<String?>(nil)
    private let _usernameText = MutableProperty<String?>(nil)
    private let _image = MutableProperty<UIImage?>(nil)
    
    private var imageEntities = [ImageEntity]()
    private var (stopSignalProducer, stopSignalObserver) = SignalProducer<(), NoError>.buffer()
    
    private let network: Networking

    public init(network: Networking) {
        self.network = network
    }
}

extension ImageDetailViewModel: ImageDetailViewModelModifiable {
    public func update(imageEntities: [ImageEntity], atIndex index: Int) {
        sendNext(stopSignalObserver, ())
        (stopSignalProducer, stopSignalObserver) = SignalProducer<(), NoError>.buffer()
        
        let imageEntity: ImageEntity? = imageEntities.indices.contains(index) ? imageEntities[index] : nil
        self._id.value = imageEntity?.id
        self._usernameText.value = imageEntity?.username
        self._pageImageSizeText.value = imageEntity.map { "\($0.pageImageWidth) x \($0.pageImageHeight)" }
        self._tagText.value = imageEntity.map { ", ".join($0.tags) }
        
        _image.value = nil
        if let imageEntity = imageEntity {
            _image <~ network.requestImage(imageEntity.imageURL)
                .takeUntil(stopSignalProducer)
                .map { $0 as UIImage? }
                .flatMapError { _ in SignalProducer<UIImage?, NoError>(value: nil) }
                .observeOn(UIScheduler())
        }
    }
    
    // This method can be used if you add next and previsou buttons on image detail view
    // to display the next or previous image.
//    public func updateIndex(index: Int) {
//        update(imageEntities, atIndex: index)
//    }
}

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
    public var id: AnyProperty<UInt64?> { return AnyProperty(_id) }
    public var pageImageSizeText: AnyProperty<String?> { return AnyProperty(_pageImageSizeText) }
    public var tagText: AnyProperty<String?> { return AnyProperty(_tagText) }
    public var usernameText: AnyProperty<String?> { return AnyProperty(_usernameText) }
    public var viewCountText: AnyProperty<String?> { return AnyProperty(_viewCountText) }
    public var downloadCountText: AnyProperty<String?> { return AnyProperty(_downloadCountText) }
    public var likeCountText: AnyProperty<String?> { return AnyProperty(_likeCountText) }
    public var image: AnyProperty<UIImage?> { return AnyProperty(_image) }
    
    private let _id = MutableProperty<UInt64?>(nil)
    private let _pageImageSizeText = MutableProperty<String?>(nil)
    private let _tagText = MutableProperty<String?>(nil)
    private let _usernameText = MutableProperty<String?>(nil)
    private let _viewCountText = MutableProperty<String?>(nil)
    private let _downloadCountText = MutableProperty<String?>(nil)
    private let _likeCountText = MutableProperty<String?>(nil)
    private let _image = MutableProperty<UIImage?>(nil)
    
    internal var locale = NSLocale.currentLocale() // For testing.
    private var imageEntities = [ImageEntity]()
    private var currentImageIndex = 0
    private var (stopSignalProducer, stopSignalObserver) = SignalProducer<(), NoError>.buffer()
    
    private let network: Networking
    private let externalAppChannel: ExternalAppChanneling

    public init(network: Networking, externalAppChannel: ExternalAppChanneling) {
        self.network = network
        self.externalAppChannel = externalAppChannel
    }
    
    public func openImagePage() {
        if let currentImageEntity = currentImageEntity {
            externalAppChannel.openURL(currentImageEntity.pageURL)
        }
    }
    
    private var currentImageEntity: ImageEntity? {
        return imageEntities.indices.contains(currentImageIndex) ? imageEntities[currentImageIndex] : nil
    }
}

extension ImageDetailViewModel: ImageDetailViewModelModifiable {
    public func update(imageEntities: [ImageEntity], atIndex index: Int) {
        stopSignalObserver.sendNext(())
        (stopSignalProducer, stopSignalObserver) = SignalProducer<(), NoError>.buffer()
        
        self.imageEntities = imageEntities
        currentImageIndex = index
        let imageEntity = currentImageEntity
        
        self._id.value = imageEntity?.id
        self._usernameText.value = imageEntity?.username
        self._pageImageSizeText.value = imageEntity.map { "\($0.pageImageWidth) x \($0.pageImageHeight)" }
        self._tagText.value = imageEntity.map { $0.tags.joinWithSeparator(", ") }
        self._viewCountText.value = imageEntity.map { formatInt64($0.viewCount) }
        self._downloadCountText.value = imageEntity.map { formatInt64($0.downloadCount) }
        self._likeCountText.value = imageEntity.map { formatInt64($0.likeCount) }
        
        _image.value = nil
        if let imageEntity = imageEntity {
            _image <~ network.requestImage(imageEntity.imageURL)
                .takeUntil(stopSignalProducer)
                .map { $0 as UIImage? }
                .flatMapError { _ in SignalProducer<UIImage?, NoError>(value: nil) }
                .observeOn(UIScheduler())
        }
    }
    
    private func formatInt64(value: Int64) -> String {
        return NSNumber(longLong: value).descriptionWithLocale(locale)
    }
    
    // This method can be used if you add next and previsou buttons on image detail view
    // to display the next or previous image.
//    public func updateIndex(index: Int) {
//        update(imageEntities, atIndex: index)
//    }
}

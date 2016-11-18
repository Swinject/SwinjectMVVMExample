//
//  ImageDetailViewModel.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/24/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import ReactiveSwift
import Result
import ExampleModel

public final class ImageDetailViewModel: ImageDetailViewModeling {
    public var id: Property<UInt64?> { return Property(_id) }
    public var pageImageSizeText: Property<String?> { return Property(_pageImageSizeText) }
    public var tagText: Property<String?> { return Property(_tagText) }
    public var usernameText: Property<String?> { return Property(_usernameText) }
    public var viewCountText: Property<String?> { return Property(_viewCountText) }
    public var downloadCountText: Property<String?> { return Property(_downloadCountText) }
    public var likeCountText: Property<String?> { return Property(_likeCountText) }
    public var image: Property<UIImage?> { return Property(_image) }
    
    fileprivate let _id = MutableProperty<UInt64?>(nil)
    fileprivate let _pageImageSizeText = MutableProperty<String?>(nil)
    fileprivate let _tagText = MutableProperty<String?>(nil)
    fileprivate let _usernameText = MutableProperty<String?>(nil)
    fileprivate let _viewCountText = MutableProperty<String?>(nil)
    fileprivate let _downloadCountText = MutableProperty<String?>(nil)
    fileprivate let _likeCountText = MutableProperty<String?>(nil)
    fileprivate let _image = MutableProperty<UIImage?>(nil)
    
    internal var locale = Locale.current // For testing.
    fileprivate var imageEntities = [ImageEntity]()
    fileprivate var currentImageIndex = 0
    fileprivate var stop = MutableProperty<Void>()
    
    fileprivate let network: Networking
    fileprivate let externalAppChannel: ExternalAppChanneling

    public init(network: Networking, externalAppChannel: ExternalAppChanneling) {
        self.network = network
        self.externalAppChannel = externalAppChannel
    }
    
    public func openImagePage() {
        if let currentImageEntity = currentImageEntity {
            externalAppChannel.openURL(currentImageEntity.pageURL)
        }
    }
    
    fileprivate var currentImageEntity: ImageEntity? {
        return imageEntities.indices.contains(currentImageIndex) ? imageEntities[currentImageIndex] : nil
    }
}

extension ImageDetailViewModel: ImageDetailViewModelModifiable {
    public func update(_ imageEntities: [ImageEntity], atIndex index: Int) {
        stop.value = ()
        stop = MutableProperty<Void>()
        
        self.imageEntities = imageEntities
        currentImageIndex = index
        let imageEntity = currentImageEntity
        
        self._id.value = imageEntity?.id
        self._usernameText.value = imageEntity?.username
        self._pageImageSizeText.value = imageEntity.map { "\($0.pageImageWidth) x \($0.pageImageHeight)" }
        self._tagText.value = imageEntity.map { $0.tags.joined(separator: ", ") }
        self._viewCountText.value = imageEntity.map { formatInt64($0.viewCount) }
        self._downloadCountText.value = imageEntity.map { formatInt64($0.downloadCount) }
        self._likeCountText.value = imageEntity.map { formatInt64($0.likeCount) }
        
        _image.value = nil
        if let imageEntity = imageEntity {
            _image <~ network.requestImage(imageEntity.imageURL)
                .take(until: stop.producer.skip(first: 1))
                .map { $0 as UIImage? }
                .flatMapError { _ in SignalProducer<UIImage?, NoError>(value: nil) }
                .observe(on: UIScheduler())
        }
    }
    
    fileprivate func formatInt64(_ value: Int64) -> String {
        return NSNumber(value: value as Int64).description(withLocale: locale)
    }
    
    // This method can be used if you add next and previsou buttons on image detail view
    // to display the next or previous image.
//    public func updateIndex(index: Int) {
//        update(imageEntities, atIndex: index)
//    }
}

//
//  ImageSearchTableViewCellModel.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import ReactiveSwift
import ReactiveCocoa
import Result
import ExampleModel

// Inherits NSObject to use rac_willDeallocSignal.
public final class ImageSearchTableViewCellModel: NSObject, ImageSearchTableViewCellModeling {
    public let id: UInt64
    public let pageImageSizeText: String
    public let tagText: String
    
    fileprivate let network: Networking
    fileprivate let previewURL: String
    fileprivate var previewImage: UIImage?
    
    internal init(image: ImageEntity, network: Networking) {
        id = image.id
        pageImageSizeText = "\(image.pageImageWidth) x \(image.pageImageHeight)"
        tagText = image.tags.joined(separator: ", ")
        
        self.network = network
        previewURL = image.previewURL
        
        super.init()
    }
    
    public func getPreviewImage() -> SignalProducer<UIImage?, NoError> {
        if let previewImage = self.previewImage {
            return SignalProducer(value: previewImage).observe(on: UIScheduler())
        }
        else {
            let imageProducer = network.requestImage(url: previewURL)
                .take(until: self.reactive.lifetime.ended)
                .on(value: { self.previewImage = $0 })
                .map { $0 as UIImage? }
                .flatMapError { _ in SignalProducer<UIImage?, NoError>(value: nil) }
            
            return SignalProducer(value: nil)
                .concat(imageProducer)
                .observe(on: UIScheduler())
        }
    }
}

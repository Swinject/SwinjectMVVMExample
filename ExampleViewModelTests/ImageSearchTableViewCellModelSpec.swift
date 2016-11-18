//
//  ImageSearchTableViewCellModelSpec.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/23/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import Foundation
import Quick
import Nimble
import ReactiveSwift
import Result
@testable import ExampleModel
@testable import ExampleViewModel

class ImageSearchTableViewCellModelSpec: QuickSpec {
    class StubNetwork: Networking {
        func requestJSON(_ url: String, parameters: [String : AnyObject]?) -> SignalProducer<Any, NetworkError> {
            return SignalProducer.empty
        }
        
        func requestImage(_ url: String) -> SignalProducer<UIImage, NetworkError> {
            return SignalProducer(value: image1x1).observe(on: QueueScheduler())
        }
    }

    class ErrorStubNetwork: Networking {
        func requestJSON(_ url: String, parameters: [String : AnyObject]?) -> SignalProducer<Any, NetworkError> {
            return SignalProducer.empty
        }
        
        func requestImage(_ url: String) -> SignalProducer<UIImage, NetworkError> {
            return SignalProducer(error: .NotConnectedToInternet)
        }
    }

    override func spec() {
        var viewModel: ImageSearchTableViewCellModel!
        beforeEach {
            viewModel = ImageSearchTableViewCellModel(image: dummyResponse.images[0], network: StubNetwork())
        }
        
        describe("Constant values") {
            it("sets id.") {
                expect(viewModel.id).toEventually(equal(10000))
            }
            it("formats tag and page image size texts.") {
                expect(viewModel.pageImageSizeText).toEventually(equal("1000 x 2000"))
                expect(viewModel.tagText).toEventually(equal("a, b"))
            }
        }
        describe("Preview image") {
            it("returns nil at the first time.") {
                var image: UIImage? = image1x1
                viewModel.getPreviewImage()
                    .take(first: 1)
                    .on(value: { image = $0 })
                    .start()
                
                expect(image).toEventually(beNil())
            }
            it("eventually returns an image.") {
                var image: UIImage? = nil
                viewModel.getPreviewImage()
                    .on(value: { image = $0 })
                    .start()
                
                expect(image).toEventuallyNot(beNil())
            }
            it("returns an image on the main thread.") {
                var onMainThread = false
                viewModel.getPreviewImage()
                    .skip(first: 1) // Skips the first nil.
                    .on(value: { _ in onMainThread = Thread.isMainThread })
                    .start()
                
                expect(onMainThread).toEventually(beTrue())
            }
            context("with an image already downloaded") {
                it("immediately returns the image omitting the first nil.") {
                    var image: UIImage? = nil
                    viewModel.getPreviewImage().startWithCompleted() {
                        viewModel.getPreviewImage()
                            .take(first: 1)
                            .on(value: { image = $0 })
                            .start()
                    }
                    
                    expect(image).toEventuallyNot(beNil())
                }
            }
            context("on error") {
                it("returns nil.") {
                    var image: UIImage? = image1x1
                    let viewModel = ImageSearchTableViewCellModel(image: dummyResponse.images[0], network: ErrorStubNetwork())
                    viewModel.getPreviewImage()
                        .skip(first: 1) // Skips the first nil.
                        .on(value: { image = $0 })
                        .start()
                    
                    expect(image).toEventually(beNil())
                }
            }
        }
    }
}


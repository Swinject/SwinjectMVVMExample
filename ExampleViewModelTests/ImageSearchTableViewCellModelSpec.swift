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
import ReactiveCocoa
@testable import ExampleModel
@testable import ExampleViewModel

class ImageSearchTableViewCellModelSpec: QuickSpec {
    class StubNetwork: Networking {
        func requestJSON(url: String, parameters: [String : AnyObject]?) -> SignalProducer<AnyObject, NetworkError> {
            return SignalProducer.empty
        }
        
        func requestImage(url: String) -> SignalProducer<UIImage, NetworkError> {
            return SignalProducer(value: image1x1).observeOn(QueueScheduler())
        }
    }

    class ErrorStubNetwork: Networking {
        func requestJSON(url: String, parameters: [String : AnyObject]?) -> SignalProducer<AnyObject, NetworkError> {
            return SignalProducer.empty
        }
        
        func requestImage(url: String) -> SignalProducer<UIImage, NetworkError> {
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
                    .take(1)
                    .on(next: { image = $0 })
                    .start()
                
                expect(image).toEventually(beNil())
            }
            it("eventually returns an image.") {
                var image: UIImage? = nil
                viewModel.getPreviewImage()
                    .on(next: { image = $0 })
                    .start()
                
                expect(image).toEventuallyNot(beNil())
            }
            it("returns an image on the main thread.") {
                var onMainThread = false
                viewModel.getPreviewImage()
                    .skip(1) // Skips the first nil.
                    .on(next: { _ in onMainThread = NSThread.isMainThread() })
                    .start()
                
                expect(onMainThread).toEventually(beTrue())
            }
            context("with an image already downloaded") {
                it("immediately returns the image omitting the first nil.") {
                    var image: UIImage? = nil
                    viewModel.getPreviewImage().start(completed: {
                        viewModel.getPreviewImage()
                            .take(1)
                            .on(next: { image = $0 })
                            .start()
                    })
                    
                    expect(image).toEventuallyNot(beNil())
                }
            }
            context("on error") {
                it("returns nil.") {
                    var image: UIImage? = image1x1
                    let viewModel = ImageSearchTableViewCellModel(image: dummyResponse.images[0], network: ErrorStubNetwork())
                    viewModel.getPreviewImage()
                        .skip(1) // Skips the first nil.
                        .on(next: { image = $0 })
                        .start()
                    
                    expect(image).toEventually(beNil())
                }
            }
        }
    }
}

private let image1x1: UIImage = {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), true, 0)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}()


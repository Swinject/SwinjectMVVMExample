//
//  ImageDetailViewModelSpec.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/25/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import Quick
import Nimble
import ReactiveCocoa
import ExampleModel
@testable import ExampleViewModel

class ImageDetailViewModelSpec: QuickSpec {
    // MARK: Stub
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
            return SignalProducer(error: .InternationalRoamingOff).observeOn(QueueScheduler())
        }
    }
    
    // MARK: - Mock
    class MockExternalAppChannel: ExternalAppChanneling {
        var passedURL: String?
        
        func openURL(url: String) {
            passedURL = url
        }
    }

    // MARK: - Spec
    override func spec() {
        var externalAppChannel: MockExternalAppChannel!
        var viewModel: ImageDetailViewModel!
        beforeEach {
            externalAppChannel = MockExternalAppChannel()
            viewModel = ImageDetailViewModel(network: StubNetwork(), externalAppChannel: externalAppChannel)
        }
        
        describe("Constant values") {
            it("sets id and username.") {
                viewModel.update(dummyResponse.images, atIndex: 0)
                expect(viewModel.id.value) == 10000
                expect(viewModel.usernameText.value) == "User0"
            }
            it("formats tag and page image size texts.") {
                viewModel.update(dummyResponse.images, atIndex: 1)
                expect(viewModel.pageImageSizeText.value) == "1500 x 3000"
                expect(viewModel.tagText.value) == "x, y"
            }
        }
        describe("Image") {
            it("eventually gets an image.") {
                viewModel.update(dummyResponse.images, atIndex: 0)
                expect(viewModel.image.value).toEventuallyNot(beNil())
            }
        }
        describe("Image page") {
            it("opens the URL of the current image page.") {
                viewModel.update(dummyResponse.images, atIndex: 1)
                viewModel.openImagePage()
                expect(externalAppChannel.passedURL) == "https://somewhere.com/page1/"
            }
        }
    }
}


//
//  ImageSearchTableViewModelSpec.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/23/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import Quick
import Nimble
import ReactiveCocoa
@testable import ExampleModel
@testable import ExampleViewModel

class ImageSearchTableViewModelSpec: QuickSpec {
    class StubImageSearch: ImageSearching {
        func searchImages() -> SignalProducer<ResponseEntity, NetworkError> {
            return SignalProducer { observer, disposable in
                sendNext(observer, dummyResponse)
                sendCompleted(observer)
            }
            .observeOn(QueueScheduler())
        }
    }
    
    class StubNetwork: Networking {
        func requestJSON(url: String, parameters: [String : AnyObject]?) -> SignalProducer<AnyObject, NetworkError> {
            return SignalProducer.empty
        }
        
        func requestImage(url: String) -> SignalProducer<UIImage, NetworkError> {
            return SignalProducer.empty
        }
    }
    
    class MockImageDetailViewModel: ImageDetailViewModelModifiable {
        let id = PropertyOf<UInt64?>(initialValue: 0, producer: SignalProducer.empty)
        let pageImageSizeText = PropertyOf<String?>(initialValue: nil, producer: SignalProducer.empty)
        let tagText = PropertyOf<String?>(initialValue: nil, producer: SignalProducer.empty)
        let usernameText = PropertyOf<String?>(initialValue: nil, producer: SignalProducer.empty)
        let image = PropertyOf<UIImage?>(initialValue: nil, producer: SignalProducer.empty)
        
        var imageEntities: [ImageEntity]?
        var index: Int?
        
        func update(imageEntities: [ImageEntity], atIndex index: Int) {
            self.imageEntities = imageEntities
            self.index = index
        }
    }
    
    override func spec() {
        var viewModel: ImageSearchTableViewModel!
        var imageDetailViewModel: MockImageDetailViewModel!
        beforeEach {
            viewModel = ImageSearchTableViewModel(imageSearch: StubImageSearch(), network: StubNetwork())
            imageDetailViewModel = MockImageDetailViewModel()
            viewModel.imageDetailViewModel = imageDetailViewModel
        }
        
        describe("Image search") {
            it("eventually sets cellModels property after the search.") {
                var cellModels: [ImageSearchTableViewCellModeling]? = nil
                viewModel.cellModels.producer
                    .on(next: { cellModels = $0 })
                    .start()
                viewModel.startSearch()
                
                expect(cellModels).toEventuallyNot(beNil())
                expect(cellModels?.count).toEventually(equal(2))
                expect(cellModels?[0].id).toEventually(equal(10000))
                expect(cellModels?[1].id).toEventually(equal(10001))
            }
            it("sets cellModels property on the main thread.") {
                var onMainThread = false
                viewModel.cellModels.producer
                    .on(next: { _ in onMainThread = NSThread.isMainThread() })
                    .start()
                viewModel.startSearch()
                
                expect(onMainThread).toEventually(beTrue())
            }
        }
        describe("Image detail view model") {
            it("passes the image entities and selected index to the image detail view model.") {
                viewModel.cellModels.producer
                    .on(next: { _ in viewModel.selectCellAtIndex(1) })
                    .start()
                viewModel.startSearch()

                expect(imageDetailViewModel.imageEntities?.count).toEventually(equal(2))
                expect(imageDetailViewModel.index).toEventually(equal(1))
            }
        }
    }
}

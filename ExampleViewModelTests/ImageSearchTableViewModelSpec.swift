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
    // MARK: Stub
    class StubImageSearch: ImageSearching {
        func searchImages(nextPageTrigger trigger: SignalProducer<(), NoError>) -> SignalProducer<ResponseEntity, NetworkError> {
            return SignalProducer { observer, disposable in
                sendNext(observer, dummyResponse)
                sendCompleted(observer)
            }
            .observeOn(QueueScheduler())
        }
    }

    class NotCompletingStubImageSearch: ImageSearching {
        func searchImages(nextPageTrigger trigger: SignalProducer<(), NoError>) -> SignalProducer<ResponseEntity, NetworkError> {
            return SignalProducer { observer, disposable in
                sendNext(observer, dummyResponse)
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
    
    // MARK: - Mock
    class MockImageSearch: ImageSearching {
        var nextPageTriggered = false

        func searchImages(nextPageTrigger trigger: SignalProducer<(), NoError>) -> SignalProducer<ResponseEntity, NetworkError> {
            trigger.on(next: { _ in self.nextPageTriggered = true }).start()
            
            return SignalProducer { observer, disposable in
                sendNext(observer, dummyResponse)
            }
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
        
        func openImagePage() {
        }
    }
    
    // MARK: - Spec
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
            it("updates searching property when the search starts and finishes") {
                var observedValues = [Bool]()
                viewModel.searching.producer
                    .on(next: { observedValues.append($0) })
                    .start()
                
                viewModel.startSearch()
                expect(distinctUntilChanged(observedValues)).toEventually(equal([false, true, false]))
            }
            it("keeps loadNextPage action disabled if the search signal completes.") {
                viewModel.startSearch()
                expect(viewModel.loadNextPage.enabled.value).toEventuallyNot(beTrue())
            }
            it("has loadNextPage action set to enabled if the search signal does not complete.") {
                let viewModel = ImageSearchTableViewModel(imageSearch: NotCompletingStubImageSearch(), network: StubNetwork())
                viewModel.startSearch()
                expect(viewModel.loadNextPage.enabled.value).toEventually(beTrue())
            }
        }
        describe("Load next page") {
            it("triggers nextPageTrigger passed to ImageSearch by calling loadNextPage method.") {
                let imageSearch = MockImageSearch()
                let viewModel = ImageSearchTableViewModel(imageSearch: imageSearch, network: StubNetwork())
                
                viewModel.startSearch()
                expect(imageSearch.nextPageTriggered).to(beFalse())

                viewModel.loadNextPage.enabled.producer
                    .on(next: { enabled in
                        if enabled {
                            viewModel.loadNextPage.apply(()).start()
                        }
                    })
                    .start()
                expect(imageSearch.nextPageTriggered).toEventually(beTrue())
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

private func distinctUntilChanged<T: Equatable>(values: [T]) -> [T] {
    return values.reduce([]) { array, value in value == array.last ? array : array + [value] }
}

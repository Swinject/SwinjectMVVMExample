//
//  ImageSearchTableViewModelSpec.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/23/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import Quick
import Nimble
import ReactiveSwift
import Result
@testable import ExampleModel
@testable import ExampleViewModel

class ImageSearchTableViewModelSpec: QuickSpec {
    // MARK: Stub
    class StubImageSearch: ImageSearching {
        func searchImages(nextPageTrigger trigger: SignalProducer<(), NoError>) -> SignalProducer<ResponseEntity, NetworkError> {
            return SignalProducer { observer, disposable in
                observer.send(value: dummyResponse)
                observer.sendCompleted()
            }
            .observe(on: QueueScheduler())
        }
    }

    class NotCompletingStubImageSearch: ImageSearching {
        func searchImages(nextPageTrigger trigger: SignalProducer<(), NoError>) -> SignalProducer<ResponseEntity, NetworkError> {
            return SignalProducer { observer, disposable in
                observer.send(value: dummyResponse)
            }
            .observe(on: QueueScheduler())
        }
    }
    
    class ErrorStubImageSearch: ImageSearching {
        func searchImages(nextPageTrigger trigger: SignalProducer<(), NoError>) -> SignalProducer<ResponseEntity, NetworkError> {
            return SignalProducer { observer, disposable in
                observer.send(error: NetworkError.Unknown)
            }
            .observe(on: QueueScheduler())
        }
    }

    class StubNetwork: Networking {
        func requestJSON(_ url: String, parameters: [String : AnyObject]?) -> SignalProducer<Any, NetworkError> {
            return SignalProducer.empty
        }
        
        func requestImage(_ url: String) -> SignalProducer<UIImage, NetworkError> {
            return SignalProducer.empty
        }
    }
    
    // MARK: - Mock
    class MockImageSearch: ImageSearching {
        var nextPageTriggered = false

        func searchImages(nextPageTrigger trigger: SignalProducer<(), NoError>) -> SignalProducer<ResponseEntity, NetworkError> {
            trigger.on(value: { _ in self.nextPageTriggered = true }).start()
            
            return SignalProducer { observer, disposable in
                observer.send(value: dummyResponse)
            }
        }
    }
    
    class MockImageDetailViewModel: ImageDetailViewModelModifiable {
        let id = Property<UInt64?>(initial: 0, then: SignalProducer.empty)
        let pageImageSizeText = Property<String?>(initial: nil, then: SignalProducer.empty)
        let tagText = Property<String?>(initial: nil, then: SignalProducer.empty)
        let usernameText = Property<String?>(initial: nil, then: SignalProducer.empty)
        let viewCountText = Property<String?>(initial: nil, then: SignalProducer.empty)
        let downloadCountText = Property<String?>(initial: nil, then: SignalProducer.empty)
        let likeCountText = Property<String?>(initial: nil, then: SignalProducer.empty)
        let image = Property<UIImage?>(initial: nil, then: SignalProducer.empty)
        
        var imageEntities: [ImageEntity]?
        var index: Int?
        
        func update(_ imageEntities: [ImageEntity], atIndex index: Int) {
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
                    .on(value: { cellModels = $0 })
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
                    .on(value: { _ in onMainThread = Thread.isMainThread })
                    .start()
                viewModel.startSearch()
                
                expect(onMainThread).toEventually(beTrue())
            }
            it("updates searching property when the search starts and finishes") {
                var observedValues = [Bool]()
                viewModel.searching.producer
                    .on(value: { observedValues.append($0) })
                    .start()
                
                viewModel.startSearch()
                expect(distinctUntilChanged(observedValues)).toEventually(equal([false, true, false]))
            }
            it("keeps loadNextPage action disabled if the search signal completes.") {
                viewModel.startSearch()
                expect(viewModel.loadNextPage.isEnabled.value).toEventuallyNot(beTrue())
            }
            it("has loadNextPage action set to enabled if the search signal does not complete.") {
                let viewModel = ImageSearchTableViewModel(imageSearch: NotCompletingStubImageSearch(), network: StubNetwork())
                viewModel.startSearch()
                expect(viewModel.loadNextPage.isEnabled.value).toEventually(beTrue())
            }
            context("on error") {
                it("sets errorMessage property.") {
                    let viewModel = ImageSearchTableViewModel(imageSearch: ErrorStubImageSearch(), network: StubNetwork())
                    viewModel.startSearch()
                    expect(viewModel.errorMessage.value).toEventuallyNot(beNil())
                }
            }
        }
        describe("Load next page") {
            it("triggers nextPageTrigger passed to ImageSearch by calling loadNextPage method.") {
                let imageSearch = MockImageSearch()
                let viewModel = ImageSearchTableViewModel(imageSearch: imageSearch, network: StubNetwork())
                
                viewModel.startSearch()
                expect(imageSearch.nextPageTriggered).to(beFalse())

                viewModel.loadNextPage.isEnabled.producer
                    .on(value: { enabled in
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
                    .on(value: { _ in viewModel.selectCellAtIndex(1) })
                    .start()
                viewModel.startSearch()

                expect(imageDetailViewModel.imageEntities?.count).toEventually(equal(2))
                expect(imageDetailViewModel.index).toEventually(equal(1))
            }
        }
    }
}

private func distinctUntilChanged<T: Equatable>(_ values: [T]) -> [T] {
    return values.reduce([]) { array, value in value == array.last ? array : array + [value] }
}

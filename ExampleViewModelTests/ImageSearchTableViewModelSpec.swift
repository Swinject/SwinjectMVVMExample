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
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
                    sendNext(observer, dummyResponse)
                    sendCompleted(observer)
                })
            }
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
    
    override func spec() {
        var viewModel: ImageSearchTableViewModel!
        beforeEach {
            viewModel = ImageSearchTableViewModel(imageSearch: StubImageSearch(), network: StubNetwork())
        }
        
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
}

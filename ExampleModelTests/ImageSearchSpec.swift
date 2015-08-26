//
//  ImageSearchSpec.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import Quick
import Nimble
import ReactiveCocoa
@testable import ExampleModel

class ImageSearchSpec: QuickSpec {
    // MARK: Stub
    class GoodStubNetwork: Networking {
        func requestJSON(url: String, parameters: [String : AnyObject]?) -> SignalProducer<AnyObject, NetworkError> {
            var imageJSON0 = imageJSON
            imageJSON0["id"] = 0
            var imageJSON1 = imageJSON
            imageJSON1["id"] = 1
            let json: [String: AnyObject] = [
                "totalHits": 123,
                "hits": [imageJSON0, imageJSON1]
            ]
            
            return SignalProducer { observer, disposable in
                sendNext(observer, json)
                sendCompleted(observer)
            }
            .observeOn(QueueScheduler())
        }
        
        func requestImage(url: String) -> SignalProducer<UIImage, NetworkError> {
            return SignalProducer.empty
        }
    }
    
    class BadStubNetwork: Networking {
        func requestJSON(url: String, parameters: [String : AnyObject]?) -> SignalProducer<AnyObject, NetworkError> {
            let json = [String: AnyObject]()
            
            return SignalProducer { observer, disposable in
                sendNext(observer, json)
                sendCompleted(observer)
            }
            .observeOn(QueueScheduler())
        }
        
        func requestImage(url: String) -> SignalProducer<UIImage, NetworkError> {
            return SignalProducer.empty
        }
    }

    class ErrorStubNetwork: Networking {
        func requestJSON(url: String, parameters: [String : AnyObject]?) -> SignalProducer<AnyObject, NetworkError> {
            return SignalProducer { observer, disposable in
                sendError(observer, .NotConnectedToInternet)
            }
            .observeOn(QueueScheduler())
        }
        
        func requestImage(url: String) -> SignalProducer<UIImage, NetworkError> {
            return SignalProducer.empty
        }
    }
    
    class CountConfigurableStubNetwork: Networking {
        var imageCountToEmit = 100
        
        func requestJSON(url: String, parameters: [String : AnyObject]?) -> SignalProducer<AnyObject, NetworkError> {
            func createImageJSON(id id: Int) -> [String: AnyObject] {
                var json = imageJSON
                json["id"] = id
                return json
            }
            let json: [String: AnyObject] = [
                "totalHits": 123,
                "hits": (0..<imageCountToEmit).map { createImageJSON(id: $0) }
            ]
            
            return SignalProducer { observer, disposable in
                sendNext(observer, json)
                sendCompleted(observer)
            }.observeOn(QueueScheduler())
        }
        
        func requestImage(url: String) -> SignalProducer<UIImage, NetworkError> {
            return SignalProducer.empty
        }
    }
    
    // MARK: - Mock
    class MockNetwork: Networking {
        var passedParameters: [String : AnyObject]?

        func requestJSON(url: String, parameters: [String : AnyObject]?) -> SignalProducer<AnyObject, NetworkError> {
            passedParameters = parameters
            return SignalProducer.empty
        }
        
        func requestImage(url: String) -> SignalProducer<UIImage, NetworkError> {
            return SignalProducer.empty
        }
    }


    // MARK: - Spec
    override func spec() {
        describe("Response") {
            it("returns images if the network works correctly.") {
                var response: ResponseEntity? = nil
                let search = ImageSearch(network: GoodStubNetwork())
                search.searchImages(nextPageTrigger: SignalProducer.empty)
                    .on(next: { response = $0 })
                    .start()
                
                expect(response).toEventuallyNot(beNil())
                expect(response?.totalCount).toEventually(equal(123))
                expect(response?.images.count).toEventually(equal(2))
                expect(response?.images[0].id).toEventually(equal(0))
                expect(response?.images[1].id).toEventually(equal(1))
            }
            it("sends an error if the network returns incorrect data.") {
                var error: NetworkError? = nil
                let search = ImageSearch(network: BadStubNetwork())
                search.searchImages(nextPageTrigger: SignalProducer.empty)
                    .on(error: { error = $0 })
                    .start()
                
                expect(error).toEventually(equal(NetworkError.IncorrectDataReturned))
            }
            it("passes the error sent by the network.") {
                var error: NetworkError? = nil
                let search = ImageSearch(network: ErrorStubNetwork())
                search.searchImages(nextPageTrigger: SignalProducer.empty)
                    .on(error: { error = $0 })
                    .start()
                
                expect(error).toEventually(equal(NetworkError.NotConnectedToInternet))
            }
        }
        describe("Pagination") {
            describe("page parameter") {
                var mockNetwork: MockNetwork!
                var search: ImageSearch!
                beforeEach {
                    mockNetwork = MockNetwork()
                    search = ImageSearch(network: mockNetwork)
                }
                
                it("sets page to 1 at the beginning.") {
                    search.searchImages(nextPageTrigger: SignalProducer.empty).start()
                    expect(mockNetwork.passedParameters?["page"] as? Int).toEventually(equal(1))
                }
                it("increments page by nextPageTrigger") {
                    let trigger = SignalProducer<(), NoError>(value: ()) // Trigger once.
                    search.searchImages(nextPageTrigger: trigger).start()
                    expect(mockNetwork.passedParameters?["page"] as? Int).toEventually(equal(2))
                }
            }
            describe("completed event") {
                var network: CountConfigurableStubNetwork!
                var search: ImageSearch!
                var nextPageTrigger: (SignalProducer<(), NoError>, Event<(), NoError> -> ())! // SignalProducer buffer
                beforeEach {
                    network = CountConfigurableStubNetwork()
                    search = ImageSearch(network: network)
                    nextPageTrigger = SignalProducer.buffer()
                }
                
                it("sends completed when no more images can be found.") {
                    var completedCalled = false
                    network.imageCountToEmit = Pixabay.maxImagesPerPage
                    search.searchImages(nextPageTrigger: nextPageTrigger.0)
                        .on(completed: { completedCalled = true })
                        .start()
                    
                    sendNext(nextPageTrigger.1, ()) // Emits `maxImagesPerPage` (50) images, which mean more images possibly exit.
                    network.imageCountToEmit = Pixabay.maxImagesPerPage - 1
                    sendNext(nextPageTrigger.1, ()) // Emits only 49, which mean no more images exist.
                    expect(completedCalled).toEventually(beTrue(), timeout: 2)
                }
                it("does not send completed if the max image number per page is filled.") {
                    var completedCalled = false
                    network.imageCountToEmit = Pixabay.maxImagesPerPage
                    search.searchImages(nextPageTrigger: nextPageTrigger.0)
                        .on(completed: { completedCalled = true })
                        .start()
                    
                    sendNext(nextPageTrigger.1, ()) // Emits `maxImagesPerPage` (50) images, which mean more images possibly exit.
                    expect(completedCalled).toEventuallyNot(beTrue())
                }
            }
        }
    }
}

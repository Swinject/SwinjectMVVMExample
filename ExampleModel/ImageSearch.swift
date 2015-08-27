//
//  ImageSearch.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import ReactiveCocoa
import Himotoki

public final class ImageSearch: ImageSearching {
    private let network: Networking
    
    public init(network: Networking) {
        self.network = network
    }
    
    public func searchImages(nextPageTrigger trigger: SignalProducer<(), NoError>) -> SignalProducer<ResponseEntity, NetworkError> {
        return SignalProducer { observer, disposable in
            let firstSearch = SignalProducer<(), NoError>(value: ())
            let load = firstSearch.concat(trigger)
            var parameters = Pixabay.requestParameters
            var loadedImageCount: Int64 = 0
            
            load.on(next: {
                self.network.requestJSON(Pixabay.apiURL, parameters: parameters)
                    .start({ event in
                        switch event {
                        case .Next(let json):
                            if let response = decode(json) as ResponseEntity? {
                                sendNext(observer, response)
                                loadedImageCount += response.images.count
                                if response.totalCount <= loadedImageCount || response.images.count < Pixabay.maxImagesPerPage {
                                    sendCompleted(observer)
                                }
                            }
                            else {
                                sendError(observer, .IncorrectDataReturned)
                            }
                        case .Error(let error):
                            sendError(observer, error)
                        case .Completed:
                            break
                        case .Interrupted:
                            sendInterrupted(observer)
                        }
                    })
                parameters = Pixabay.incrementPage(parameters)
            }).start()
        }
    }
}

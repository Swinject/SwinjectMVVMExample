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
    
    public func searchImages() -> SignalProducer<ResponseEntity, NetworkError> {
        return SignalProducer { observer, disposable in
            self.network.requestJSON(Pixabay.apiURL, parameters: Pixabay.requestParameters)
                .start({ event in
                    switch event {
                    case .Next(let json):
                        if let response = decode(json) as ResponseEntity? {
                            sendNext(observer, response)
                        }
                        else {
                            sendError(observer, .IncorrectDataReturned)
                        }
                    case .Error(let error):
                        sendError(observer, error)
                    case .Completed:
                        sendCompleted(observer)
                    case .Interrupted:
                        sendInterrupted(observer)
                    }
                })
        }
    }
}

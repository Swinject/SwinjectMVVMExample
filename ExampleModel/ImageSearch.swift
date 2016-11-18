//
//  ImageSearch.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import ReactiveSwift
import Result
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
            
            load.on(value: {
                self.network.requestJSON(Pixabay.apiURL, parameters: parameters as [String : AnyObject])
                    .start({ event in
                        switch event {
                        case .value(let json):
                            if let response = try? ResponseEntity.decodeValue(json) {
                                observer.send(value: response)
                                loadedImageCount += response.images.count
                                if response.totalCount <= loadedImageCount || response.images.count < Pixabay.maxImagesPerPage {
                                    observer.sendCompleted()
                                }
                            }
                            else {
                                observer.send(error: .IncorrectDataReturned)
                            }
                        case .failed(let error):
                            observer.send(error: error)
                        case .completed:
                            break
                        case .interrupted:
                            observer.sendInterrupted()
                        }
                    })
                parameters = Pixabay.incrementPage(parameters)
            }).start()
        }
    }
}

//
//  ImageSearching.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import ReactiveSwift
import Result

public protocol ImageSearching {
    func searchImages(nextPageTrigger trigger: SignalProducer<(), NoError>) -> SignalProducer<ResponseEntity, NetworkError>
}

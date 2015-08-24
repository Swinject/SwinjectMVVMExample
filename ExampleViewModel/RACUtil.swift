//
//  RACUtil.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/24/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import Foundation
import ReactiveCocoa

internal extension NSObject {
    internal var racutil_willDeallocProducer: SignalProducer<(), NoError>  {
        return self.rac_willDeallocSignal()
            .toSignalProducer()
            .map { _ in }
            .flatMapError { _ in SignalProducer(value: ()) }
    }
}

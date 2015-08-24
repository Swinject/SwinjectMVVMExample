//
//  RACUtil.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/24/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import UIKit
import ReactiveCocoa

internal extension UITableViewCell {
    internal var racutil_prepareForReuseProducer: SignalProducer<(), NoError>  {
        return self.rac_prepareForReuseSignal
            .toSignalProducer()
            .map { _ in }
            .flatMapError { _ in SignalProducer(value: ()) }
    }
}

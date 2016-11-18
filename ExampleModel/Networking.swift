//
//  Networking.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import ReactiveSwift

public protocol Networking {
    /// Returns a `SignalProducer` emitting a JSON root element ( an array or dictionary).
    func requestJSON(url: String, parameters: [String : AnyObject]?) -> SignalProducer<Any, NetworkError>
    
    /// Returns a `SignalProducer` emitting an `UIImage`.
    func requestImage(url: String) -> SignalProducer<UIImage, NetworkError>
}

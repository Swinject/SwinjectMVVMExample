//
//  LocalizedString.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/26/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

internal func LocalizedString(_ key: String, comment: String?) -> String {
    struct Static {
        static let bundle = Bundle(identifier: "com.github.Swinject.SwinjectMVVMExample.ExampleViewModel")!
    }
    return NSLocalizedString(key, bundle: Static.bundle, comment: comment ?? "")
}

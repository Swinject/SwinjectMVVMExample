//
//  ExternalAppChannel.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/26/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

public final class ExternalAppChannel: ExternalAppChanneling {
    public init() {
    }
    
    public func openURL(url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.openURL(url)
        }
    }
}

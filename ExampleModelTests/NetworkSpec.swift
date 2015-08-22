//
//  NetworkSpec.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import Quick
import Nimble
@testable import ExampleModel

/// Specificatios of Network.
/// As a stable network service, https://httpbin.org is used.
/// Refer to the website for its API details.
class NetworkSpec: QuickSpec {
    override func spec() {
        describe("JSON") {
            it("eventually gets JSON data as specified with parameters.") {
                var json: [String: AnyObject]? = nil
                Network().requestJSON("https://httpbin.org/get", parameters: ["a": "b", "x": "y"])
                    .on(next: { json = $0 as? [String: AnyObject] })
                    .start()
                
                expect(json).toEventuallyNot(beNil(), timeout: 5)
                expect((json?["args"] as? [String: AnyObject])?["a"] as? String).toEventually(equal("b"), timeout: 5)
                expect((json?["args"] as? [String: AnyObject])?["x"] as? String).toEventually(equal("y"), timeout: 5)
            }
            it("eventually gets an error if the network has a problem.") {
                var error: NetworkError? = nil
                Network().requestJSON("https://not.existing.server.comm/get", parameters: ["a": "b", "x": "y"])
                    .on(error: { error = $0 })
                    .start()
                
                expect(error).toEventually(equal(NetworkError.NotReachedServer), timeout: 5)
            }
        }
    }
}

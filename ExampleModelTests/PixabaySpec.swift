//
//  PixabaySpec.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/25/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import Quick
import Nimble
@testable import ExampleModel

class PixabaySpec: QuickSpec {
    override func spec() {
        describe("Increment page") {
            it("increments page number.") {
                var parameter = Pixabay.requestParameters
                expect(parameter["page"] as? Int) == 1
                parameter = Pixabay.incrementPage(parameter)
                expect(parameter["page"] as? Int) == 2
            }
            it("sets page to 1 if no page is specified.") {
                var parameter = Pixabay.requestParameters
                parameter["page"] = nil
                parameter = Pixabay.incrementPage(parameter)
                expect(parameter["page"] as? Int) == 1
            }
        }
    }
}


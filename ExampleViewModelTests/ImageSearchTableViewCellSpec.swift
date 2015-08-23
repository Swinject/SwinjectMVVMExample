//
//  ImageSearchTableViewCellSpec.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/23/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import Quick
import Nimble
@testable import ExampleModel
@testable import ExampleViewModel

class ImageSearchTableViewCellSpec: QuickSpec {
    override func spec() {
        it("sets id and preview URL.") {
            let viewModel = ImageSearchTableViewCellModel(image: dummyResponse.images[0])
            
            expect(viewModel.id).toEventually(equal(10000))
            expect(viewModel.previewURL).toEventually(equal("https://somewhere.com/preview0.jpg"))
        }
        it("formats tag and page image size texts.") {
            let viewModel = ImageSearchTableViewCellModel(image: dummyResponse.images[0])
            
            expect(viewModel.pageImageSizeText).toEventually(equal("1000 x 2000"))
            expect(viewModel.tagText).toEventually(equal("a, b"))
        }
    }
}

//
//  ImageEntitySpec.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import Quick
import Nimble
import Himotoki
@testable import ExampleModel

internal let imageJSON: [String: AnyObject] = [
    "id": 12345,
    "pageURL": "https:\\/\\/somewhere.com\\/page\\/",
    "imageWidth": 2000,
    "imageHeight": 1000,
    "previewURL": "https:\\/\\/somewhere.com\\/preview.jpg",
    "previewWidth": 200,
    "previewHeight": 100,
    "webformatURL": "https:\\/\\/somewhere.com\\/image.jpg",
    "webformatWidth": 600,
    "webformatHeight": 300,
    "views": 54321,
    "downloads": 4321,
    "likes": 321,
    "tags": "a, b c, d ",
    "user": "Swinject"
]

class ImageEntitySpec: QuickSpec {
    override func spec() {
        it("parses JSON data to create a new instance.") {
            let image: ImageEntity? = decode(imageJSON)
            
            expect(image).notTo(beNil())
            expect(image?.id) == 12345
            expect(image?.pageURL) == "https:\\/\\/somewhere.com\\/page\\/"
            expect(image?.pageImageWidth) == 2000
            expect(image?.pageImageHeight) == 1000
            expect(image?.previewURL) == "https:\\/\\/somewhere.com\\/preview.jpg"
            expect(image?.previewWidth) == 200
            expect(image?.previewHeight) == 100
            expect(image?.imageURL) == "https:\\/\\/somewhere.com\\/image.jpg"
            expect(image?.imageWidth) == 600
            expect(image?.imageHeight) == 300
            expect(image?.viewCount) == 54321
            expect(image?.downloadCount) == 4321
            expect(image?.likeCount) == 321
            expect(image?.tags) == ["a", "b c", "d"]
            expect(image?.username) == "Swinject"
        }
        it("gets an empty array if tags element is nil.") {
            var missingJSON = imageJSON
            missingJSON["tags"] = nil
            let image: ImageEntity? = decode(missingJSON)
            
            expect(image?.tags.isEmpty).to(beTrue())
        }
        it("gets nil if any of JSON elements except tags is missing.") {
            for key in imageJSON.keys where key != "tags" {
                var missingJSON = imageJSON
                missingJSON[key] = nil
                let image: ImageEntity? = decode(missingJSON)
                
                expect(image).to(beNil())
            }
        }
        it("ignores an extra JOSN element.") {
            var extraJSON = imageJSON
            extraJSON["extraKey"] = "extra element"
            let image: ImageEntity? = decode(extraJSON)
            
            expect(image).notTo(beNil())
        }
    }
}

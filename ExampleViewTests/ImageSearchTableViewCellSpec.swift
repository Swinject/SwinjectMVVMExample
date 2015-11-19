//
//  ImageSearchTableViewCellSpec.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/24/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import Quick
import Nimble
import ReactiveCocoa
import ExampleViewModel
@testable import ExampleView

class ImageSearchTableViewCellSpec: QuickSpec {
    class MockViewModel: ImageSearchTableViewCellModeling {
        let id: UInt64 = 0
        let pageImageSizeText = ""
        let tagText = ""
        
        var getPreviewImageStarted = false
        
        func getPreviewImage() -> SignalProducer<UIImage?, NoError> {
            return SignalProducer<UIImage?, NoError> { observer, _ in
                self.getPreviewImageStarted = true
                observer.sendCompleted()
            }
        }
    }

    override func spec() {
        it("starts getPreviewImage signal producer when its view model is set.") {
            let viewModel = MockViewModel()
            let view = createTableViewCell()
            
            expect(viewModel.getPreviewImageStarted) == false
            view.viewModel = viewModel
            expect(viewModel.getPreviewImageStarted) == true
        }
    }
}

private func createTableViewCell() -> ImageSearchTableViewCell {
    let bundle = NSBundle(forClass: ImageSearchTableViewCell.self)
    let storyboard = UIStoryboard(name: "Main", bundle: bundle)
    let tableViewController = storyboard.instantiateViewControllerWithIdentifier("ImageSearchTableViewController")
        as! ImageSearchTableViewController
    return tableViewController.tableView.dequeueReusableCellWithIdentifier("ImageSearchTableViewCell")
        as! ImageSearchTableViewCell
}

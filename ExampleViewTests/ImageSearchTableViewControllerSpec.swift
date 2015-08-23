//
//  ImageSearchTableViewControllerSpec.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/23/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import Quick
import Nimble
import ReactiveCocoa
import ExampleViewModel
@testable import ExampleView

class ImageSearchTableViewControllerSpec: QuickSpec {
    class MockViewModel: ImageSearchTableViewModeling {
        let cellModels = PropertyOf(MutableProperty<[ImageSearchTableViewCellModeling]>([]))
        var startSearchCalled = false
        
        func startSearch() {
            startSearchCalled = true
        }
    }
    
    override func spec() {
        it("starts searching images when the view is about to appear.") {
            let viewModel = MockViewModel()
            let viewController = ImageSearchTableViewController()
            viewController.viewModel = viewModel
            
            expect(viewModel.startSearchCalled) == false
            viewController.viewWillAppear(true)
            expect(viewModel.startSearchCalled) == true
        }
    }
}

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
        let searching = PropertyOf(ConstantProperty<Bool>(false))
        var loadNextPage: Action<(), (), NoError> = Action { SignalProducer.empty }
        
        var startSearchCallCount = 0
        
        func startSearch() {
            startSearchCallCount++
        }
        
        func selectCellAtIndex(index: Int) {
        }
    }
    
    override func spec() {
        it("starts searching images when the view is about to appear at the first time.") {
            let viewModel = MockViewModel()
            let viewController = ImageSearchTableViewController()
            viewController.viewModel = viewModel
            
            expect(viewModel.startSearchCallCount) == 0
            viewController.viewWillAppear(true)
            expect(viewModel.startSearchCallCount) == 1
            viewController.viewWillAppear(true)
            expect(viewModel.startSearchCallCount) == 1
        }
    }
}

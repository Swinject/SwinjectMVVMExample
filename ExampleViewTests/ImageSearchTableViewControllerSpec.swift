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
        let cellModels = AnyProperty(MutableProperty<[ImageSearchTableViewCellModeling]>([]))
        let searching = AnyProperty(ConstantProperty<Bool>(false))
        let errorMessage = AnyProperty(ConstantProperty<String?>(nil))
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
            let storyboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: ImageSearchTableViewController.self))
            let viewController = storyboard.instantiateViewControllerWithIdentifier("ImageSearchTableViewController") as! ImageSearchTableViewController
            viewController.viewModel = viewModel
            
            expect(viewModel.startSearchCallCount) == 0
            viewController.viewWillAppear(true)
            expect(viewModel.startSearchCallCount) == 1
            viewController.viewWillAppear(true)
            expect(viewModel.startSearchCallCount) == 1
        }
    }
}

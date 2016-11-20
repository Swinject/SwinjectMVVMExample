//
//  ImageSearchTableViewControllerSpec.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/23/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import Quick
import Nimble
import ReactiveSwift
import Result
import ExampleViewModel
@testable import ExampleView

class ImageSearchTableViewControllerSpec: QuickSpec {
    class MockViewModel: ImageSearchTableViewModeling {
        let cellModels = Property(MutableProperty<[ImageSearchTableViewCellModeling]>([]))
        let searching = Property(value: false)
        let errorMessage = Property<String?>(value: nil)
        var loadNextPage: Action<(), (), NoError> = Action { SignalProducer.empty }
        
        var startSearchCallCount = 0
        
        func startSearch() {
            startSearchCallCount += 1
        }
        
        func selectCellAtIndex(_ index: Int) {
        }
    }
    
    override func spec() {
        it("starts searching images when the view is about to appear at the first time.") {
            let viewModel = MockViewModel()
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: ImageSearchTableViewController.self))
            let viewController = storyboard.instantiateViewController(withIdentifier: "ImageSearchTableViewController") as! ImageSearchTableViewController
            viewController.viewModel = viewModel
            
            expect(viewModel.startSearchCallCount) == 0
            viewController.viewWillAppear(true)
            expect(viewModel.startSearchCallCount) == 1
            viewController.viewWillAppear(true)
            expect(viewModel.startSearchCallCount) == 1
        }
    }
}

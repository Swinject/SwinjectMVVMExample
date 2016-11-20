//
//  AppDelegateSpec.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/28/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import Quick
import Nimble
import Swinject
import SwinjectStoryboard
import ExampleModel
import ExampleViewModel
import ExampleView
@testable import SwinjectMVVMExample

class AppDelegateSpec: QuickSpec {
    override func spec() {
        var container: Container!
        beforeEach {
            container = AppDelegate().container
        }
        
        describe("Container") {
            it("resolves every service type.") {
                // Models
                expect(container.resolve(Networking.self)).notTo(beNil())
                expect(container.resolve(ImageSearching.self)).notTo(beNil())
                expect(container.resolve(ExternalAppChanneling.self)).notTo(beNil())

                // ViewModels
                expect(container.resolve(ImageSearchTableViewModeling.self)).notTo(beNil())
                expect(container.resolve(ImageDetailViewModelModifiable.self)).notTo(beNil())
                expect(container.resolve(ImageDetailViewModeling.self)).notTo(beNil())
            }
            it("injects view models to views.") {
                let bundle = Bundle(for: ImageSearchTableViewController.self)
                let storyboard = SwinjectStoryboard.create(name: "Main", bundle: bundle, container: container)
                let imageSearchTableViewController = storyboard.instantiateViewController(withIdentifier: "ImageSearchTableViewController")
                    as! ImageSearchTableViewController
                let imageDetailviewController = storyboard.instantiateViewController(withIdentifier: "ImageDetailViewController")
                    as! ImageDetailViewController
                
                expect(imageSearchTableViewController.viewModel).notTo(beNil())
                expect(imageDetailviewController.viewModel).notTo(beNil())
            }
        }
    }
}

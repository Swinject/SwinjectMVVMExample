//
//  AppDelegate.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/20/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import UIKit
import Swinject
import SwinjectStoryboard
import ExampleModel
import ExampleViewModel
import ExampleView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let container = Container() { container in
        // Models
        container.register(Networking.self) { _ in Network() }
        container.register(ImageSearching.self) { r in ImageSearch(network: r.resolve(Networking.self)!) }
        container.register(ExternalAppChanneling.self) { _ in ExternalAppChannel() }
        
        // View models
        container.register(ImageSearchTableViewModeling.self) { r in
            let viewModel = ImageSearchTableViewModel(imageSearch: r.resolve(ImageSearching.self)!, network: r.resolve(Networking.self)!)
            viewModel.imageDetailViewModel = r.resolve(ImageDetailViewModelModifiable.self)!
            return viewModel
            }.inObjectScope(.container)
        container.register(ImageDetailViewModelModifiable.self) { _ in
            ImageDetailViewModel(
                network: container.resolve(Networking.self)!,
                externalAppChannel: container.resolve(ExternalAppChanneling.self)!)
            }.inObjectScope(.container)
        container.register(ImageDetailViewModeling.self) { r in
            r.resolve(ImageDetailViewModelModifiable.self)!
        }
        
        // Views
        container.registerForStoryboard(ImageSearchTableViewController.self) { r, c in
            c.viewModel = r.resolve(ImageSearchTableViewModeling.self)!
        }
        container.registerForStoryboard(ImageDetailViewController.self) { r, c in
            c.viewModel = r.resolve(ImageDetailViewModeling.self)!
        }
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.white
        window.makeKeyAndVisible()
        self.window = window
        
        let bundle = Bundle(for: ImageSearchTableViewController.self)
        let storyboard = SwinjectStoryboard.create(name: "Main", bundle: bundle, container: container)
        window.rootViewController = storyboard.instantiateInitialViewController()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}


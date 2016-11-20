//
//  SwinjectStoryboard.swift
//  Swinject
//
//  Created by Yoichi Tagaya on 7/31/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import Swinject

#if os(iOS) || os(tvOS) || os(OSX)

/// The `SwinjectStoryboard` provides the features to inject dependencies of view/window controllers in a storyboard.
///
/// To specify a registration name of a view/window controller registered to the `Container` as a service type,
/// add a user defined runtime attribute with the following settings:
///
/// - Key Path: `swinjectRegistrationName`
/// - Type: String
/// - Value: Registration name to the `Container`
///
/// in User Defined Runtime Attributes section on Indentity Inspector pane.
/// If no name is supplied to the registration, no runtime attribute should be specified.
public class SwinjectStoryboard: _SwinjectStoryboardBase, SwinjectStoryboardType {
    /// A shared container used by SwinjectStoryboard instances that are instantiated without specific containers.
    ///
    /// Typical usecases of this property are:
    /// - Implicit instantiation of UIWindow and its root view controller from "Main" storyboard.
    /// - Storyboard references to transit from a storyboard to another.
    public static var defaultContainer = Container()
    
    // Boxing to workaround a runtime error [Xcode 7.1.1 and Xcode 7.2 beta 4]
    // If container property is ResolverType type and a ResolverType instance is assigned to the property,
    // the program crashes by EXC_BAD_ACCESS, which looks a bug of Swift.
    internal var container: Box<ResolverType>!
    
    /// Do NOT call this method explicitly. It is designed to be called by the runtime.
    public override class func initialize() {
        struct Static {
            static var onceToken: () = {
                (SwinjectStoryboard.self as SwinjectStoryboardType.Type).setup?()
            }()
        }
        let _ = Static.onceToken
    }

    private override init() {
        super.init()
    }

    /// Creates the new instance of `SwinjectStoryboard`. This method is used instead of an initializer.
    ///
    /// - Parameters:
    ///   - name:      The name of the storyboard resource file without the filename extension.
    ///   - bundle:    The bundle containing the storyboard file and its resources. Specify nil to use the main bundle.
    ///   - container: The container with registrations of the view/window controllers in the storyboard and their dependencies.
    ///                The shared singleton container `SwinjectStoryboard.defaultContainer` is used if no container is passed.
    ///
    /// - Returns: The new instance of `SwinjectStoryboard`.
    public class func create(
        name: String,
        bundle storyboardBundleOrNil: Bundle?,
        container: ResolverType = SwinjectStoryboard.defaultContainer) -> SwinjectStoryboard
    {
        // Use this factory method to create an instance because the initializer of UI/NSStoryboard is "not inherited".
        let storyboard = SwinjectStoryboard._create(name, bundle: storyboardBundleOrNil)
        storyboard.container = Box(container)
        return storyboard
    }


#if os(iOS) || os(tvOS)
    /// Instantiates the view controller with the specified identifier.
    /// The view controller and its child controllers have their dependencies injected
    /// as specified in the `Container` passed to the initializer of the `SwinjectStoryboard`.
    ///
    /// - Parameter identifier: The identifier set in the storyboard file.
    ///
    /// - Returns: The instantiated view controller with its dependencies injected.
    public override func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
        SwinjectStoryboard.pushInstantiatingStoryboard(self)
        let viewController = super.instantiateViewController(withIdentifier: identifier)
        SwinjectStoryboard.popInstantiatingStoryboard()

        if !SwinjectStoryboard.isCreatingStoryboardReference {
            injectDependency(to: viewController)
        }
        return viewController
    }
    
    private func injectDependency(to viewController: UIViewController) {
        let registrationName = viewController.swinjectRegistrationName

        // Xcode 7.1 workaround for Issue #10. This workaround is not necessary with Xcode 7.
        // If a future update of Xcode fixes the problem, replace the resolution with the following code and fix registerForStoryboard too.
        // https://github.com/Swinject/Swinject/issues/10
        if let container = container.value as? _ResolverType {
            let option = SwinjectStoryboardOption(controllerType: type(of: viewController))
            typealias FactoryType = (ResolverType, Container.Controller) -> Container.Controller
            let _ = container._resolve(name: registrationName, option: option) { (factory: FactoryType) in factory(self.container.value, viewController) }
        } else {
            fatalError("A type conforming ResolverType protocol must conform _ResolverType protocol too.")
        }

        for child in viewController.childViewControllers {
            injectDependency(to: child)
        }
    }
    
#elseif os(OSX)
    /// Instantiates the view/Window controller with the specified identifier.
    /// The view/window controller and its child controllers have their dependencies injected
    /// as specified in the `Container` passed to the initializer of the `SwinjectStoryboard`.
    ///
    /// - Parameter identifier: The identifier set in the storyboard file.
    ///
    /// - Returns: The instantiated view/window controller with its dependencies injected.
    public override func instantiateController(withIdentifier identifier: String) -> Any {
        SwinjectStoryboard.pushInstantiatingStoryboard(self)
        let controller = super.instantiateController(withIdentifier: identifier)
        SwinjectStoryboard.popInstantiatingStoryboard()

        if !SwinjectStoryboard.isCreatingStoryboardReference {
            injectDependency(to: controller)
        }
        return controller
    }
    
    private func injectDependency(to controller: Container.Controller) {
        let registrationName = (controller as? RegistrationNameAssociatable)?.swinjectRegistrationName
        
        // Xcode 7.1 workaround for Issue #10. This workaround is not necessary with Xcode 7.
        // If a future update of Xcode fixes the problem, replace the resolution with the following code and fix registerForStoryboard too:
        // https://github.com/Swinject/Swinject/issues/10
        if let container = container.value as? _ResolverType {
            let option = SwinjectStoryboardOption(controllerType: type(of: controller))
            typealias FactoryType = (ResolverType, Container.Controller) -> Container.Controller
            let _ = container._resolve(name: registrationName, option: option) { (factory: FactoryType) in factory(self.container.value, controller) }
        } else {
            fatalError("A type conforming ResolverType protocol must conform _ResolverType protocol too.")
        }
        if let windowController = controller as? NSWindowController, let viewController = windowController.contentViewController {
            injectDependency(to: viewController)
		}
        if let viewController = controller as? NSViewController {
            for child in viewController.childViewControllers {
                injectDependency(to: child)
            }
        }
    }
#endif
}

#endif

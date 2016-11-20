//
//  ImageSearchTableViewModeling.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import ReactiveSwift
import Result

public protocol ImageSearchTableViewModeling {
    var cellModels: Property<[ImageSearchTableViewCellModeling]> { get }
    var searching: Property<Bool> { get }
    var errorMessage: Property<String?> { get }
    
    func startSearch()
    var loadNextPage: Action<(), (), NoError> { get }
    
    func selectCellAtIndex(_ index: Int)
}

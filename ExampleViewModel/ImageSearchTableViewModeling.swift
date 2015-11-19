//
//  ImageSearchTableViewModeling.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import ReactiveCocoa

public protocol ImageSearchTableViewModeling {
    var cellModels: AnyProperty<[ImageSearchTableViewCellModeling]> { get }
    var searching: AnyProperty<Bool> { get }
    var errorMessage: AnyProperty<String?> { get }
    
    func startSearch()
    var loadNextPage: Action<(), (), NoError> { get }
    
    func selectCellAtIndex(index: Int)
}

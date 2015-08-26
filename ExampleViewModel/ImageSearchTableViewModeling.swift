//
//  ImageSearchTableViewModeling.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import ReactiveCocoa

public protocol ImageSearchTableViewModeling {
    var cellModels: PropertyOf<[ImageSearchTableViewCellModeling]> { get }
    var searching: PropertyOf<Bool> { get }
    
    func startSearch()
    var loadNextPage: Action<(), (), NoError> { get }
    
    func selectCellAtIndex(index: Int)
}

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
    
    func startSearch()
}

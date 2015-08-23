//
//  ImageSearchTableViewModel.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import ReactiveCocoa
import ExampleModel

public final class ImageSearchTableViewModel: ImageSearchTableViewModeling {
    public let cellModels: PropertyOf<[ImageSearchTableViewCellModeling]>
    private let _cellModels = MutableProperty<[ImageSearchTableViewCellModeling]>([])
    private let imageSearch: ImageSearching
    
    public init(imageSearch: ImageSearching) {
        self.imageSearch = imageSearch
        cellModels = PropertyOf(_cellModels)
    }
    
    public func startSearch() {
        imageSearch.searchImages()
            .map { response in
                response.images.map { ImageSearchTableViewCellModel(image: $0) as ImageSearchTableViewCellModeling }
            }
            .observeOn(QueueScheduler.mainQueueScheduler)
            .on(next: { cellModels in
                self._cellModels.value = cellModels
            })
            .start()
    }
}

//
//  ImageSearchTableViewModel.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import ReactiveSwift
import Result
import ExampleModel

public final class ImageSearchTableViewModel: ImageSearchTableViewModeling {
    public var cellModels: Property<[ImageSearchTableViewCellModeling]> { return Property(_cellModels) }
    public var searching: Property<Bool> { return Property(_searching) }
    public var errorMessage: Property<String?> { return Property(_errorMessage) }
    
    fileprivate let _cellModels = MutableProperty<[ImageSearchTableViewCellModeling]>([])
    fileprivate let _searching = MutableProperty<Bool>(false)
    fileprivate let _errorMessage = MutableProperty<String?>(nil)
    
    /// Accepts property injection.
    public var imageDetailViewModel: ImageDetailViewModelModifiable?
    
    public var loadNextPage: Action<(), (), NoError> {
        return Action(enabledIf: nextPageLoadable) { _ in
            return SignalProducer { observer, disposable in
                if let observer = self.nextPageTrigger.value {
                    self._searching.value = true
                    observer.value = ()
                }
            }
        }
    }
    fileprivate var nextPageLoadable: Property<Bool> {
        return Property(
            initial: false,
            then: searching.producer.combineLatest(with: nextPageTrigger.producer).map { searching, trigger in
                !searching && trigger != nil
            })
    }
    fileprivate let nextPageTrigger = MutableProperty<MutableProperty<Void>?>(nil) // SignalProducer buffer

    fileprivate let imageSearch: ImageSearching
    fileprivate let network: Networking
    
    fileprivate var foundImages = [ImageEntity]()
    
    public init(imageSearch: ImageSearching, network: Networking) {
        self.imageSearch = imageSearch
        self.network = network
    }
    
    public func startSearch() {
        func toCellModel(_ image: ImageEntity) -> ImageSearchTableViewCellModeling {
            return ImageSearchTableViewCellModel(image: image, network: self.network) as ImageSearchTableViewCellModeling
        }
        
        _searching.value = true
        nextPageTrigger.value = MutableProperty()
        let trigger = nextPageTrigger.value!.producer.skip(first: 1)

        imageSearch.searchImages(nextPageTrigger: trigger)
            .map { response in
                (response.images, response.images.map { toCellModel($0) })
            }
            .observe(on: UIScheduler())
            .on(value: { images, cellModels in
                self.foundImages += images
                self._cellModels.value += cellModels
                self._searching.value = false
            })
            .on(failed: { error in
                self._errorMessage.value = error.description
            })
            .on(event: { event in
                switch event {
                case .completed, .failed, .interrupted:
                    self.nextPageTrigger.value = nil
                    self._searching.value = false
                default:
                    break
                }
            })
            .start()
    }

    public func selectCellAtIndex(_ index: Int) {
        imageDetailViewModel?.update(foundImages, atIndex: index)
    }
}

//
//  ImageSearchTableViewCell.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import ExampleViewModel
import ReactiveCocoa

internal final class ImageSearchTableViewCell: UITableViewCell {
    internal var viewModel: ImageSearchTableViewCellModeling? {
        didSet {
            tagLabel.text = viewModel?.tagText
            imageSizeLabel.text = viewModel?.pageImageSizeText
            
            if let viewModel = viewModel {
                viewModel.getPreviewImage()
                    .takeUntil(self.racutil_prepareForReuseProducer)
                    .on(next: { self.thumbnailImageView.image = $0 })
                    .start()
            }
            else {
                thumbnailImageView.image = nil
            }
        }
    }
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var imageSizeLabel: UILabel!
}

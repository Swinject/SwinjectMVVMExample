//
//  ImageDetailViewController.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/24/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ExampleViewModel

public final class ImageDetailViewController: UIViewController {
    public var viewModel: ImageDetailViewModeling?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let viewModel = viewModel {
            viewModel.image.producer
                .on(next: { self.imageView.image = $0 })
                .start()
            viewModel.tagText.producer
                .on(next: { self.tagLabel.text = $0 })
                .start()
            viewModel.usernameText.producer
                .on(next: { self.usernameLabel.text = $0 })
                .start()
            viewModel.pageImageSizeText.producer
                .on(next: { self.imageSizeLabel.text = $0 })
                .start()
            viewModel.viewCountText.producer
                .on(next: { self.viewCountLabel.text = $0 })
                .start()
            viewModel.downloadCountText.producer
                .on(next: { self.downloadCountLabel.text = $0 })
                .start()
            viewModel.likeCountText.producer
                .on(next: { self.likeCountLabel.text = $0 })
                .start()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var imageSizeLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var downloadCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    
    @IBAction func openImagePage(sender: UIBarButtonItem) {
        let actionText = LocalizedString("ImageDetailViewController_ActionSheetViewInSafari", comment: "Action sheet button text.")
        let cancelText = LocalizedString("ImageDetailViewController_ActionSheetCancel", comment: "Action sheet button text.")
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: actionText, style: .Default) { _ in
            viewModel?.openImagePage()
        })
        alertController.addAction(UIAlertAction(title: cancelText, style: .Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

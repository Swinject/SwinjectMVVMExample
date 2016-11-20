//
//  ImageSearchTableViewController.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import ExampleViewModel

public final class ImageSearchTableViewController: UITableViewController {
    fileprivate var autoSearchStarted = false
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var searchingIndicator: UIActivityIndicatorView!
    
    public var viewModel: ImageSearchTableViewModeling? {
        didSet {
            if let viewModel = viewModel {
                viewModel.cellModels.producer
                    .on(value: { _ in self.tableView.reloadData() })
                    .start()
                viewModel.searching.producer
                    .on(value: { searching in
                        if searching {
                            // Display the activity indicator at the center of the screen if the table is empty.
                            self.footerView.frame.size.height = viewModel.cellModels.value.isEmpty
                                ? self.tableView.frame.size.height + self.tableView.contentOffset.y : 44.0
                            
                            self.tableView.tableFooterView = self.footerView
                            self.searchingIndicator.startAnimating()
                        }
                        else {
                            self.tableView.tableFooterView = nil
                            self.searchingIndicator.stopAnimating()
                        }
                    })
                    .start()
                viewModel.errorMessage.producer
                    .on(value: { errorMessage in
                        if let errorMessage = errorMessage {
                            self.displayErrorMessage(errorMessage)
                        }
                    })
                    .start()
            }
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !autoSearchStarted {
            autoSearchStarted = true
            viewModel?.startSearch()
        }
    }
    
    fileprivate func displayErrorMessage(_ errorMessage: String) {
        let title = LocalizedString("ImageSearchTableViewController_ErrorAlertTitle", comment: "Error alert title.")
        let dismissButtonText = LocalizedString("ImageSearchTableViewController_DismissButtonTitle", comment: "Dismiss button title on an alert.")
        let message = errorMessage
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: dismissButtonText, style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
            })
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: UITableViewDataSource
extension ImageSearchTableViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let viewModel = viewModel {
            return viewModel.cellModels.value.count
        }
        return 0
        
        // The following code invokes didSet of viewModel property. A bug?
        // return viewModel?.cellModels.value.count ?? 0
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageSearchTableViewCell", for: indexPath) as! ImageSearchTableViewCell
        cell.viewModel = viewModel.map { $0.cellModels.value[indexPath.row] }
        
        if let viewModel = viewModel
            , indexPath.row >= viewModel.cellModels.value.count - 1 && viewModel.loadNextPage.isEnabled.value {
                viewModel.loadNextPage.apply(()).start()
        }

        return cell
    }
}

// MARK: - UITableViewDelegate
extension ImageSearchTableViewController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.selectCellAtIndex(indexPath.row)
        performSegue(withIdentifier: "ImageDetailViewControllerSegue", sender: self)
    }
}

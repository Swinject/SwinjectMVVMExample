//
//  ImageSearchTableViewController.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import ExampleViewModel

public final class ImageSearchTableViewController: UITableViewController {
    private var autoSearchStarted = false
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var searchingIndicator: UIActivityIndicatorView!
    
    public var viewModel: ImageSearchTableViewModeling? {
        didSet {
            if let viewModel = viewModel {
                viewModel.cellModels.producer
                    .on(next: { _ in self.tableView.reloadData() })
                    .start()
                viewModel.searching.producer
                    .on(next: { searching in
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
            }
        }
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !autoSearchStarted {
            autoSearchStarted = true
            viewModel?.startSearch()
        }
    }
}

// MARK: UITableViewDataSource
extension ImageSearchTableViewController {
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let viewModel = viewModel {
            return viewModel.cellModels.value.count
        }
        return 0
        
        // The following code invokes didSet of viewModel property. A bug?
        // return viewModel?.cellModels.value.count ?? 0
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ImageSearchTableViewCell", forIndexPath: indexPath) as! ImageSearchTableViewCell
        cell.viewModel = viewModel.map { $0.cellModels.value[indexPath.row] }
        
        if let viewModel = viewModel
            where indexPath.row >= viewModel.cellModels.value.count - 1 && viewModel.loadNextPage.enabled.value {
                viewModel.loadNextPage.apply(()).start()
        }

        return cell
    }
}

// MARK: - UITableViewDelegate
extension ImageSearchTableViewController {
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        viewModel?.selectCellAtIndex(indexPath.row)
        performSegueWithIdentifier("ImageDetailViewControllerSegue", sender: self)
    }
}

//
//  ViewController1.swift
//  Swinject
//
//  Created by Yoichi Tagaya on 11/2/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import Cocoa

class ViewController1: NSViewController {
    var animalViewController: AnimalViewController?
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        self.animalViewController = segue.destinationController as? AnimalViewController
    }
}

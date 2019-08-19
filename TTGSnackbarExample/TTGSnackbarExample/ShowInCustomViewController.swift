//
//  ShowInCustomViewController.swift
//  TTGSnackbarExample
//
//  Created by tutuge on 2018/10/7.
//  Copyright © 2018 tutuge. All rights reserved.
//

import UIKit

class ShowInCustomViewController: UIViewController {

    @IBOutlet weak var customContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func show(_ sender: UIButton) {
        let snackbar = TTGSnackbar.init(message: "Show in custom view", duration: .short)
        snackbar.containerView = customContainerView
        snackbar.show()
    }

}

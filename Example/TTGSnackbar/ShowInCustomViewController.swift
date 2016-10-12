//
//  ShowInCustomViewController.swift
//  TTGSnackbar
//
//  Created by tutuge on 2016/10/13.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit
import TTGSnackbar

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

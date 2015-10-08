//
//  ViewController.swift
//  TTGSnackbarExample
//
//  Created by zekunyan on 15/10/5.
//  Copyright © 2015年 tutuge. All rights reserved.
//

import UIKit
import TTGSnackbar

class ViewController: UIViewController {
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var actionTextField: UITextField!
    @IBOutlet weak var durationSegmented: UISegmentedControl!
    
    let durationTypes = [TTGSnackbarDuration.TTGSnackbarDurationShort, TTGSnackbarDuration.TTGSnackbarDurationMiddle, TTGSnackbarDuration.TTGSnackbarDurationLong]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func show(sender: UIButton) {
        let snackbar: TTGSnackbar = TTGSnackbar.init(message: messageTextField.text!, duration: durationTypes[durationSegmented.selectedSegmentIndex])
        snackbar.show()
    }
    
    @IBAction func showWithAction(sender: UIButton) {
        let snackbar: TTGSnackbar = TTGSnackbar.init(message: messageTextField.text!, duration: durationTypes[durationSegmented.selectedSegmentIndex],
            actionText: actionTextField.text!, actionBlock: {(TTGSnackbar snackbar) in NSLog("Click action")})
        snackbar.show()
    }
}


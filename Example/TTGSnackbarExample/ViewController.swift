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
    @IBOutlet weak var outputLabel: UILabel!
    
    let durationTypes = [TTGSnackbarDuration.TTGSnackbarDurationShort, TTGSnackbarDuration.TTGSnackbarDurationMiddle, TTGSnackbarDuration.TTGSnackbarDurationLong]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func show(sender: UIButton) {
        let snackbar: TTGSnackbar = TTGSnackbar.init(message: messageTextField.text!, duration: durationTypes[durationSegmented.selectedSegmentIndex])
        snackbar.show()
    }
    
    @IBAction func showWithAction(sender: UIButton) {
        outputLabel?.text = "";
        let snackbar: TTGSnackbar = TTGSnackbar.init(message: messageTextField.text!, duration: durationTypes[durationSegmented.selectedSegmentIndex],
            actionText: actionTextField.text!, actionBlock: {(TTGSnackbar snackbar) in outputLabel?.text = "Click action !"})
        
        // Add dismiss callback
        snackbar.dismissBlock = {(snackbar: TTGSnackbar) -> Void in outputLabel?.text = "Dismiss !"}
        
        // Change message text color
        snackbar.messageTextColor = UIColor.redColor()
        
        snackbar.show()
    }
    
    @IBAction func showWithActionAndDismissManually(sender: UIButton) {
        outputLabel?.text = "";
        let snackbar: TTGSnackbar = TTGSnackbar.init(message: messageTextField.text!, duration: TTGSnackbarDuration.TTGSnackbarDurationForever,
            actionText: actionTextField.text!, actionBlock: {(TTGSnackbar snackbar) in outputLabel?.text = "Click action !"})
        snackbar.show()
        
        // Add dismiss callback
        snackbar.dismissBlock = {(snackbar: TTGSnackbar) -> Void in outputLabel?.text = "Dismiss !"}
        
        // Dismiss manually after 3 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            snackbar.dismiss()
        }
    }
    
}


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
    @IBOutlet weak var animationTypeSegmented: UISegmentedControl!

    let durationTypes: [TTGSnackbarDuration] = [.Short, .Middle, .Long]
    let animationTypes: [TTGSnackbarAnimationType] = [.SlideFromBottomBackToBottom, .FadeInFadeOut, .SlideFromLeftToRight]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func show(sender: UIButton) {
        let snackbar: TTGSnackbar = TTGSnackbar.init(message: messageTextField.text!, duration: durationTypes[durationSegmented.selectedSegmentIndex])
        
        // Change message text font and color
        snackbar.messageTextColor = UIColor.yellowColor()
        snackbar.messageTextFont = UIFont.boldSystemFontOfSize(18)
        
        // Change animation duration
        snackbar.animationDuration = 0.5
        
        snackbar.animationType = animationTypes[animationTypeSegmented!.selectedSegmentIndex]
        snackbar.show()
    }

    @IBAction func showWithAction(sender: UIButton) {
        outputLabel?.text = "";
        let snackbar: TTGSnackbar = TTGSnackbar.init(message: messageTextField.text!, duration: durationTypes[durationSegmented.selectedSegmentIndex],
                actionText: actionTextField.text!, actionBlock: { (snackbar) in self.outputLabel?.text = "Click action !" })

        // Change action text font and color
        snackbar.actionTextColor = UIColor.grayColor()
        snackbar.actionTextFont = UIFont.italicSystemFontOfSize(16)
        
        // Change left and right margin
        snackbar.leftMargin = 12
        snackbar.rightMargin = 12
        
        // Change bottom margin
        snackbar.bottomMargin = 12
        
        // Change corner radius
        snackbar.cornerRadius = 2

        snackbar.animationType = animationTypes[animationTypeSegmented!.selectedSegmentIndex]
        snackbar.show()
    }

    @IBAction func showWithActionAndDismissManually(sender: UIButton) {
        outputLabel?.text = "";
        let snackbar: TTGSnackbar = TTGSnackbar.init(message: messageTextField.text!, duration: TTGSnackbarDuration.Forever,
                actionText: actionTextField.text!) {
            (snackbar) in

            // Dismiss manually after 3 seconds
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                () -> Void in
                snackbar.dismiss()
            }
        }

        // Add dismiss callback
        snackbar.dismissBlock = {
            (snackbar: TTGSnackbar) -> Void in self.outputLabel?.text = "Dismiss !"
        }

        snackbar.animationType = animationTypes[animationTypeSegmented!.selectedSegmentIndex]
        snackbar.show()
    }
    
    @IBAction func showWithTwoActions(sender: UIButton) {
        let snackbar: TTGSnackbar = TTGSnackbar.init(message: "Two actions !", duration: durationTypes[durationSegmented.selectedSegmentIndex])
        
        // Action 1
        snackbar.actionText = "Yes"
        snackbar.actionTextColor = UIColor.greenColor()
        snackbar.actionBlock = { (snackbar) in self.outputLabel?.text = "Click Yes !"}
        
        // Action 2
        snackbar.secondActionText = "No"
        snackbar.secondActionTextColor = UIColor.yellowColor()
        snackbar.secondActionBlock = { (snackbar) in self.outputLabel?.text = "Click No !"}
        
        snackbar.animationType = animationTypes[animationTypeSegmented!.selectedSegmentIndex]
        snackbar.show()
    }
    
    @IBAction func showWithIconImage(sender: UIButton) {
        let snackbar: TTGSnackbar = TTGSnackbar.init(message: messageTextField.text!, duration: durationTypes[durationSegmented.selectedSegmentIndex])
        
        // Add icon image
        snackbar.icon = UIImage.init(named: "emoji_cool_small")
        
        snackbar.animationType = animationTypes[animationTypeSegmented!.selectedSegmentIndex]
        snackbar.show()
    }
}


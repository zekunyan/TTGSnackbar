//
//  ViewController.swift
//  TTGSnackbarExample
//
//  Created by tutuge on 2018/10/7.
//  Copyright © 2018 tutuge. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var actionTextField: UITextField!
    @IBOutlet weak var durationSegmented: UISegmentedControl!
    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var animationTypeSegmented: UISegmentedControl!
    
    let durationTypes: [TTGSnackbarDuration] = [.short, .middle, .long]
    let animationTypes: [TTGSnackbarAnimationType] = [.slideFromBottomBackToBottom, .fadeInFadeOut, .slideFromLeftToRight, .slideFromTopBackToTop]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func show(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let snackbar: TTGSnackbar = TTGSnackbar.init(message: messageTextField.text!, duration: durationTypes[durationSegmented.selectedSegmentIndex])
        
        // Change the content padding inset
        snackbar.contentInset = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
        
        // Change margin
        snackbar.leftMargin = 8
        snackbar.rightMargin = 8
        
        // Change message text font and color
        snackbar.messageTextColor = UIColor(red:0.22, green:0.29, blue:0.36, alpha:1.00)
        snackbar.messageTextFont = UIFont.boldSystemFont(ofSize: 18)
        
        // Change snackbar background color
        snackbar.backgroundColor = UIColor(red:0.30, green:0.72, blue:0.53, alpha:1.00)
        
        // Change animation duration
        snackbar.animationDuration = 0.5
        
        // Animation type
        snackbar.animationType = animationTypes[animationTypeSegmented!.selectedSegmentIndex]
        
        snackbar.show()
    }
    
    @IBAction func showWithAction(_ sender: UIButton) {
        self.view.endEditing(true)
        
        outputLabel?.text = "";
        let snackbar: TTGSnackbar = TTGSnackbar.init(message: messageTextField.text!, duration: durationTypes[durationSegmented.selectedSegmentIndex],
                                                     actionText: actionTextField.text!, actionBlock: { (snackbar) in self.outputLabel?.text = "Click action !" })
        
        // Change action text font and color
        snackbar.actionTextColor = UIColor.gray
        snackbar.actionTextFont = UIFont.boldSystemFont(ofSize: 16)
        
        // Change action max width
        snackbar.actionMaxWidth = 80
        
        // Change left and right margin
        snackbar.leftMargin = 12
        snackbar.rightMargin = 12
        
        // Change bottom margin
        snackbar.bottomMargin = 12
        
        // Change corner radius
        snackbar.cornerRadius = 2
        
        // Change separate line back color
        snackbar.separateViewBackgroundColor = .yellow
        
        snackbar.animationType = animationTypes[animationTypeSegmented!.selectedSegmentIndex]
        snackbar.show()
    }
    
    @IBAction func showWithActionAndDismissManually(_ sender: UIButton) {
        self.view.endEditing(true)
        
        outputLabel?.text = "";
        let snackbar: TTGSnackbar = TTGSnackbar.init(message: messageTextField.text!, duration: TTGSnackbarDuration.forever,
                                                     actionText: actionTextField.text!) {
                                                        (snackbar) in
                                                        
                                                        // Dismiss manually after 3 seconds
                                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
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
    
    @IBAction func showWithTwoActions(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let snackbar: TTGSnackbar = TTGSnackbar.init(message: messageTextField.text!, duration: durationTypes[durationSegmented.selectedSegmentIndex])
        
        // Action 1
        snackbar.actionText = "Yes"
        snackbar.actionTextColor = UIColor.green
        snackbar.actionBlock = { (snackbar) in self.outputLabel?.text = "Click Yes !"}
        
        // Action 2
        snackbar.secondActionText = "No"
        snackbar.secondActionTextColor = UIColor.yellow
        snackbar.secondActionBlock = { (snackbar) in self.outputLabel?.text = "Click No !"}
        
        snackbar.animationType = animationTypes[animationTypeSegmented!.selectedSegmentIndex]
        snackbar.show()
    }
    
    @IBAction func showWithIconImage(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let snackbar: TTGSnackbar = TTGSnackbar.init(message: messageTextField.text!, duration: durationTypes[durationSegmented.selectedSegmentIndex])
        
        // Add icon image
        snackbar.icon = UIImage.init(named: "emoji_cool_small")
        
        snackbar.animationType = animationTypes[animationTypeSegmented!.selectedSegmentIndex]
        snackbar.show()
    }
    
    @IBAction func showWithActionIconImage(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let snackbar: TTGSnackbar = TTGSnackbar.init(message: messageTextField.text!, duration: durationTypes[durationSegmented.selectedSegmentIndex])
        
        // Add action icon image
        snackbar.actionIcon = UIImage.init(named: "emoji_cool_small")
        snackbar.actionBlock = { (snackbar) in self.outputLabel?.text = "Click icon !"}
        
        snackbar.animationType = animationTypes[animationTypeSegmented!.selectedSegmentIndex]
        snackbar.show()
    }
    
    @IBAction func showCustomContentView(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let snackbar: TTGSnackbar = TTGSnackbar.init(message: "", duration: durationTypes[durationSegmented.selectedSegmentIndex])
        
        // Change the content padding inset
        snackbar.contentInset = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
        
        // Change animation duration
        snackbar.animationDuration = 0.5
        
        // Animation type
        snackbar.animationType = animationTypes[animationTypeSegmented!.selectedSegmentIndex]
        
        // Get custom content view
        let customContentView = UINib.init(nibName: "CustomView", bundle:Bundle.main).instantiate(withOwner: nil, options: nil).first as! UIView?
        customContentView?.layer.masksToBounds = true
        customContentView?.layer.cornerRadius = 4
        snackbar.customContentView = customContentView
        
        snackbar.show()
    }
    
    @IBAction func showSnackbarManager(_ sender: UIButton){
        self.view.endEditing(true)
        
        let sb1 = snackbarManagerSimpleMessageExample(message: "Snackbar messsage 1")
        let sb2 = snackbarManagerSimpleMessageExample(message: "Snackbar messsage 2")
        
        let sba1 = snackbarManagerMessageWithActionExample(message: "Snackbar 1-action 1")
        let sba2 = snackbarManagerMessageWithActionExample(message: "Snackbar 1-action 2")
        
        let sba3 = snackbarManagerMessageWithTwoActionsExample(message: "Snackbar 2-action 3")
        let sba4 = snackbarManagerMessageWithTwoActionsExample(message: "Snackbar 2-action 4")
        
        
        TTGSnackbarManager.shared.show(snackbar: sba1)
        
        TTGSnackbarManager.shared.show(snackbar: sba2)
        
        TTGSnackbarManager.shared.show(snackbar: sba3)
        
        TTGSnackbarManager.shared.show(snackbar: sba4)
        
        TTGSnackbarManager.shared.show(snackbar: sb1)
        
        TTGSnackbarManager.shared.show(snackbar: sb2)
        
    }
    
    private func snackbarManagerSimpleMessageExample(message: String) -> TTGSnackbar {
        
        let snackbar: TTGSnackbar = TTGSnackbar.init(message: message, duration: durationTypes[durationSegmented.selectedSegmentIndex])
        
        // Change the content padding inset
        snackbar.contentInset = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
        
        // Change margin
        snackbar.leftMargin = 8
        snackbar.rightMargin = 8
        
        // Change message text font and color
        snackbar.messageTextColor = UIColor(red:0.22, green:0.29, blue:0.36, alpha:1.00)
        snackbar.messageTextFont = UIFont.boldSystemFont(ofSize: 18)
        
        // Change snackbar background color
        snackbar.backgroundColor = UIColor(red:0.30, green:0.72, blue:0.53, alpha:1.00)
        
        // Change animation duration
        snackbar.animationDuration = 0.5
        
        snackbar.dismissBlock = { (asb: TTGSnackbar) -> Void in
            self.outputLabel?.text = "\(message) dismissed."
        }
        
        // Animation type
        snackbar.animationType = animationTypes[animationTypeSegmented!.selectedSegmentIndex]
        
        return snackbar
    }
    
    private func snackbarManagerMessageWithActionExample(message: String) -> TTGSnackbar {
        let snackbar: TTGSnackbar = TTGSnackbar.init(message: message, duration: durationTypes[durationSegmented.selectedSegmentIndex],
                                                     actionText: actionTextField.text!, actionBlock: { (snackbar) in
                self.outputLabel?.text = "Click action! " + message }
        )
        
        // Change action text font and color
        snackbar.actionTextColor = UIColor.gray
        snackbar.actionTextFont = UIFont.boldSystemFont(ofSize: 16)
        
        // Change action max width
        snackbar.actionMaxWidth = 80
        
        // Change left and right margin
        snackbar.leftMargin = 12
        snackbar.rightMargin = 12
        
        // Change bottom margin
        snackbar.bottomMargin = 12
        
        // Change corner radius
        snackbar.cornerRadius = 2
                
        snackbar.dismissBlock = { (asb: TTGSnackbar) -> Void in
            self.outputLabel?.text = "\(message) dismissed."
        }
        
        // Change separate line back color
        snackbar.separateViewBackgroundColor = .yellow
        
        snackbar.animationType = animationTypes[animationTypeSegmented!.selectedSegmentIndex]
        
        return snackbar
    }
    
    private func snackbarManagerMessageWithTwoActionsExample(message: String) -> TTGSnackbar {
        
        let snackbar: TTGSnackbar = TTGSnackbar.init(message: message, duration: durationTypes[durationSegmented.selectedSegmentIndex])
        
        // Action 1
        snackbar.actionText = "Yes"
        snackbar.actionTextColor = UIColor.green
        snackbar.actionBlock = { (snackbar) in self.outputLabel?.text = "Click Yes !"}
        
        // Action 2
        snackbar.secondActionText = "No"
        snackbar.secondActionTextColor = UIColor.yellow
        snackbar.secondActionBlock = { (snackbar) in self.outputLabel?.text = "Click No !"}
        
        snackbar.animationType = animationTypes[animationTypeSegmented!.selectedSegmentIndex]
                
        snackbar.dismissBlock = { (asb: TTGSnackbar) -> Void in
            self.outputLabel?.text = "\(message) dismissed."
        }
        
        return snackbar
    }
}

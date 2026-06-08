//
//  TTGSnackbarLabel.swift
//  TTGSnackbar
//
//  Created by zekunyan on 15/10/4.
//  Copyright © 2015年 tutuge. All rights reserved.
//

import UIKit

open class TTGSnackbarLabel: UILabel {

    @objc open dynamic var contentInset: UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: contentInset)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(
            top: -contentInset.top,
            left: -contentInset.left,
            bottom: -contentInset.bottom,
            right: -contentInset.right)
        return textRect.inset(by: invertedInsets)
    }

    override open func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInset))
    }

}


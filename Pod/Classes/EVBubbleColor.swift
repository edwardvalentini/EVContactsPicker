//
//  EVBubbleColor.swift
//  Pods
//
//  Created by Edward Valentini on 8/29/15.
//
//

import UIKit

class EVBubbleColor: NSObject {

    var gradientTop : UIColor?
    var gradientBottom : UIColor?
    var border : UIColor?
    
    init(gradientTop: UIColor, gradientBottom: UIColor, border: UIColor) {
        super.init()
        self.gradientTop = gradientTop
        self.gradientBottom = gradientBottom
        self.border = border
    }

}

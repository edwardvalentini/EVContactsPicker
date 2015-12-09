//
//  EVBundle.swift
//  Pods
//
//  Created by Edward Valentini on 12/9/15.
//
//

import Foundation

extension NSBundle {
    class func evBundle() -> NSBundle {
        return NSBundle(forClass: EVContactsPickerViewController.self)
    }
    
    class func evAssetsBundle() -> NSBundle {
        let path : NSString = NSBundle.evBundle().resourcePath! as NSString
        let assetPath = path.stringByAppendingPathComponent("EVContactsPickerAssets.bundle")
        return NSBundle(path: assetPath)!

    }
    
    class func evLocalizedStringForKey(key: String) -> String {
        return NSLocalizedString(key, tableName: "EVContactsPicker", bundle: NSBundle.evAssetsBundle(), comment: "")
    }
}

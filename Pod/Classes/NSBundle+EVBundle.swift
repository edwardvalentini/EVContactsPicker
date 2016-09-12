//
//  EVBundle.swift
//  Pods
//
//  Created by Edward Valentini on 12/9/15.
//
//

import Foundation

public extension Bundle {
    public class func evBundle() -> Bundle {
        return Bundle(for: EVContactsPickerViewController.self)
    }
    
    
    public class func evAssetsBundle() -> Bundle {
        let path : NSString = Bundle.evBundle().resourcePath! as NSString
        let assetPath = path.appendingPathComponent("EVContactsPickerAssets.bundle")
        return Bundle(path: assetPath)!

    }
    
    public class func evLocalizedStringForKey(_ key: String) -> String {
        return NSLocalizedString(key, tableName: "EVContactsPicker", bundle: Bundle.evAssetsBundle(), comment: "")
    }
}

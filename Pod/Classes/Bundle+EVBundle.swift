//
//  EVBundle.swift
//  Pods
//
//  Created by Edward Valentini on 12/9/15.
//
//

import Foundation

let kBundleName = "EVContactsPicker.bundle"
let kTableName = "EVContactsPicker"
let kImagesDir = "images"

public extension Bundle {
    public class func evBundle() -> Bundle? {
        let bundle = Bundle(for: EVContactsPickerViewController.self)
        guard let pathOfBund = bundle.resourceURL else {
            return nil
        }
        
        let bundleURL = pathOfBund.appendingPathComponent(kBundleName)
        guard let frameworkBundle = Bundle(url: bundleURL) else {
            return nil
        }
        
        return frameworkBundle
    }
    
    public class func evLocalizedStringForKey(_ key: String) -> String? {
        guard let cab = Bundle.evBundle() else {
            return nil
        }
        return NSLocalizedString(key, tableName: "ChatloudKit", bundle: cab, comment: "")
    }
    
    public class func evImage(withName name: String, andExtension ext: String) -> UIImage? {
        guard let cab = Bundle.evBundle() else {
            return nil
        }
        
        guard let imagePath = cab.path(forResource: name, ofType: ext, inDirectory: kImagesDir) else {
            return nil
        }
        
        guard let image = UIImage(contentsOfFile: imagePath) else {
            return nil
        }
        
        return image
    }

}

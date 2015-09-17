//
//  EVContact.swift
//  Pods
//
//  Created by Edward Valentini on 8/29/15.
//
//

import UIKit

class EVContact: NSObject {
    var recordId : NSInteger?
    var firstName : String?
    var lastName : String?
    var phone : String?
    var email : String?
    var image : UIImage?
    var selected : Bool = false
    var date : NSDate?
    var dateUpdated : NSDate?
    
    init(attributes: [NSObject : AnyObject]) {
        super.init()
        self.setValuesForKeysWithDictionary(attributes)
    }
    
    override func setValue(value: AnyObject?, forKey key: String) {
        switch(key) {
            case "id" :
                self.recordId = value?.integerValue
            case "firstName" :
                self.firstName = value as! String?
            case "lastName" :
                self.lastName = value as! String?
            case "phone":
                self.phone = value as! String?
            case "email" :
                self.email = value as! String?
            case "image":
                self.image = value as! UIImage?
            case "isSelected" :
                self.selected = value!.boolValue!
            case "date" :
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                self.date = dateFormatter.dateFromString(value! as! String)
            case "dateUpdated" :
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                self.dateUpdated = dateFormatter.dateFromString(value! as! String)
            default :
                let i = 2
        }


    }
    
    func fullname() -> String {
        if(self.firstName != nil && self.lastName != nil) {
            return String(self.firstName! + " " + self.lastName!)
        } else if (self.firstName != nil) {
            return self.firstName!
        } else if (self.lastName != nil) {
            return self.lastName!
        } else {
            return ""
        }
    }
}

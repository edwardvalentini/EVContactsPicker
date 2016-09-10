//
//  EVContact.swift
//  Pods
//
//  Created by Edward Valentini on 8/29/15.
//
//

import UIKit

@objc open class EVContact: NSObject {
    open var identifier : String?
    open var firstName : String?
    open var lastName : String?
    open var phone : String?
    open var email : String?
    open var image : UIImage?
    var selected : Bool = false
    var date : Date?
    var dateUpdated : Date?
    
    public override init() {
        super.init()
    }
    
    public init(attributes: [String : AnyObject]) {
        super.init()
        self.setValuesForKeys(attributes)
    }
    
    override open func setValue(_ value: Any?, forKey key: String) {
        switch(key) {
            case "id" :
                self.identifier = value as! String?
                break
            case "firstName" :
                self.firstName = value as! String?
                break
            case "lastName" :
                self.lastName = value as! String?
                break
            case "phone":
                self.phone = value as! String?
                break
            case "email" :
                self.email = value as! String?
                break
            case "image":
                self.image = value as! UIImage?
                break
            case "isSelected" :
                self.selected = (value! as AnyObject).boolValue!
                break
            case "date" :
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                self.date = dateFormatter.date(from: value! as! String)
                break
            case "dateUpdated" :
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                self.dateUpdated = dateFormatter.date(from: value! as! String)
                break
            default :
                break
            
        }


    }
    
    open func fullname() -> String {
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

//
//  EVContact.swift
//  Pods
//
//  Created by Edward Valentini on 8/29/15.
//
//

import UIKit

//public func ==(lhs: EVContactProtocol, rhs: EVContactProtocol) -> Bool {
//    return lhs.identifier == rhs.identifier
//}

public protocol EVContactProtocol {
    var identifier : String { get set }
    var firstName : String? { get set }
    var lastName : String? { get set }
    var phone : String? { get set }
    var email : String? { get set }
    var image : UIImage? { get set }
    var imageURL : URL? { get set }
    var selected : Bool { get set }
    var date : Date? { get set }
    var dateUpdated : Date? { get set }
    
    func fullname() -> String?
}

extension EVContactProtocol {
    public func fullname() -> String? {
        if let firstName = self.firstName, let lastName = self.lastName {
            return String(firstName + " " + lastName)
        }
        if let firstName = self.firstName {
            return firstName
        }
        
        if let lastName = self.lastName {
            return lastName
        }
        return nil
    }
}



public struct EVContact: EVContactProtocol {
    public var identifier: String
    public var dateUpdated: Date? = nil
    public var date: Date? = nil
    public var selected: Bool = false
    public var image: UIImage? = nil
    public var imageURL : URL? = nil
    public var email: String? = nil
    public var phone: String? = nil
    public var lastName: String? = nil
    public var firstName: String? = nil
    
    public init(identifier: String) {
        self.identifier = identifier
    }
}

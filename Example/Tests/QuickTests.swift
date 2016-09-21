//
//  QuickTests.swift
//  EVContactsPicker
//
//  Created by Edward Valentini on 9/20/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import EVContactsPicker

class QuickTests: QuickSpec {
    override func spec() {
        
        it("initializes an EVContact ") {
            
            var contact = EVContact(identifier: UUID().uuidString)
            contact.firstName = "First"
            contact.lastName = "Last"
            contact.email = "some@example.com"
            
            expect(contact.fullname()).to(equal("First Last"))
            expect(contact.email).to(equal("some@example.com"))
        }

    }
}

//
//  EVContactsPickerDelegate.swift
//  Pods
//
//  Created by Edward Valentini on 9/19/15.
//
//

import Foundation

@objc public protocol EVContactsPickerDelegate : NSObjectProtocol {
    func didChooseContacts(contacts: [EVContact]? ) -> Void
}
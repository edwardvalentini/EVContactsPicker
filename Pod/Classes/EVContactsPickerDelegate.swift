//
//  EVContactsPickerDelegate.swift
//  Pods
//
//  Created by Edward Valentini on 9/19/15.
//
//

import Foundation

@objc public protocol EVContactsPickerDelegate : NSObjectProtocol {
    @objc func didChooseContacts(_ contacts: [EVContact]? ) -> Void
    @objc optional func shouldShowContact(_ contact: EVContact) -> Bool
}

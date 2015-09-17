//
//  EVPickedContactsViewDelegate.swift
//  Pods
//
//  Created by Edward Valentini on 8/29/15.
//
//

import Foundation

protocol EVPickedContactsViewDelegate : NSObjectProtocol {
    func contactPickerTextViewDidChange(textViewText: String) -> Void
    func contactPickerDidRemoveContact(contact: AnyObject) -> Void
    func contactPickerDidResize(pickedContactView: EVPickedContactsView) -> Void
}
//
//  EVPickedContactsViewDelegate.swift
//  Pods
//
//  Created by Edward Valentini on 8/29/15.
//
//

import Foundation

protocol EVPickedContactsViewDelegate : NSObjectProtocol {
    func contactPickerTextViewDidChange(_ textViewText: String) -> Void
    func contactPickerDidRemoveContact(_ contact: AnyObject) -> Void
    func contactPickerDidResize(_ pickedContactView: EVPickedContactsView) -> Void
}

//
//  EVContactBubbleDelegate.swift
//  Pods
//
//  Created by Edward Valentini on 8/29/15.
//
//

import Foundation

protocol EVContactBubbleDelegate : NSObjectProtocol {
    func contactBubbleWasSelected(contactBubble: EVContactBubble) -> Void
    func contactBubbleWasUnSelected(contactBubble: EVContactBubble) -> Void
    func contactBubbleShouldBeRemoved(contactBubble: EVContactBubble) -> Void
}
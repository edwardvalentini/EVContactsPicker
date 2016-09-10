//
//  EVContactBubbleDelegate.swift
//  Pods
//
//  Created by Edward Valentini on 8/29/15.
//
//

import Foundation

protocol EVContactBubbleDelegate : NSObjectProtocol {
    func contactBubbleWasSelected(_ contactBubble: EVContactBubble) -> Void
    func contactBubbleWasUnSelected(_ contactBubble: EVContactBubble) -> Void
    func contactBubbleShouldBeRemoved(_ contactBubble: EVContactBubble) -> Void
}

//
//  EVPickedContactsView.swift
//  Pods
//
//  Created by Edward Valentini on 8/29/15.
//
//

import UIKit

class EVPickedContactsView: UIView, EVContactBubbleDelegate, UITextViewDelegate, UIScrollViewDelegate {
    // MARK: - Private Variables
    
    fileprivate var _shouldSelectTextView = false
    fileprivate var scrollView : UIScrollView?
    fileprivate var contacts : [AnyHashable: EVContactBubble]?
    fileprivate var keyContacts : [AnyHashable : EVContactProtocol]?
    fileprivate var contactKeys : [AnyHashable]?
    fileprivate var placeholderLabel : UILabel?
    fileprivate var lineHeight : CGFloat?
    fileprivate var textView : UITextView?
    
    fileprivate var bubbleColor : EVBubbleColor?
    fileprivate var bubbleSelectedColor : EVBubbleColor?
    
    fileprivate let kViewPadding = CGFloat(5.0)
    fileprivate let kHorizontalPadding = CGFloat(2.0)
    fileprivate let kVerticalPadding = CGFloat(4.0)
    fileprivate let kTextViewMinWidth = CGFloat(130.0)
    
    // MARK: - Properties
    
    var selectedContactBubble : EVContactBubble?
    var delegate : EVPickedContactsViewDelegate?
    var limitToOne : Bool = false
    var viewPadding : CGFloat?
    var font : UIFont?
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    // MARK: - Public Methods
    
    func disableDropShadow() -> Void {
        let layer = self.layer
        layer.shadowRadius = 0.0
        layer.shadowOpacity = 0.0
    }
    
    func addContact(_ contact : EVContactProtocol, name: String) -> Void {

        guard let contactKeys = self.contactKeys else {
            return
        }
        
        let contactKey = contact.identifier

        if contactKeys.contains(contactKey) {
            return
        }
        
        self.textView?.text = ""
        
        let contactBubble = EVContactBubble(name: name, color: self.bubbleColor, selectedColor: self.bubbleSelectedColor)
        
        if let font = self.font {
            contactBubble.setFont(font)
        }
        
        contactBubble.delegate = self
        
        self.contacts?[contactKey] = contactBubble
        
        self.contactKeys?.append(contactKey)
        self.keyContacts?[contactKey] = contact
        
        self.layoutView()
        
        self.textView?.isHidden = false
        self.textView?.text = ""
        
        self.scrollToBottomWithAnimation(false)
        
    }
    
    func selectTextView() -> Void {
        self.textView?.isHidden = false
    }
    
    func removeAllContacts() -> Void {
        for ( _ , kValue) in self.contacts! {
            kValue.removeFromSuperview()
        }
        
        self.contacts?.removeAll()
        self.contactKeys?.removeAll()
        
        self.layoutView()
        
        self.textView?.isHidden = false
        self.textView?.text = ""
    }
    
    func removeContact(_ contact : EVContactProtocol) -> Void {
        // let contactKey = NSValue(nonretainedObject: contact)
            let contactKey = contact.identifier

            if let contacts = self.contacts {
                if let contactBubble = contacts[contactKey] {
                    contactBubble.removeFromSuperview()
                    _ = self.contacts?.removeValue(forKey: contactKey)
                    _ = self.keyContacts?.removeValue(forKey: contactKey)
                    
                    if let foundIndex = self.contactKeys?.index(of: contactKey) {
                        self.contactKeys?.remove(at: foundIndex)
                    }
                    
                    self.layoutView()
                    
                    self.textView?.isHidden = false
                    self.textView?.text = ""
                    
                    self.scrollToBottomWithAnimation(false)
                }
            }
    }
    
    
    func setPlaceHolderString(_ placeHolderString: String) -> Void {
        self.placeholderLabel?.text = placeHolderString
        self.layoutView()
    }
    
    func resignKeyboard() -> Void {
        self.textView?.resignFirstResponder()
    }
    
    func setBubbleColor(_ color: EVBubbleColor, selectedColor:EVBubbleColor) -> Void {
        self.bubbleColor = color
        self.bubbleSelectedColor = selectedColor
        
        for contactKey in self.contactKeys! {
            if let contacts = contacts {
                if let contactBubble = contacts[contactKey] {
                    contactBubble.color = color
                    contactBubble.selectedColor = selectedColor
                    if(contactBubble.isSelected) {
                        contactBubble.select()
                    } else {
                        contactBubble.unSelect()
                    }
                }
            }
        }
    }
    
    

    
    

    // MARK: - Private Methods
    
    fileprivate func setup() -> Void {
        self.viewPadding = kViewPadding
        
        self.contacts = [:]
        self.contactKeys = []
        self.keyContacts = [:]
        
        let contactBubble = EVContactBubble(name: "Sample")
        self.lineHeight = contactBubble.frame.size.height + 2 + kVerticalPadding
        
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView?.scrollsToTop = false
        self.scrollView?.delegate = self
        self.addSubview(self.scrollView!)
        
        self.textView = UITextView()
        self.textView?.delegate = self
        self.textView?.font = contactBubble.label?.font
        self.textView?.backgroundColor = UIColor.clear
        self.textView?.contentInset = UIEdgeInsetsMake(-4.0, -2.0, 0, 0)
        self.textView?.isScrollEnabled = false
        self.textView?.scrollsToTop = false
        self.textView?.clipsToBounds = false
        self.textView?.autocorrectionType = UITextAutocorrectionType.no
        
        self.backgroundColor = UIColor.white
        let layer = self.layer
        layer.shadowColor = UIColor(red: 225.0/255.0, green: 226.0/255.0, blue: 228.0/255.0, alpha: 1.0).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 1.0
        
        self.placeholderLabel = UILabel(frame: CGRect(x: 8, y: self.viewPadding!, width: self.frame.size.width, height: self.lineHeight!))
        self.placeholderLabel?.font = contactBubble.label?.font
        self.placeholderLabel?.backgroundColor = UIColor.clear
        self.placeholderLabel?.textColor = UIColor.gray
        self.addSubview(self.placeholderLabel!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EVPickedContactsView.handleTapGesture))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    
    func scrollToBottomWithAnimation(_ animated : Bool) -> Void {
        if(animated) {
            let size = self.scrollView?.contentSize
            let frame = CGRect(x: 0, y: size!.height - (self.scrollView?.frame.size.height)!, width: size!.width, height: (self.scrollView?.frame.size.height)!)
            
            self.scrollView?.scrollRectToVisible(frame, animated: animated)
        } else {
            var offset = self.scrollView?.contentOffset
            offset?.y = (self.scrollView?.contentSize.height)! - (self.scrollView?.frame.size.height)!
            self.scrollView?.contentOffset = offset!
        }
    }
    
    func removeContactBubble(_ contactBubble : EVContactBubble) -> Void {
        if let contactKey = self.contactForContactBubble(contactBubble), let keyContacts = self.keyContacts, let contact = keyContacts[contactKey] {
            self.delegate?.contactPickerDidRemoveContact(contact)
            self.removeContactByKey(contactKey)
        }
    }
    
    func removeContactByKey(_ contactKey : AnyHashable) -> Void {
        
        guard let contacts = self.contacts else {
            return
        }
        
        if let contactBubble = contacts[contactKey] {
            contactBubble.removeFromSuperview()
            
            let _ = self.contacts?.removeValue(forKey: contactKey)
            
            if let foundIndex = self.contactKeys?.index(of: contactKey) {
                self.contactKeys?.remove(at: foundIndex)
            }
            
            self.layoutView()
            
            self.textView?.isHidden = false
            self.textView?.text = ""
            
            self.scrollToBottomWithAnimation(false)
        }
    }
    
    func contactForContactBubble(_ contactBubble : EVContactBubble) -> AnyHashable? {
        
        guard let contacts = self.contacts else {
            return nil
        }
        
        var returnKey : AnyHashable? = nil
        
        contacts.forEach { (key: AnyHashable, value: EVContactBubble) in
            if let valueForKey = contacts[key], valueForKey.isEqual(contactBubble) {
                returnKey = key
            }
        }
    
        return returnKey
    }
    
    
    func layoutView() -> Void {
        var frameOfLastBubble = CGRect.null
        var lineCount = 0
        
        for contactKey in self.contactKeys! {
            if let contacts = self.contacts, let contactBubble = contacts[contactKey] { // as EVContactBubble {
            
                var bubbleFrame = contactBubble.frame
                
                if(frameOfLastBubble.isNull) {
                    bubbleFrame.origin.x = kHorizontalPadding
                    bubbleFrame.origin.y = kVerticalPadding + self.viewPadding!
                } else {
                    let width = bubbleFrame.size.width + 2 * kHorizontalPadding
                    if( self.frame.size.width - frameOfLastBubble.origin.x - frameOfLastBubble.size.width - width >= 0) {
                        
                        bubbleFrame.origin.x = frameOfLastBubble.origin.x + frameOfLastBubble.size.width + kHorizontalPadding * 2
                        bubbleFrame.origin.y = frameOfLastBubble.origin.y
                    } else {
                        lineCount += 1
                        bubbleFrame.origin.x = kHorizontalPadding
                        bubbleFrame.origin.y = (CGFloat(lineCount) * self.lineHeight!) + kVerticalPadding + 	self.viewPadding!
                    }
                }
                
                frameOfLastBubble = bubbleFrame
                contactBubble.frame = bubbleFrame
                
                if (contactBubble.superview == nil){
                    self.scrollView?.addSubview(contactBubble)
                }
            }
        }
        
        let minWidth = kTextViewMinWidth + 2 * kHorizontalPadding
        var textViewFrame = CGRect(x: 0, y: 0, width: (self.textView?.frame.size.width)!, height: self.lineHeight!)
        
        if (self.frame.size.width - frameOfLastBubble.origin.x - frameOfLastBubble.size.width - minWidth >= 0){ // add to the same line
            textViewFrame.origin.x = frameOfLastBubble.origin.x + frameOfLastBubble.size.width + kHorizontalPadding
            textViewFrame.size.width = self.frame.size.width - textViewFrame.origin.x
        } else { // place text view on the next line
            lineCount += 1
            
            textViewFrame.origin.x = kHorizontalPadding
            textViewFrame.size.width = self.frame.size.width - 2 * kHorizontalPadding
            
            if (self.contacts?.count == 0){
                lineCount = 0
                textViewFrame.origin.x = kHorizontalPadding
            }
        }
        textViewFrame.origin.y = CGFloat(lineCount) * self.lineHeight! + kVerticalPadding + self.viewPadding!
        self.textView?.frame = textViewFrame

        if (self.textView?.superview == nil){
            self.scrollView?.addSubview(self.textView!)
        }
        
        if (self.limitToOne && (self.contacts?.count)! >= 1){
            self.textView?.isHidden = true;
            lineCount = 0;
        }
        
        var frame = self.bounds
        let maxFrameHeight = 2 * self.lineHeight! + 2 * self.viewPadding!
        var newHeight = (CGFloat(lineCount) + 1.0) * self.lineHeight! + 2 * self.viewPadding!
        
        self.scrollView?.contentSize = CGSize(width: (self.scrollView?.frame.size.width)!, height: newHeight)
        
        newHeight = (newHeight > maxFrameHeight) ? maxFrameHeight : newHeight;
        if (self.frame.size.height != newHeight){
            // Adjust self height
            var selfFrame = self.frame
            selfFrame.size.height = newHeight
            self.frame = selfFrame
            
            // Adjust scroll view height
            frame.size.height = newHeight
            self.scrollView?.frame = frame
            
            self.delegate?.contactPickerDidResize(self)

        }
        
        // Show placeholder if no there are no contacts
        if (self.contacts?.count == 0){
            self.placeholderLabel?.isHidden = false
        } else {
            self.placeholderLabel?.isHidden = true
        }
    }
    
    
    // MARK: - UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        self.textView?.isHidden = false
        if( text == "\n" ) {
            return false
        }
        
        if( textView.text == "" && text == "" ) {
            if let contactKey = self.contactKeys?.last {
                if let contacts = self.contacts {
                    self.selectedContactBubble = (contacts[contactKey])
                    self.selectedContactBubble?.select()
                }
            }
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.delegate?.contactPickerTextViewDidChange(textView.text)
        
        if( textView.text == "" && self.contacts?.count == 0) {
            self.placeholderLabel?.isHidden = false
        } else {
            self.placeholderLabel?.isHidden = true
        }
        
    }
    
    // MARK: - EVContactBubbleDelegate Methods
    
    func contactBubbleWasSelected(_ contactBubble: EVContactBubble) -> Void {
        if( self.selectedContactBubble != nil ) {
            self.selectedContactBubble?.unSelect()
        }
        
        self.selectedContactBubble = contactBubble
        self.textView?.resignFirstResponder()
        self.textView?.text = ""
        self.textView?.isHidden = true
    }
    
    func contactBubbleWasUnSelected(_ contactBubble: EVContactBubble) -> Void {
        self.textView?.becomeFirstResponder()
        self.textView?.text = ""
        self.textView?.isHidden = false
    }
    
    func contactBubbleShouldBeRemoved(_ contactBubble: EVContactBubble) -> Void {
        self.removeContactBubble(contactBubble)
    }
    
    // MARK: - Gesture Recognizer
    
    func handleTapGesture() -> Void {
        if(self.limitToOne && self.contactKeys?.count == 1) {
            return
        }
        
        self.scrollToBottomWithAnimation(true)
        
        self.textView?.isHidden = false
        self.textView?.becomeFirstResponder()
        
        self.selectedContactBubble?.unSelect()
        self.selectedContactBubble = nil
        
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if(_shouldSelectTextView) {
            _shouldSelectTextView = false
            self.selectTextView()
        }
    }
    
}

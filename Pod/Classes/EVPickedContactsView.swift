//
//  EVPickedContactsView.swift
//  Pods
//
//  Created by Edward Valentini on 8/29/15.
//
//

import UIKit

class EVPickedContactsView: UIView, EVContactBubbleDelegate, UITextViewDelegate, UIScrollViewDelegate {

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
    
    func addContact(contact : EVContact, name: String) -> Void {
        let contactKey = NSValue(nonretainedObject: contact)
        
        
        if(self.contactKeys!.contains(contactKey)) {
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
        
        self.layoutView()
        
        self.textView?.hidden = false
        self.textView?.text = ""
        
        self.scrollToBottomWithAnimation(false)
        
    }
    
    func selectTextView() -> Void {
        self.textView?.hidden = false
    }
    
    func removeAllContacts() -> Void {
        for ( _ , kValue) in self.contacts! {
            let contactBubble : EVContactBubble = kValue as! EVContactBubble
            contactBubble.removeFromSuperview()
        }
        
        self.contacts?.removeAll()
        self.contactKeys?.removeAll()
        
        self.layoutView()
        
        self.textView?.hidden = false
        self.textView?.text = ""
    }
    
    func removeContact(contact : EVContact) -> Void {
         let contactKey = NSValue(nonretainedObject: contact)

            if let contacts = self.contacts {
                if let contactBubble = contacts[contactKey] as? EVContactBubble {
                    contactBubble.removeFromSuperview()
                    self.contacts?.removeValueForKey(contactKey)
                    
                    if let foundIndex = self.contactKeys?.indexOf(contactKey) {
                        self.contactKeys?.removeAtIndex(foundIndex)
                    }
                    
                    self.layoutView()
                    
                    self.textView?.hidden = false
                    self.textView?.text = ""
                    
                    self.scrollToBottomWithAnimation(false)
                }
            }
    }
    
    
    func setPlaceHolderString(placeHolderString: String) -> Void {
        self.placeholderLabel?.text = placeHolderString
        self.layoutView()
    }
    
    func resignKeyboard() -> Void {
        self.textView?.resignFirstResponder()
    }
    
    func setBubbleColor(color: EVBubbleColor, selectedColor:EVBubbleColor) -> Void {
        self.bubbleColor = color
        self.bubbleSelectedColor = selectedColor
        
        for contactKey in self.contactKeys! {
            let contactBubble = self.contacts?[contactKey] as! EVContactBubble
            contactBubble.color = color
            contactBubble.selectedColor = selectedColor
            if(contactBubble.isSelected) {
                contactBubble.select()
            } else {
                contactBubble.unSelect()
            }
        }
    }
    
    
    // MARK: - Private Variables
    
    private var _shouldSelectTextView = false
    private var scrollView : UIScrollView?
    private var contacts : [NSObject : AnyObject]?
    private var contactKeys : [NSObject]?
    private var placeholderLabel : UILabel?
    private var lineHeight : CGFloat?
    private var textView : UITextView?
    
    private var bubbleColor : EVBubbleColor?
    private var bubbleSelectedColor : EVBubbleColor?
    
    private let kViewPadding = CGFloat(5.0)
    private let kHorizontalPadding = CGFloat(2.0)
    private let kVerticalPadding = CGFloat(4.0)
    private let kTextViewMinWidth = CGFloat(130.0)
    
    

    // MARK: - Private Methods
    
    private func setup() -> Void {
        self.viewPadding = kViewPadding
        
        self.contacts = [:]
        self.contactKeys = []
        
        let contactBubble = EVContactBubble(name: "Sample")
        self.lineHeight = contactBubble.frame.size.height + 2 + kVerticalPadding
        
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView?.scrollsToTop = false
        self.scrollView?.delegate = self
        self.addSubview(self.scrollView!)
        
        self.textView = UITextView()
        self.textView?.delegate = self
        self.textView?.font = contactBubble.label?.font
        self.textView?.backgroundColor = UIColor.clearColor()
        self.textView?.contentInset = UIEdgeInsetsMake(-4.0, -2.0, 0, 0)
        self.textView?.scrollEnabled = false
        self.textView?.scrollsToTop = false
        self.textView?.clipsToBounds = false
        self.textView?.autocorrectionType = UITextAutocorrectionType.No
        
        self.backgroundColor = UIColor.whiteColor()
        let layer = self.layer
        layer.shadowColor = UIColor(red: 225.0/255.0, green: 226.0/255.0, blue: 228.0/255.0, alpha: 1.0).CGColor
        layer.shadowOffset = CGSizeMake(0, 2)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 1.0
        
        self.placeholderLabel = UILabel(frame: CGRectMake(8, self.viewPadding!, self.frame.size.width, self.lineHeight!))
        self.placeholderLabel?.font = contactBubble.label?.font
        self.placeholderLabel?.backgroundColor = UIColor.clearColor()
        self.placeholderLabel?.textColor = UIColor.grayColor()
        self.addSubview(self.placeholderLabel!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EVPickedContactsView.handleTapGesture))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    
    func scrollToBottomWithAnimation(animated : Bool) -> Void {
        if(animated) {
            let size = self.scrollView?.contentSize
            let frame = CGRectMake(0, size!.height - (self.scrollView?.frame.size.height)!, size!.width, (self.scrollView?.frame.size.height)!)
            
            self.scrollView?.scrollRectToVisible(frame, animated: animated)
        } else {
            var offset = self.scrollView?.contentOffset
            offset?.y = (self.scrollView?.contentSize.height)! - (self.scrollView?.frame.size.height)!
            self.scrollView?.contentOffset = offset!
        }
    }
    
    func removeContactBubble(contactBubble : EVContactBubble) -> Void {
        let contact = self.contactForContactBubble(contactBubble)
        if(contact == nil) {
            return
        }
        
        if(( self.delegate?.respondsToSelector(Selector("contactPickerDidRemoveContact:"))) != nil) {
            self.delegate?.contactPickerDidRemoveContact((contact?.nonretainedObjectValue)!)
        }
        
        self.removeContactByKey(contact!)
    }
    
    func removeContactByKey(contactKey : AnyObject) -> Void {
        let contactBubble = self.contacts?[contactKey as! NSObject] as! EVContactBubble
        contactBubble.removeFromSuperview()
        
        self.contacts?.removeValueForKey(contactKey as! NSObject)
        
        if let foundIndex = self.contactKeys?.indexOf(contactKey as! NSObject) {
            self.contactKeys?.removeAtIndex(foundIndex)
        }
        
        self.layoutView()
        
        self.textView?.hidden = false
        self.textView?.text = ""
        
        self.scrollToBottomWithAnimation(false)
    }
    
    func contactForContactBubble(contactBubble : EVContactBubble) -> AnyObject? {
        
        let keys = self.contacts?.keys
        
        for contact in keys! {
            if((self.contacts?[contact]?.isEqual(contactBubble)) != nil) {
                return contact
            }
        }
        return nil
    }
    
    
    func layoutView() -> Void {
        var frameOfLastBubble = CGRectNull
        var lineCount = 0
        
        for contactKey in self.contactKeys! {
            let contactBubble = self.contacts?[contactKey] as! EVContactBubble
            var bubbleFrame = contactBubble.frame
            
            if(CGRectIsNull(frameOfLastBubble)) {
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
        
        let minWidth = kTextViewMinWidth + 2 * kHorizontalPadding
        var textViewFrame = CGRectMake(0, 0, (self.textView?.frame.size.width)!, self.lineHeight!)
        
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
        
        if (self.limitToOne && self.contacts?.count >= 1){
            self.textView?.hidden = true;
            lineCount = 0;
        }
        
        var frame = self.bounds
        let maxFrameHeight = 2 * self.lineHeight! + 2 * self.viewPadding!
        var newHeight = (CGFloat(lineCount) + 1.0) * self.lineHeight! + 2 * self.viewPadding!
        
        self.scrollView?.contentSize = CGSizeMake((self.scrollView?.frame.size.width)!, newHeight)
        
        newHeight = (newHeight > maxFrameHeight) ? maxFrameHeight : newHeight;
        if (self.frame.size.height != newHeight){
            // Adjust self height
            var selfFrame = self.frame
            selfFrame.size.height = newHeight
            self.frame = selfFrame
            
            // Adjust scroll view height
            frame.size.height = newHeight
            self.scrollView?.frame = frame
            
            if(( self.delegate?.respondsToSelector(Selector("contactPickerDidResize:"))) != nil) {
                self.delegate?.contactPickerDidResize(self)
            }

        }
        
        // Show placeholder if no there are no contacts
        if (self.contacts?.count == 0){
            self.placeholderLabel?.hidden = false
        } else {
            self.placeholderLabel?.hidden = true
        }
    }
    
    
    // MARK: - UITextViewDelegate
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        self.textView?.hidden = false
        if( text == "\n" ) {
            return false
        }
        
        if( textView.text == "" && text == "" ) {
            if let contactKey = self.contactKeys?.last {
                self.selectedContactBubble = (self.contacts?[contactKey] as! EVContactBubble)
                self.selectedContactBubble?.select()
            }
        }
        
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        if(( self.delegate?.respondsToSelector(Selector("contactPickerTextViewDidChange:"))) != nil) {
            self.delegate?.contactPickerTextViewDidChange(textView.text)
        }
        
        if( textView.text == "" && self.contacts?.count == 0) {
            self.placeholderLabel?.hidden = false
        } else {
            self.placeholderLabel?.hidden = true
        }
        
    }
    
    // MARK: - EVContactBubbleDelegate Methods
    
    func contactBubbleWasSelected(contactBubble: EVContactBubble) -> Void {
        if( self.selectedContactBubble != nil ) {
            self.selectedContactBubble?.unSelect()
        }
        
        self.selectedContactBubble = contactBubble
        self.textView?.resignFirstResponder()
        self.textView?.text = ""
        self.textView?.hidden = true
    }
    
    func contactBubbleWasUnSelected(contactBubble: EVContactBubble) -> Void {
        self.textView?.becomeFirstResponder()
        self.textView?.text = ""
        self.textView?.hidden = false
    }
    
    func contactBubbleShouldBeRemoved(contactBubble: EVContactBubble) -> Void {
        self.removeContactBubble(contactBubble)
    }
    
    // MARK: - Gesture Recognizer
    
    func handleTapGesture() -> Void {
        if(self.limitToOne && self.contactKeys?.count == 1) {
            return
        }
        
        self.scrollToBottomWithAnimation(true)
        
        self.textView?.hidden = false
        self.textView?.becomeFirstResponder()
        
        self.selectedContactBubble?.unSelect()
        self.selectedContactBubble = nil
        
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if(_shouldSelectTextView) {
            _shouldSelectTextView = false
            self.selectTextView()
        }
    }
    
}

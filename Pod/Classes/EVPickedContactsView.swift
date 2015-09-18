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
    func addContact(contact : AnyObject, name: String) -> Void {
        //let contactKey = NSValue(nonretainedObject: contact)
        //if(self.contactKeys?)
        
        //if()
    }
    
    func removeContact(contact : AnyObject) -> Void {
        
    }
    
    func removeAllContacts() -> Void {
        
    }
    
    func setPlaceHolderString(placeHolderString: String) -> Void {
        
    }
    
    func disableDropShadow() -> Void {
        
    }
    
    func resignKeyboard() -> Void {
        
    }
    
    func setBubbleColor(color: EVBubbleColor, selectedColor:EVBubbleColor) -> Void {
        
    }

    
    // MARK: - EVContactBubbleDelegate Methods
    
    func contactBubbleWasSelected(contactBubble: EVContactBubble) -> Void {
        
    }
    
    func contactBubbleWasUnSelected(contactBubble: EVContactBubble) -> Void {
        
    }
    
    func contactBubbleShouldBeRemoved(contactBubble: EVContactBubble) -> Void {
        
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTapGesture"))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapGesture)
        
    }
    
    func handleTapGesture() -> Void {
        
    }
    
    
    
    
}

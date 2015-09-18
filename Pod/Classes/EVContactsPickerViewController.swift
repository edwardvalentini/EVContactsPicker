//
//  EVContactsPickerViewController.swift
//  EVContactsPicker
//
//  Created by Edward Valentini on 9/18/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI


public class EVContactsPickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,  EVPickedContactsViewDelegate, ABPersonViewControllerDelegate {
    
    let kKeyboardHeight : CGFloat = 0.0
    
    var contactPickerView : EVPickedContactsView? = nil
    var addressBookRef : ABAddressBookRef? = nil
    var tableView : UITableView? = nil
    var contacts : [AnyObject]? = nil
    var selectedContacts : [AnyObject]? = nil
    var filteredContacts : [AnyObject]? = nil
    var barButton : UIBarButtonItem? = nil
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title  = "Select Contacts (0)"
        var err : Unmanaged<CFError>? = nil
        addressBookRef = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        barButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: Selector("done"))
        barButton?.enabled = false
        self.navigationItem.rightBarButtonItem = barButton
        
        self.contactPickerView = EVPickedContactsView(frame: CGRectMake(0, 0, self.view.frame.size.width, 100))
        self.contactPickerView?.delegate = self
        self.contactPickerView?.setPlaceHolderString("Type Contact Name")
        self.view.addSubview(self.contactPickerView!)
        
        
        self.tableView = UITableView(frame: CGRectMake(0, self.contactPickerView!.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.contactPickerView!.frame.size.height - kKeyboardHeight), style: .Plain)
        
        self.tableView?.delegate  = self
        self.tableView?.dataSource = self
        
        self.tableView?.registerNib(UINib(nibName: "EVContactsPickerTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactCell")
        self.view.insertSubview(self.tableView!, belowSubview: self.contactPickerView!)
        
        ABAddressBookRequestAccessWithCompletion(self.addressBookRef!) { (granted : Bool, error: CFError!) -> Void in
            if(granted) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.getContactsFromAddressBook()
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    print("show UIalert for problem")
                })
            }
        }
        
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Addressbook
    
    func getContactsFromAddressBook() -> Void {
        
        var err : Unmanaged<CFError>? = nil
        let addressBook = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
        self.contacts = []

        let allContacts = ABAddressBookCopyArrayOfAllPeople(addressBook)
        var mutableContacts : [AnyObject] = []
        
        var i = 0
        
        for tmpContact in allContacts {
            
        }

        
        
    }

    public func personViewController(personViewController: ABPersonViewController, shouldPerformDefaultActionForPerson person: ABRecord, property: ABPropertyID, identifier: ABMultiValueIdentifier) -> Bool {
        return true
    }
    
    
    // MARK: - TableView
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "contactCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if( cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }
        
        return cell!
    }
    
    public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // MARK: - EVPickedContactsViewDelegate
    
    func contactPickerTextViewDidChange(textViewText: String) -> Void {
        
    }
    
    func contactPickerDidRemoveContact(contact: AnyObject) -> Void {
        
    }
    
    func contactPickerDidResize(pickedContactView: EVPickedContactsView) -> Void {
        
    }
    
    // MARK: - Miscellaneous

    func done(sender: AnyObject) -> Void {
        let alertView = UIAlertController(title: "Done!", message: "Finish App", preferredStyle: .Alert)
        self.presentViewController(alertView, animated: true, completion: nil)
    }

}

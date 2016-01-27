//
//  EVContactsPickerViewController.swift
//  EVContactsPicker
//
//  Created by Edward Valentini on 9/18/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
//import AddressBook
//import AddressBookUI
import Contacts
import ContactsUI


/*
let kAvatarImage =  "icon-avatar-60x60"
let kSelectedCheckbox = "icon-checkbox-selected-green-25x25"
let kUnselectedCheckbox = "icon-checkbox-unselected-25x25"
*/


@available(iOS 9.0, *)
@objc public class EVContactsPickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,  EVPickedContactsViewDelegate, CNContactViewControllerDelegate {
    
    let kKeyboardHeight : CGFloat = 0.0
    
    var contactPickerView : EVPickedContactsView? = nil
    var store : CNContactStore? = nil
    var tableView : UITableView? = nil
    var contacts : [EVContact]? = nil
    var selectedContacts : [EVContact]? = nil
    var filteredContacts : [EVContact]? = nil
    var barButton : UIBarButtonItem? = nil
    //var contactPickerMode : EVContactModeOption! = .Internal
    var useExternal : Bool = false
    var externalDataSource : [EVContact]? = nil
    
    public var delegate : EVContactsPickerDelegate?
    private var curBundle : NSBundle?
    
    
    lazy var avatarImage : UIImage = {
       let bundle = NSBundle.evAssetsBundle()
       let path = bundle.pathForResource(kAvatarImage, ofType: "png", inDirectory: "Images")
       return UIImage(named: path!)!
    }()
    
    lazy var selectedCheckbox : UIImage = {
        let bundle = NSBundle.evAssetsBundle()
        let path = bundle.pathForResource(kSelectedCheckbox, ofType: "png", inDirectory: "Images")
        return UIImage(named: path!)!
    }()
    
    lazy var unselectedCheckbox : UIImage = {
        let bundle = NSBundle.evAssetsBundle()
        let path = bundle.pathForResource(kUnselectedCheckbox, ofType: "png", inDirectory: "Images")
        return UIImage(named: path!)!
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setup()
    }
    
    public init(externalDataSource: [EVContact]!) {
        self.init()
        self.useExternal = true
        self.externalDataSource = externalDataSource
        self.setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()

    }
    
    func setup() -> Void {
        self.title  = NSBundle.evLocalizedStringForKey("Selected Contacts") + "(0)"
        self.curBundle = NSBundle(forClass: self.dynamicType)
        if( self.useExternal == false ) {
            self.store = CNContactStore()
        }

    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        barButton = UIBarButtonItem(title: NSBundle.evLocalizedStringForKey("Done"), style: .Done, target: self, action: Selector("done:"))
        barButton?.enabled = false
        self.navigationItem.rightBarButtonItem = barButton
        
        self.contactPickerView = EVPickedContactsView(frame: CGRectMake(0, 0, self.view.frame.size.width, 100))
        self.contactPickerView?.delegate = self
        self.contactPickerView?.setPlaceHolderString(NSBundle.evLocalizedStringForKey("Type Contact Name"))
        self.view.addSubview(self.contactPickerView!)
        
        
        self.tableView = UITableView(frame: CGRectMake(0, self.contactPickerView!.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.contactPickerView!.frame.size.height - kKeyboardHeight), style: .Plain)
        
        self.tableView?.delegate  = self
        self.tableView?.dataSource = self
        

        
        self.tableView?.registerNib(UINib(nibName: "EVContactsPickerTableViewCell", bundle: self.curBundle), forCellReuseIdentifier: "contactCell")
        self.view.insertSubview(self.tableView!, belowSubview: self.contactPickerView!)
        
        if( self.useExternal == false ) {
            self.store?.requestAccessForEntityType(.Contacts, completionHandler: { (granted : Bool, error: NSError?) -> Void in
                if(granted) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.getContactsFromAddressBook()
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        print("show UIalert for problem")
                    })
                }
            })
        } else {
            self.contacts = self.externalDataSource
            self.selectedContacts = []
            self.filteredContacts = self.contacts
            self.tableView?.reloadData()
        }
    }
    
    override public func viewWillAppear(animated: Bool) -> Void {
        super.viewWillAppear(animated)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.refreshContacts()
        }
    }
    
    override public func viewDidLayoutSubviews() -> Void {
        super.viewDidLayoutSubviews()
        var topOffset : CGFloat = 0.0
        if( self.respondsToSelector(Selector("topLayoutGuide"))) {
            topOffset = self.topLayoutGuide.length
        }
        self.contactPickerView?.frame.origin.y = topOffset
        self.adjustTableViewFrame(false)
    }
    
    func adjustTableViewFrame(animated: Bool) -> Void {
        var frame = self.tableView?.frame
        frame?.origin.y = (self.contactPickerView?.frame.size.height)!
        frame?.size.height = self.view.frame.size.height - (self.contactPickerView?.frame.size.height)! - kKeyboardHeight
        if( animated ) {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.3)
            UIView.setAnimationDelay(0.1)
            UIView.setAnimationCurve(.EaseOut)
            self.tableView?.frame = frame!
            UIView.commitAnimations()
        } else {
            self.tableView?.frame = frame!
        }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Addressbook
    
    func getContactsFromAddressBook() -> Void {
        
        self.contacts = []
        var mutableContacts : [EVContact] = []
        
        let req : CNContactFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactEmailAddressesKey,CNContactGivenNameKey,CNContactFamilyNameKey,CNContactImageDataAvailableKey,CNContactThumbnailImageDataKey,CNContactImageDataKey,CNContactPhoneNumbersKey])
        
        do {
            try self.store?.enumerateContactsWithFetchRequest(req, usingBlock: { (contact: CNContact, boolprop : UnsafeMutablePointer<ObjCBool> ) -> Void in
                
                let tmpContact = EVContact()
                tmpContact.identifier = contact.identifier
                tmpContact.firstName = contact.givenName
                tmpContact.lastName = contact.familyName
                if (contact.phoneNumbers.count > 0) {
                    tmpContact.phone = (contact.phoneNumbers[0].value as! CNPhoneNumber).stringValue

                }
                if (contact.emailAddresses.count > 0) {
                    tmpContact.email = (contact.emailAddresses[0].value as! String)
                }
                
                if(contact.imageDataAvailable) {
                    let imgData = contact.imageData
                    let img = UIImage(data: imgData!)
                    tmpContact.image = img
                } else {
//                    let imPath = self.curBundle?.pathForResource(kAvatarImage, ofType: "png", inDirectory: "EVContactsPicker.bundle")
//                    let im = UIImage(contentsOfFile: imPath!)
                    tmpContact.image = self.avatarImage
                }
                
                mutableContacts.append(tmpContact)
                self.contacts = mutableContacts
                self.selectedContacts = []
                self.filteredContacts = self.contacts
                self.tableView?.reloadData()
                
            })
        } catch {
            print("error occured")
        }
  
    }
    
    func refreshContacts() -> Void {
        if let contacts = self.contacts {
            for contact in contacts {
                self.refreshContact(contact)
            }
        }
        self.tableView?.reloadData()
    }

    func refreshContact(contact: EVContact) {
        if( self.useExternal == false ) {
            do {
                if let tmpContact = try self.store?.unifiedContactWithIdentifier(contact.identifier!, keysToFetch: [CNContactEmailAddressesKey,CNContactGivenNameKey,CNContactFamilyNameKey,CNContactImageDataAvailableKey,CNContactThumbnailImageDataKey,CNContactImageDataKey,CNContactPhoneNumbersKey]) {
                    contact.identifier = tmpContact.identifier
                    contact.firstName = tmpContact.givenName
                    contact.lastName = tmpContact.familyName
                    if (tmpContact.phoneNumbers.count > 0) {
                        contact.phone = (tmpContact.phoneNumbers[0].value as! CNPhoneNumber).stringValue
                        
                    }
                    if (tmpContact.emailAddresses.count > 0) {
                        contact.email = (tmpContact.emailAddresses[0].value as! String)
                    }

                    
                    if(tmpContact.imageDataAvailable) {
                        let imgData = tmpContact.imageData
                        let img = UIImage(data: imgData!)
                        contact.image = img
                    } else {
//                        let imPath = self.curBundle?.pathForResource(kAvatarImage, ofType: "png", inDirectory: "EVContactsPicker.bundle")
//                        let im = UIImage(contentsOfFile: imPath!)
                        
                        contact.image = self.avatarImage
                    }
                }
            } catch {
                print("error")
            }
        } else {
            if(contact.image == nil) {
//                let imPath = self.curBundle?.pathForResource(kAvatarImage, ofType: "png", inDirectory: "EVContactsPicker.bundle")
//                let im = UIImage(contentsOfFile: imPath!)
                contact.image = self.avatarImage
            }
        }
    }
    
    public func contactViewController(viewController: CNContactViewController, shouldPerformDefaultActionForContactProperty property: CNContactProperty) -> Bool {
        return true
    }
    
    // MARK: - TableView
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if( self.filteredContacts == nil ) {
            return 0
        } else {
            return self.filteredContacts!.count
        }
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "contactCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! EVContactsPickerTableViewCell
        let contact = self.filteredContacts?[indexPath.row]
        
        cell.fullName?.text = contact?.fullname()
        cell.phone?.text = contact?.phone
        cell.email?.text = contact?.email
        if((contact?.image) != nil) {
            cell.contactImage?.image = contact?.image
        }
        
        cell.contactImage?.layer.masksToBounds = true
        cell.contactImage?.layer.cornerRadius = 20
        
        if(self.selectedContacts == nil) {
//            let imPath = self.curBundle?.pathForResource(kUnselectedCheckbox, ofType: "png", inDirectory: "EVContactsPicker.bundle")
//            let im = UIImage(contentsOfFile: imPath!)
            cell.checkImage?.image = self.unselectedCheckbox
        } else {
            if (self.selectedContacts!.contains(contact!)) {
//                let imPath = self.curBundle?.pathForResource(kSelectedCheckbox, ofType: "png", inDirectory: "EVContactsPicker.bundle")
//                let im = UIImage(contentsOfFile: imPath!)
                cell.checkImage?.image = self.selectedCheckbox
            } else {
//                let imPath = self.curBundle?.pathForResource(kUnselectedCheckbox, ofType: "png", inDirectory: "EVContactsPicker.bundle")
//                let im = UIImage(contentsOfFile: imPath!)
                cell.checkImage?.image = self.unselectedCheckbox
            }
        }
        if (self.useExternal == false ) {
            cell.accessoryView = UIButton(type: .DetailDisclosure)
            let but = cell.accessoryView as! UIButton
            but.addTarget(self, action: Selector("viewContactDetail:"), forControlEvents: UIControlEvents.TouchUpInside)
        } else {
            cell.accessoryType = .None
            cell.accessoryView?.hidden = true
        }

        return cell
    }
    
    public func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {

        self.contactPickerView?.resignKeyboard()
        
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! EVContactsPickerTableViewCell
        
        let user = self.filteredContacts?[indexPath.row]
        
            if (self.selectedContacts!.contains(user!)) {
                let ind = selectedContacts?.indexOf(user!)
                self.selectedContacts?.removeAtIndex(ind!)
                self.contactPickerView?.removeContact(user!)
//                let imPath = self.curBundle?.pathForResource(kUnselectedCheckbox, ofType: "png", inDirectory: "EVContactsPicker.bundle")
//                let im = UIImage(contentsOfFile: imPath!)
                cell.checkImage?.image = self.unselectedCheckbox
            } else {
                self.selectedContacts?.append(user!)
                self.contactPickerView?.addContact(user!, name: (user?.fullname())!)
//                let imPath = self.curBundle?.pathForResource(kSelectedCheckbox, ofType: "png", inDirectory: "EVContactsPicker.bundle")
//                let im = UIImage(contentsOfFile: imPath!)
                cell.checkImage?.image = self.selectedCheckbox
            }
        
        if(self.selectedContacts?.count > 0) {
            self.barButton?.enabled = true
        } else {
            self.barButton?.enabled = false
        }
        
        self.title = String(NSBundle.evLocalizedStringForKey("Add Contacts") + "(\(self.selectedContacts!.count))")
        self.filteredContacts = self.contacts
        self.tableView?.reloadData()
        
        return indexPath
    }
    
    // MARK: - EVPickedContactsViewDelegate
    
    func contactPickerTextViewDidChange(textViewText: String) -> Void {
        if(textViewText == "") {
            self.filteredContacts = self.contacts
        } else {
            let pred = NSPredicate(format: "self.%@ contains[cd] %@ OR self.%@ contains[cd] %@", "firstName", textViewText, "lastName", textViewText)
            self.filteredContacts = self.contacts?.filter { pred.evaluateWithObject($0) }
        }
        
        self.tableView?.reloadData()
        
     }
    
    func contactPickerDidRemoveContact(contact: AnyObject) -> Void {
        let c = contact as! EVContact
        let ind = self.selectedContacts?.indexOf(c)
        self.selectedContacts?.removeAtIndex(ind!)
        let indexPath = NSIndexPath(forRow: ind!, inSection: 0)
        let cell = self.tableView?.cellForRowAtIndexPath(indexPath) as! EVContactsPickerTableViewCell
        if(self.selectedContacts?.count > 0) {
            self.barButton?.enabled = true
        } else {
            self.barButton?.enabled = false
        }
        let imPath = self.curBundle?.pathForResource(kUnselectedCheckbox, ofType: "png", inDirectory: "EVContactsPicker.bundle")
        let im = UIImage(contentsOfFile: imPath!)
        cell.checkImage?.image = im
        self.title = String(NSBundle.evLocalizedStringForKey("Add Contacts") + "(\(self.selectedContacts!.count))")
    }
    
    func contactPickerDidResize(pickedContactView: EVPickedContactsView) -> Void {
        self.adjustTableViewFrame(true)
    }
    
    // MARK: - Miscellaneous

    public func done(sender: AnyObject) -> Void {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.01 * Double(NSEC_PER_SEC)))

        dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
            if let del = self.delegate {
                if(del.respondsToSelector(Selector("didChooseContacts:"))) {
                    if let selcontacts = self.selectedContacts {
                        del.didChooseContacts(selcontacts)
                    } else {
                        del.didChooseContacts(nil)
                    }
                }
            }
        });
    }
    
    @IBAction func viewContactDetail(sender: UIButton) -> Void {
       // print("clicked discloser")
        
        if( self.useExternal == false ) {
            let indexp = NSIndexPath(forRow: 0, inSection: 0)
            
            let c =    self.filteredContacts?[indexp.row]
            do {
                let appconact = try self.store?.unifiedContactWithIdentifier((c?.identifier!)!, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()] )
                let vc = CNContactViewController(forContact: appconact!)
                CNContactViewController.descriptorForRequiredKeys()
                self.navigationController?.pushViewController(vc, animated: true)
            } catch {
                print("error")
            }
        }
        
        
    }

}

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
@objc open class EVContactsPickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,  EVPickedContactsViewDelegate, CNContactViewControllerDelegate {
    
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
    public var maxSelectedContacts : Int = -1 {
        didSet {
            singleSelection = maxSelectedContacts == 1;
        }
    }
    var singleSelection : Bool = false {
        didSet {
            updateTitle()
        }
    }
    var externalDataSource : [EVContact]? = nil
    
    public var showEmail = true
    public var showPhone = true
    
    public var delegate : EVContactsPickerDelegate?
    fileprivate var curBundle : Bundle?

    
    
    lazy var avatarImage : UIImage = {
       let bundle = Bundle.evAssetsBundle()
       let path = bundle.path(forResource: kAvatarImage, ofType: "png", inDirectory: "Images")
       return UIImage(named: path!)!
    }()
    
    lazy var selectedCheckbox : UIImage = {
        let bundle = Bundle.evAssetsBundle()
        let path = bundle.path(forResource: kSelectedCheckbox, ofType: "png", inDirectory: "Images")
        return UIImage(named: path!)!
    }()
    
    lazy var unselectedCheckbox : UIImage = {
        let bundle = Bundle.evAssetsBundle()
        let path = bundle.path(forResource: kUnselectedCheckbox, ofType: "png", inDirectory: "Images")
        return UIImage(named: path!)!
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
        updateTitle()
        self.curBundle = Bundle(for: type(of: self))
        if( self.useExternal == false ) {
            self.store = CNContactStore()
        }

    }
    
    func updateTitle() -> Void {
        var contactsPresented = false
        if let theContacts = self.selectedContacts {
            contactsPresented = theContacts.isEmpty
        }
        if contactsPresented == false {
            if singleSelection {
                self.title  = Bundle.evLocalizedStringForKey("Selected Contacts")
            } else {
                self.title  = Bundle.evLocalizedStringForKey("Selected Contacts") + "(0)"
            }
        } else {
            if singleSelection {
                self.title  = Bundle.evLocalizedStringForKey("Add Contacts")
            } else {
                self.title = String(Bundle.evLocalizedStringForKey("Add Contacts") + "(\(self.selectedContacts!.count))")
            }
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        barButton = UIBarButtonItem(title: Bundle.evLocalizedStringForKey("Done"), style: .done, target: self, action: #selector(EVContactsPickerViewController.done(_:)))
        barButton?.isEnabled = false
        self.navigationItem.rightBarButtonItem = barButton
        
        if self.navigationController?.viewControllers.first == self {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel,
                                                                    target: self,
                                                                    action: #selector(cancelTapped))
        }
        
        self.contactPickerView = EVPickedContactsView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width:self.view.frame.size.width, height: 100)))
        self.contactPickerView?.delegate = self
        self.contactPickerView?.setPlaceHolderString(Bundle.evLocalizedStringForKey("Type Contact Name"))
        self.view.addSubview(self.contactPickerView!)
        
        
        self.tableView = UITableView(frame: CGRect(x: 0, y: self.contactPickerView!.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height - self.contactPickerView!.frame.size.height - kKeyboardHeight), style: .plain)
        
        self.tableView?.delegate  = self
        self.tableView?.dataSource = self
        

        
        self.tableView?.register(UINib(nibName: "EVContactsPickerTableViewCell", bundle: self.curBundle), forCellReuseIdentifier: "contactCell")
        self.view.insertSubview(self.tableView!, belowSubview: self.contactPickerView!)
        
        if( self.useExternal == false ) {
            self.store?.requestAccess(for: .contacts, completionHandler: { (granted : Bool, error: Error?) -> Void in
                if(granted) {
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.getContactsFromAddressBook()
                    })
                } else {
                    DispatchQueue.main.async(execute: { () -> Void in
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
    
    override open func viewWillAppear(_ animated: Bool) -> Void {
        super.viewWillAppear(animated)
        DispatchQueue.main.async { () -> Void in
            self.refreshContacts()
        }
    }
    
    override open func viewDidLayoutSubviews() -> Void {
        super.viewDidLayoutSubviews()
        var topOffset : CGFloat = 0.0
        if( self.responds(to: #selector(getter: UIViewController.topLayoutGuide))) {
            topOffset = self.topLayoutGuide.length
        }
        self.contactPickerView?.frame.origin.y = topOffset
        self.adjustTableViewFrame(false)
    }
    
    func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func adjustTableViewFrame(_ animated: Bool) -> Void {
        var frame = self.tableView?.frame
        frame?.origin.y = (self.contactPickerView?.frame.size.height)!
        frame?.size.height = self.view.frame.size.height - (self.contactPickerView?.frame.size.height)! - kKeyboardHeight
        if( animated ) {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.3)
            UIView.setAnimationDelay(0.1)
            UIView.setAnimationCurve(.easeOut)
            self.tableView?.frame = frame!
            UIView.commitAnimations()
        } else {
            self.tableView?.frame = frame!
        }
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Addressbook
    
    func getContactsFromAddressBook() -> Void {
        
        self.contacts = []
        var mutableContacts : [EVContact] = []
        
        let req : CNContactFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactEmailAddressesKey as CNKeyDescriptor,CNContactGivenNameKey as CNKeyDescriptor,CNContactFamilyNameKey as CNKeyDescriptor,CNContactImageDataAvailableKey as CNKeyDescriptor,CNContactThumbnailImageDataKey as CNKeyDescriptor,CNContactImageDataKey as CNKeyDescriptor,CNContactPhoneNumbersKey as CNKeyDescriptor])
        
        do {
            try self.store?.enumerateContacts(with: req, usingBlock: { (contact: CNContact, boolprop : UnsafeMutablePointer<ObjCBool> ) -> Void in
                
                let tmpContact = EVContact()
                tmpContact.identifier = contact.identifier
                tmpContact.firstName = contact.givenName
                tmpContact.lastName = contact.familyName
                if (contact.phoneNumbers.count > 0) {
                    tmpContact.phone = (contact.phoneNumbers[0].value ).stringValue

                }
                if (contact.emailAddresses.count > 0) {
                    tmpContact.email = (contact.emailAddresses[0].value as String)
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
                
                let showContact = self.delegate?.shouldShowContact?(tmpContact)
                
                if showContact == nil || showContact == true {
                    mutableContacts.append(tmpContact)
                }
                
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

    func refreshContact(_ contact: EVContact) {
        if( self.useExternal == false ) {
            do {
                if let tmpContact = try self.store?.unifiedContact(withIdentifier: contact.identifier!, keysToFetch: [CNContactEmailAddressesKey as CNKeyDescriptor,CNContactGivenNameKey as CNKeyDescriptor,CNContactFamilyNameKey as CNKeyDescriptor,CNContactImageDataAvailableKey as CNKeyDescriptor,CNContactThumbnailImageDataKey as CNKeyDescriptor,CNContactImageDataKey as CNKeyDescriptor,CNContactPhoneNumbersKey as CNKeyDescriptor]) {
                    contact.identifier = tmpContact.identifier
                    contact.firstName = tmpContact.givenName
                    contact.lastName = tmpContact.familyName
                    if (tmpContact.phoneNumbers.count > 0) {
                        contact.phone = (tmpContact.phoneNumbers[0].value ).stringValue
                        
                    }
                    if (tmpContact.emailAddresses.count > 0) {
                        contact.email = (tmpContact.emailAddresses[0].value as String)
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
    
    open func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        return true
    }
    
    // MARK: - TableView
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if( self.filteredContacts == nil ) {
            return 0
        } else {
            return self.filteredContacts!.count
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "contactCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! EVContactsPickerTableViewCell
        let contact = self.filteredContacts?[(indexPath as NSIndexPath).row]
        
        cell.fullName?.text = contact?.fullname()
        
        cell.email?.isHidden = (contact?.email == nil || contact?.email?.isEmpty == true || showEmail == false)
        cell.phone?.isHidden = (contact?.phone == nil || contact?.phone?.isEmpty == true || showPhone == false)
        
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
            cell.accessoryView = UIButton(type: .detailDisclosure)
            let but = cell.accessoryView as! UIButton
            but.addTarget(self, action: #selector(EVContactsPickerViewController.viewContactDetail(_:)), for: UIControlEvents.touchUpInside)
        } else {
            cell.accessoryType = .none
            cell.accessoryView?.isHidden = true
        }

        return cell
    }
    
    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

        self.contactPickerView?.resignKeyboard()
        
        
        let cell = tableView.cellForRow(at: indexPath) as! EVContactsPickerTableViewCell
        
        let user = self.filteredContacts?[(indexPath as NSIndexPath).row]
        
            if (self.selectedContacts!.contains(user!)) {
                let ind = selectedContacts?.index(of: user!)
                self.selectedContacts?.remove(at: ind!)
                self.contactPickerView?.removeContact(user!)
//                let imPath = self.curBundle?.pathForResource(kUnselectedCheckbox, ofType: "png", inDirectory: "EVContactsPicker.bundle")
//                let im = UIImage(contentsOfFile: imPath!)
                cell.checkImage?.image = self.unselectedCheckbox
            } else if (canAddMoreContacts() || singleSelection) {
                if singleSelection {
                    self.selectedContacts?.removeAll();
                    self.contactPickerView?.removeAllContacts();
                }
                self.selectedContacts?.append(user!)
                self.contactPickerView?.addContact(user!, name: (user?.fullname())!)
//                let imPath = self.curBundle?.pathForResource(kSelectedCheckbox, ofType: "png", inDirectory: "EVContactsPicker.bundle")
//                let im = UIImage(contentsOfFile: imPath!)
                cell.checkImage?.image = self.selectedCheckbox
            }
        
        if((self.selectedContacts?.count)! > 0) {
            self.barButton?.isEnabled = true
        } else {
            self.barButton?.isEnabled = false
        }
        
        self.title = String(Bundle.evLocalizedStringForKey("Add Contacts") + "(\(self.selectedContacts!.count))")
        self.filteredContacts = self.contacts
        self.tableView?.reloadData()
        
        return indexPath
    }
    
    private func canAddMoreContacts() -> Bool {
        return maxSelectedContacts <= 0 || maxSelectedContacts > 0 && maxSelectedContacts > (self.selectedContacts?.count)!;
    }
    
    // MARK: - EVPickedContactsViewDelegate
    
    func contactPickerTextViewDidChange(_ textViewText: String) -> Void {
        if(textViewText == "") {
            self.filteredContacts = self.contacts
        } else {
            let pred = NSPredicate(format: "self.%@ contains[cd] %@ OR self.%@ contains[cd] %@", "firstName", textViewText, "lastName", textViewText)
            self.filteredContacts = self.contacts?.filter { pred.evaluate(with: $0) }
        }
        
        self.tableView?.reloadData()
        
     }
    
    func contactPickerDidRemoveContact(_ contact: AnyObject) -> Void {
        let c = contact as! EVContact
        let ind = self.selectedContacts?.index(of: c)
        self.selectedContacts?.remove(at: ind!)
        let indexPath = IndexPath(row: ind!, section: 0)
        let cell = self.tableView?.cellForRow(at: indexPath) as! EVContactsPickerTableViewCell
        if((self.selectedContacts?.count)! > 0) {
            self.barButton?.isEnabled = true
        } else {
            self.barButton?.isEnabled = false
        }
        let imPath = self.curBundle?.path(forResource: kUnselectedCheckbox, ofType: "png", inDirectory: "EVContactsPicker.bundle")
        let im = UIImage(contentsOfFile: imPath!)
        cell.checkImage?.image = im
        self.title = String(Bundle.evLocalizedStringForKey("Add Contacts") + "(\(self.selectedContacts!.count))")
    }
    
    func contactPickerDidResize(_ pickedContactView: EVPickedContactsView) -> Void {
        self.adjustTableViewFrame(true)
    }
    
    // MARK: - Miscellaneous

    open func done(_ sender: AnyObject) -> Void {
        let delayTime = DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)

        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: { () -> Void in
            if let del = self.delegate {
                if(del.responds(to: #selector(EVContactsPickerDelegate.didChooseContacts(_:)))) {
                    if let selcontacts = self.selectedContacts {
                        del.didChooseContacts(selcontacts)
                    } else {
                        del.didChooseContacts(nil)
                    }
                }
            }
        });
    }
    
    @IBAction func viewContactDetail(_ sender: UIButton) -> Void {
       // print("clicked discloser")
        
        if( self.useExternal == false ) {
            let indexp = IndexPath(row: 0, section: 0)
            
            let c =    self.filteredContacts?[(indexp as NSIndexPath).row]
            do {
                let appconact = try self.store?.unifiedContact(withIdentifier: (c?.identifier!)!, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()] )
                let vc = CNContactViewController(for: appconact!)
                CNContactViewController.descriptorForRequiredKeys()
                self.navigationController?.pushViewController(vc, animated: true)
            } catch {
                print("error")
            }
        }
        
        
    }

}

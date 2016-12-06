//
//  DemoViewController.swift
//  EVContactsPicker
//
//  Created by Edward Valentini on 9/19/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import EVContactsPicker

class DemoViewController: UIViewController, EVContactsPickerDelegate {

    @IBOutlet var textView : UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showDemo(_ sender: AnyObject?) -> Void {
        let contactPicker = EVContactsPickerViewController()
        contactPicker.delegate = self
        self.navigationController?.pushViewController(contactPicker, animated: true)
    }
    
    func didChooseContacts(_ contacts: [EVContactProtocol]?) {
        var conlist : String = ""
        if let cons = contacts {
            for con in cons {
                if let fullname = con.fullname() {
                    conlist += fullname + "\n"
                }
            }
            self.textView?.text = conlist
        } else {
            print("I got nothing")
        }
        let _ = self.navigationController?.popViewController(animated: true)

    }

}

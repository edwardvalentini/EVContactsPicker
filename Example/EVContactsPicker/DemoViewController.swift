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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showDemo(sender: AnyObject?) -> Void {
        
        let c1 : EVContact = EVContact()
        c1.identifier = "a12332"
        c1.firstName = "Mr. "
        c1.lastName = "T"
        
        let c2 : EVContact = EVContact()
        c2.identifier = "a93898"
        c2.firstName = "Mrs. "
        c2.lastName = "Q"
        
        
        let c3 = EVContact(attributes: ["id":"gh2798932","firstName": "Jack", "lastName": "Smith", "image" : UIImage(named: "jacksmith")! ])
        
        let cArr : [EVContact] = [ c1,c2, c3 ]

        
        let contactPicker = EVContactsPickerViewController(externalDataSource: cArr)
        //let contactPicker = EVContactsPickerViewController()
        contactPicker.delegate = self
        self.navigationController?.pushViewController(contactPicker, animated: true)
    }
    
    func didChooseContacts(contacts: [EVContact]?) {
        var conlist : String = ""
        if let cons = contacts {
            for con in cons {
                conlist += con.fullname() + "\n"
            }
            self.textView?.text = conlist
        } else {
            print("I got nothing")
        }
        self.navigationController?.popViewControllerAnimated(true)

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showDemo(sender: AnyObject?) -> Void {
        let contactPicker = EVContactsPickerViewController()
        contactPicker.delegate = self
        self.navigationController?.pushViewController(contactPicker, animated: true)
    }
    
    func didChooseContacts(contacts: [EVContact]?) {
        print("I chose \(contacts)")
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

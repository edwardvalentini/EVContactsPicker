//
//  EVContactsPickerTableViewCell.swift
//  Pods
//
//  Created by Edward Valentini on 9/18/15.
//
//

import UIKit

class EVContactsPickerTableViewCell: UITableViewCell {
    
    @IBOutlet var fullName : UILabel?
    @IBOutlet var phone : UILabel?
    @IBOutlet var email : UILabel?
    @IBOutlet var contactImage : UIImageView?
    @IBOutlet var checkImage : UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

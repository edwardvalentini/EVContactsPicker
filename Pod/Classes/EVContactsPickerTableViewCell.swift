//
//  EVContactsPickerTableViewCell.swift
//  Pods
//
//  Created by Edward Valentini on 9/18/15.
//
//

import UIKit
import Nuke

class EVContactsPickerTableViewCell: UITableViewCell {
    
    @IBOutlet var fullName : UILabel?
    @IBOutlet var phone : UILabel?
    @IBOutlet var email : UILabel?
    @IBOutlet var contactImage : UIImageView?
    @IBOutlet var checkImage : UIImageView?
    
    var imageURL: URL? {
        didSet {
            guard let imageURL = imageURL, let contactImage = contactImage else { return }
            Nuke.loadImage(with: imageURL, into: contactImage)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

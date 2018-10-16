//
//  MessagesTableViewCell.swift
//  Slindir
//
//  Created by Gurinder Batth on 16/11/17.
//  Copyright © 2017 Batth. All rights reserved.
//

import UIKit

class MessagesTableViewCell: UITableViewCell {

    @IBOutlet weak var imgViewProfile: UIImageView!
    @IBOutlet weak var imgViewNewMessage: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgViewNewMessage.layer.borderColor = UIColor.white.cgColor
        imgViewNewMessage.layer.borderWidth = 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

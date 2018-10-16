//
//  OpenCameraView.swift
//  Slindir
//
//  Created by DeftDeskSol on 25/09/1939 Saka.
//  Copyright © 1939 Batth. All rights reserved.
//

import UIKit

class OpenCameraView: UIView {
    
    @IBOutlet weak var viewVideoProfile: UIView!
    @IBOutlet weak var viewVideoRecordRed: UIView!
    @IBOutlet weak var viewRecordVideo: UIView!
    
    @IBOutlet weak var imgViewCamera: UIImageView!
    @IBOutlet weak var imgViewProfile: UIImageView!
    @IBOutlet weak var imgViewRecord: UIImageView!
    
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    
    @IBOutlet weak var lblRecordVideo: UILabel!
    @IBOutlet weak var widthOpenCamera: NSLayoutConstraint!
    @IBOutlet weak var heightOpenCamera: NSLayoutConstraint!
    
    override func awakeFromNib() {
        var radius = 10
        if UIScreen.main.bounds.size.width == 375 {
            radius = 13
        }
        else if UIScreen.main.bounds.size.width == 414 {
            radius = 17
        }
        self.imgViewRecord.layer.cornerRadius = CGFloat(radius)
        self.imgViewRecord.layer.masksToBounds = true
    }
}

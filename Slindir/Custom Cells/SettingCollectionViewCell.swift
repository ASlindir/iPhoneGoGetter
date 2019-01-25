//
//  SettingCollectionViewCell.swift
//  Slindir
//
//  Created by Gurinder Batth on 26/10/17.
//  Copyright © 2017 Batth. All rights reserved.
//

import UIKit
import AVKit

class SettingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var viewVideoProfile: UIView!
    @IBOutlet weak var viewVideoRecordRed: UIView!
    @IBOutlet weak var viewRecordVideo: UIView!
    
    @IBOutlet weak var imgViewCamera: UIImageView!
    @IBOutlet weak var imgViewProfile: UIImageView!
    @IBOutlet weak var imgViewRecord: UIImageView!
    
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    
    @IBOutlet weak var lblRecordVideo: UILabel!
    
    var videoController = AVPlayerViewController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        settingTheVideoView()
    }
    
    func settingTheVideoView(){
        viewVideoProfile.addSubview(videoController.view)
        videoController.showsPlaybackControls = false
        videoController.view.translatesAutoresizingMaskIntoConstraints = false
        viewVideoProfile.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: [:], views: ["v0":videoController.view]))
        viewVideoProfile.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: [:], views: ["v0":videoController.view]))
    }
    
}


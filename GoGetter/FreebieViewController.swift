//
//  FreebieViewController.swift
//  GoGetter
//
//  Created by Fred Covely on 4/9/20.
//  Copyright © 2020 Batth. All rights reserved.
//

import Foundation
import UIKit

class FreebieViewController: UIViewController {
   
    @IBOutlet weak var btnNext: UIButton!
    
    var userId: String? = nil
    var isPinkName: Bool = false
    var didGoHandler: ((String?) -> Void)? = nil
    
    override func viewDidLoad() {
         super.viewDidLoad()
        btnNext.isHidden = false
         // buttons
     }

     override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         
     }

     override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
         
     }
    
    @IBAction func onClick(_ sender: Any) {
    }
}

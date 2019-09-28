//
//  ReservePurchaseViewController.swift
//  GoGetter
//
//  Created by admin on 27/09/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit

class ReservePurchaseViewController: UIViewController {
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var notYetButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var userId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // buttons
        self.goButton.adjustsImageWhenHighlighted = false
        self.goButton.adjustsImageWhenDisabled = false
        
        self.notYetButton.backgroundColor = UIColor.clear
        self.notYetButton.layer.borderWidth = 1.0
        self.notYetButton.layer.borderColor = UIColor(red:0.82, green:0.84, blue:0.84, alpha:1.0).cgColor
        self.notYetButton.setTitleColor(UIColor(red:0.82, green:0.84, blue:0.84, alpha:1.0), for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.createGradientLayer(self.gradientView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.goButton.layer.cornerRadius = self.goButton.frame.height / 2.0
        self.notYetButton.layer.cornerRadius = self.notYetButton.frame.height / 2.0
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func createGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor(red:0.00, green:0.65, blue:0.69, alpha:1).cgColor]
        
        self.gradientView.layer.addSublayer(gradientLayer)
    }

    @IBAction func touchGo(_ sender: Any) {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.autoreverse], animations: {
            self.goButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: {finished in
            self.goButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    @IBAction func touchNotYet(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//
//  TestPurchaseViewController.swift
//  GoGetter
//
//  Created by admin on 26/09/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit
import Firebase
import DACircularProgress

class TestPurchaseViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var testClockImage: UIClockImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var leadingCollectionConstraint: NSLayoutConstraint!
    @IBOutlet weak var circularView: DACircularProgressView!
    @IBOutlet weak var circularImageView: UIImageView!
    @IBOutlet weak var circleView: UICircleUserView!
    
    var leadingCollectionConstraintDefault: CGFloat = 0.0
    
    var isRootController: Bool = false
    var items: [CGFloat?] = [
        10.0,
        20.0,
        30.0,
        40.0,
        50.0,
        60.0,
        70.0,
        80.0,
        90.0,
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib.init(nibName: "TestPurchaseCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TestPurchaseCollectionViewCell")
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.layer.zPosition = 0
        self.initLayoutCollection()
        
        self.testClockImage.addCircle(50.0)
        
        // init constraints
        self.leadingCollectionConstraintDefault = self.leadingCollectionConstraint.constant
        
        // circular
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.circularImageView.layer.cornerRadius = self.circularImageView.frame.height / 2.0
            self.circularImageView.layer.borderColor = UIColor.clear.cgColor
            self.circularImageView.layer.borderWidth = 2.0
            
            self.circularView.progressTintColor = UIColor.white
            self.circularView.trackTintColor = UIColor.green
            
            self.circularView.setProgress(0.35, animated: false)
        }
    }

    @IBAction func touchStart(_ sender: Any) {
        self.showHideAnimation(self.testClockImage)
        self.animationAddItemToCollection()
        //self.circleView.animationShow()
        self.circleView.animationClick()
//        self.circleView.animationChangeColor(color: UIColor.red)
    }
    
    func showHideAnimation(_ view: UIView) {
//        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
//        pulseAnimation.duration = 1
//        pulseAnimation.fromValue = 0
//        pulseAnimation.toValue = 1
//        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//        pulseAnimation.autoreverses = true
//        pulseAnimation.repeatCount = Float.greatestFiniteMagnitude
//        self.testClockImage.layer.add(pulseAnimation, forKey: nil)
        
//        self.testClockImage.alpha = 0
        
        UIView.animate(withDuration: 0.25, animations: {
            view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//            self.testClockImage.alpha = 1
        }, completion: { (completed: Bool) in
            UIView.animate(withDuration: 0.25, animations: {
                view.transform = CGAffineTransform(scaleX: 1, y: 1)
//                view.alpha = 1
            }, completion: { (completed: Bool) in
                
            })
        })
    }
    
    func animationAddItemToCollection() {
        //self.items = [nil] + self.items
        
        self.leadingCollectionConstraint.constant = self.leadingCollectionConstraintDefault + self.collectionView.frame.height + 2 * self.leadingCollectionConstraintDefault
        UIView.animate(withDuration: 0.75, animations: {
            self.view.layoutIfNeeded()
        }, completion: {res in
            self.leadingCollectionConstraint.constant = self.leadingCollectionConstraintDefault
            self.items = [nil] + self.items
            self.collectionView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let cell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? TestPurchaseCollectionViewCell {
                    
//                      UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseInOut, animations: {
//                        self.imageVIew.alpha = 0.0
//                    }) { _ in print("Animation Done") }
                    
                    let perc: CGFloat = 10.0
                    
                    cell.mainImage.addCircle(perc)
                    cell.mainImage.isHidden = false
                    cell.layer.zPosition = 1000
                    
                    cell.mainImage.animationHide(completion: {
                        self.items[0] = perc
                        self.collectionView.reloadData()
                    })
                }
            }
        })
    }
    
     // MARK: - Collection View
    
    func initLayoutCollection() {
//        let flowLayout = UIFormLineCheckFlowLayout()
////                flowLayout.itemSize = CGSize(width: self.collectionView.frame.width / CGFloat(self.items.count) - self.collectionInsert * 2 - 2, height: self.collectionView.frame.height)
//        flowLayout.estimatedItemSize = CGSize(width: 1.0, height: 1.0)
//        flowLayout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
//        flowLayout.scrollDirection = .horizontal
//        //        flowLayout.minimumInteritemSpacing = self.collectionInsert
//        self.topCollectionView.collectionViewLayout = flowLayout
//        self.topCollectionView.showsHorizontalScrollIndicator = false
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestPurchaseCollectionViewCell",
                                                      for: indexPath) as! TestPurchaseCollectionViewCell
        
        if let perc = self.items[indexPath.item] {
            cell.mainImage.addCircle(perc)
            cell.mainImage.isHidden = false
        } else {
            cell.mainImage.isHidden = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            cell.layer.zPosition = 0
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }

}

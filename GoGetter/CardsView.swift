//
//  CardsView.swift
//  GoGetter
//
//  Created by OSX on 06/10/17.
//  Copyright © 2017 Batth. All rights reserved.
//

import UIKit
import Koloda
import CHIPageControl
import SDWebImage
import DACircularProgress

private let overlayRightImageName = "greenSwipe"
private let overlayLeftImageName = "redSwipe"

protocol CardsViewDelegates {
    func showBottomView(_ viewCard: CardsView)
    func undoPreviousCard()
    func undoDemoCard()
    func profileDemoCard()
}

class CardsView: OverlayView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
//MARK:-  IBOutlets, Variables and Constraints
    
    //@IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollVw: UIScrollView!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblWork: UILabel!
    
    @IBOutlet weak var imgViewGold: UIImageView!
    
    @IBOutlet weak var btnOpenScroll: UIButton!
    
    @IBOutlet weak var btnInterestOne: UIButton!
    @IBOutlet weak var btnInterestTwo: UIButton!
    @IBOutlet weak var btnInterestThree: UIButton!
    @IBOutlet weak var btnInterestFour: UIButton!
    
    @IBOutlet lazy var overlayImageView: UIImageView! = {
        [unowned self] in
        
        var imageView = UIImageView(frame: self.bounds)
        imageView.backgroundColor = .clear
        imageView.tintColor = .clear
        self.addSubview(imageView)
        
        return imageView
        }()
    
    
    var arrayImages: [String] = []
    
    var cardDelegate: CardsViewDelegates?
    
    @IBOutlet weak var pageControl: CHIPageControlChimayo!
    
    @IBOutlet weak var imgVwTip: UIImageView!
    @IBOutlet weak var imgVwLightBulb: UIImageView!
    @IBOutlet weak var lblTip: UILabel!
    @IBOutlet weak var btnUndoTip: UIButton!
    @IBOutlet weak var vwTip: UIView!
    @IBOutlet weak var pageControlConstant: NSLayoutConstraint!
    @IBOutlet weak var undoCard: UIButton!
    var isBottomViesShowing:Bool = false
    
    @IBOutlet weak var vwMessage: UIView!
    @IBOutlet weak var vwLeft: UIView!
    @IBOutlet weak var vwRight: UIView!
    @IBOutlet weak var vwProfileDetail: UIView!
    @IBOutlet weak var vwUndo: UIView!
    
    @IBOutlet weak var imgVwRight: UIImageView!
    @IBOutlet weak var imgVwLeft: UIImageView!
    @IBOutlet weak var imgVwMessage: UIImageView!
    @IBOutlet weak var imgVwDemoRight: UIImageView!
    @IBOutlet weak var imgVwDemoLeft: UIImageView!
    @IBOutlet weak var imgVwDemoMessage: UIImageView!
    @IBOutlet weak var imgVwDemoProfile: UIImageView!
    @IBOutlet weak var imgVwDemoUndo: UIImageView!
    @IBOutlet weak var imgVwProfile: UIImageView!
    @IBOutlet weak var imgVwUndo: UIImageView!
    
    @IBOutlet weak var lblDemoRight: UILabel!
    @IBOutlet weak var lblDemoLeft: UILabel!
    @IBOutlet weak var lblDemoMessage: UILabel!
    @IBOutlet weak var lblDemoProfile: UILabel!
    @IBOutlet weak var lblDemoUndo: UILabel!
    
    @IBOutlet weak var pageControlRight: CHIPageControlChimayo!
    @IBOutlet weak var pageControlLeft: CHIPageControlChimayo!
    @IBOutlet weak var pageControlMessage: CHIPageControlChimayo!
    @IBOutlet weak var pageControlProfileDetail: CHIPageControlChimayo!
    @IBOutlet weak var pageControlUndo: CHIPageControlChimayo!
    
    @IBOutlet weak var leadingLeft: NSLayoutConstraint!
    @IBOutlet weak var trailingRight: NSLayoutConstraint!
    @IBOutlet weak var compatibilityProgress: DACircularProgressView!
    
    //MARK:-  UICollection View DataSources
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileImageViewCell", for: indexPath) as! ProfileImageViewCell
        cell.contentView.backgroundColor = .clear
        cell.imageView.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl, arrayImages[indexPath.row])), placeholderImage: UIImage.init(named: "placeholder"))
        return cell
    }
    
//MARK:-  UICollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
//MARK:-  UICollection View Flow Layout Delegates
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = UIScreen.main.bounds.size.height - 168
        let width  = UIScreen.main.bounds.size.width - 37 //collectionView.frame.size.width 
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.001
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
//MARK:-  Swipe View Methods(Left and Right Swipe)
    
    override var overlayState: SwipeResultDirection?  {
        didSet {
            switch overlayState {
            case .left? :
                overlayImageView.image = UIImage(named: overlayLeftImageName)
            case .right? :
                overlayImageView.image = UIImage(named: overlayRightImageName)
            case .up? :
                print("Up Direction")
            default:
                overlayImageView.image = nil
            }
        }
    }
    
//MARK:-  UIScrollView Delegates
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if self.arrayImages.count <= 1 {
            self.scrollVw.contentSize = CGSize(width:(self.scrollVw.bounds.size.width), height: (self.scrollVw.bounds.size.height) + 2)
        }
        else {
            self.scrollVw.contentSize = CGSize(width:(self.scrollVw.bounds.size.width), height: (self.scrollVw.bounds.size.height) * CGFloat((self.arrayImages.count)))
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.progress = Double(scrollView.contentOffset.y/scrollView.frame.size.height)
        self.isBottomViesShowing = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == scrollVw {
            if !isBottomViesShowing {
                if scrollView.contentOffset.y >  scrollView.contentSize.height - scrollView.bounds.height{
                    self.isBottomViesShowing = true
                    self.cardDelegate?.showBottomView(self)
                }
            }
        }
    }
    
    @IBAction func UndoCardClicked(_ sender: Any) {
        self.cardDelegate?.undoPreviousCard()
    }
    
    @IBAction func UndoDemoCard(_ sender: Any) {
        self.cardDelegate?.undoDemoCard()
    }
    
    @IBAction func ProfileDemoCard(_ sender: Any) {
        self.cardDelegate?.profileDemoCard()
    }
    
}

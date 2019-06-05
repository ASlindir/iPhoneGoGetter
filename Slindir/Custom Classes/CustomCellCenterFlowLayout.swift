//
//  CustomCellCenterFlowLayout.swift
//  GoGetter
//
//  Created by Gurinder Batth on 01/11/17.
//  Copyright © 2017 Batth. All rights reserved.
//

//All Hounour goes to :-  Michael Michailidis


//MARK:-  For More Information Check There :- http://blog.karmadust.com/centered-paging-with-preview-cells-on-uicollectionview/

//************************************ OR **********************************************

//https://bitbucket.org/mmick66/centercellpagingcollectionview/overview

import UIKit

class CustomCellCenterFlowLayout: UICollectionViewFlowLayout {
    
    var mostRecesntOffSet: CGPoint = CGPoint()
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if velocity.x == 0{
            return mostRecesntOffSet
        }
        if let cv = self.collectionView{
            
            let cvBounds = cv.bounds
            let halfWidth = cvBounds.size.width * 0.5
            
            if let attributesForVisibleCells = self.layoutAttributesForElements(in: cvBounds){
                
                var candidateAttributes: UICollectionViewLayoutAttributes?
                for attribute in attributesForVisibleCells{
                    
                    // == Skip comparison with non-cell items (headers and footers) == //
                    if attribute.representedElementCategory != UICollectionView.ElementCategory.cell{
                        continue
                    }
                    
                    if (attribute.center.x == 0) || (attribute.center.x > (cv.contentOffset.x + halfWidth) && velocity.x < 0) {
                        continue
                    }
                    
                    candidateAttributes = attribute
                }
                
                // Beautification step , I don't know why it works!
                if (proposedContentOffset.x == -(cv.contentInset.left)){
                    return proposedContentOffset
                }
                
                guard let _ = candidateAttributes else {
                    return mostRecesntOffSet
                }
                
                mostRecesntOffSet = CGPoint(x: floor(candidateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)
                return mostRecesntOffSet
                
            }
        }
        
        //Fallback
        
        mostRecesntOffSet = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        return mostRecesntOffSet
    }
}

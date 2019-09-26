//
//  TestPurchaseCollectionViewLayout.swift
//  GoGetter
//
//  Created by admin on 26/09/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit

final class TestPurchaseCollectionViewLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        attributes?.forEach {
            $0.zIndex = 0 //Compute and set
        }
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = super.layoutAttributesForItem(at: indexPath)
        attribute?.zIndex = 0 //Compute and set
        return attribute
    }
}

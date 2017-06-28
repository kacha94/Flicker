//
//  PhotosLayout.swift
//  Freetopia
//
//  Created by Andrey Polyashev on 27.06.17.
//  Copyright © 2017 Andrey Polyashev. All rights reserved.
//

import UIKit


@objc protocol PhotosLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForPhotoAt indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat
    @objc optional func collectionViewHeightForHeader(collectionView: UICollectionView) -> CGFloat
    @objc optional func collectionViewSectionHeaderShouldBeSticky(collectionView: UICollectionView) -> Bool
    @objc optional func collectionViewSectionHeaderStickedHeight(collectionView: UICollectionView) -> CGFloat
}

class PhotosLayout: UICollectionViewLayout {

    static let SectionHeaderElementKind = "SectionHeaderElementKind"

    enum ColumnSelectionStrategy {
        case byTurns
        case lowestHeight
    }
    
    //MARK: Internal properties
    var delegate: PhotosLayoutDelegate?
    
    var numberOfColumns = 2 {
        didSet {
            invalidateLayout()
        }
    }
    
    var lineSpacing: CGFloat = 10 {
        didSet {
            invalidateLayout()
        }
    }
    
    var interitemSpacing: CGFloat = 10 {
        didSet {
            invalidateLayout()
        }
    }
    
    var columnSelectionStrategy: ColumnSelectionStrategy = .lowestHeight {
        didSet {
            invalidateLayout()
        }
    }

    var sectionContentInsets: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            invalidateLayout()
        }
    }
    
    //MARK: Private properties
    fileprivate var cache: [IndexPath : PhotosLayoutAttributes] = [:]
    fileprivate var headerLayoutAttributes: PhotosLayoutAttributes?

    fileprivate var contentWidth: CGFloat {
        let inset = collectionView!.contentInset
        return collectionView!.bounds.width - (inset.left + inset.right)
    }
    
    fileprivate var availableSectionContentWidth: CGFloat {
        return contentWidth - (sectionContentInsets.left + sectionContentInsets.right)
    }
    
    fileprivate var collectionWidth: CGFloat {
        return collectionView!.bounds.width
    }
    
    override class var layoutAttributesClass: AnyClass {
        return PhotosLayoutAttributes.self
    }
    
    fileprivate var contentHeight: CGFloat = 0
    fileprivate var cellZIndex: Int {
        return 0
    }
    
    fileprivate var headerZIndex: Int {
        return cellZIndex + 1
    }

    override func invalidateLayout() {
        super.invalidateLayout()
        cache.removeAll()
    }
    
    override func prepare() {
        contentHeight = 0
        
        let headerHeight = self.headerHeight()
        if headerHeight != 0 {
            let headerIndexPath = IndexPath(row: 0, section: 0)
            let attributes = PhotosLayoutAttributes(forSupplementaryViewOfKind: PhotosLayout.SectionHeaderElementKind,
                                                  with: headerIndexPath)
            
            attributes.frame = CGRect(x: 0,
                                      y: 0,
                                      width: collectionWidth,
                                      height: headerHeight)
            headerLayoutAttributes = attributes
        }
        
        if cache.isEmpty {
            let availableWidthForCells = availableSectionContentWidth - CGFloat(numberOfColumns - 1) * interitemSpacing
            let columnWidth = availableWidthForCells / CGFloat(numberOfColumns)
            
            var xOffsets: [CGFloat] = []
            for column in 0..<numberOfColumns {
                let offset = CGFloat(column) * columnWidth + CGFloat(column) * interitemSpacing + sectionContentInsets.left
                xOffsets.append(offset)
            }
            
            var column = 0 //current column to add item to
            var lastYOffsets = [CGFloat](repeating: headerHeight + sectionContentInsets.top, count: numberOfColumns)

            //calculating only for first section is ok in this case
            for item in 0..<collectionView!.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                let height = photoHeight(at: indexPath, withWidth: columnWidth)
                let frame = CGRect(x: xOffsets[column], y: lastYOffsets[column],
                                   width: columnWidth, height: height)
                let attributes = PhotosLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame

                cache[indexPath] = attributes
                
                //updates for properties during calculations
                contentHeight = max(contentHeight, frame.maxY)
                lastYOffsets[column] = lastYOffsets[column] + height + lineSpacing
                
                //next column selection
                column = nextColumn(withStrategy: columnSelectionStrategy, currentColumn: column, lastYOffsets: lastYOffsets)
            }
            
            contentHeight += sectionContentInsets.bottom
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        if let headerAttributes = calculateHeaderAttributesForRect(rect: rect) {
            //This property is used to determine the front-to-back ordering.  
            //Items with higher index values appear on top of items with lower values.
            headerAttributes.zIndex = headerZIndex
            layoutAttributes.append(headerAttributes)
        }
        
        for attributes in cache {
            if attributes.value.frame.intersects(rect) {
                attributes.value.zIndex = cellZIndex
                layoutAttributes.append(attributes.value)
            }
        }
        

        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath]
    }
}

//MARK: Private supporting methods
private extension PhotosLayout {
    func photoHeight(at indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        guard let validDelegate = delegate else {
            fatalError("Property `delegate` should be initialized before layout is used.")
        }
        
        return validDelegate.collectionView(collectionView: collectionView!,
                                            heightForPhotoAt: indexPath,
                                            withWidth: width)
    }
    
    func headerHeight() -> CGFloat {
        guard let height = delegate?.collectionViewHeightForHeader?(collectionView: collectionView!) else {
            return 0
        }
        
        return height
    }
    
    func headerShouldBeSticky() -> Bool {
        guard let shouldSticky = delegate?.collectionViewSectionHeaderShouldBeSticky?(collectionView: collectionView!) else {
            return false
        }
        
        return shouldSticky
    }
    
    func headerStickyAtYPosition() -> CGFloat {
        guard let yPosition = delegate?.collectionViewSectionHeaderStickedHeight?(collectionView: collectionView!) else {
            return 0
        }
        
        return yPosition
    }
    
    
    func nextColumn(withStrategy strategy: ColumnSelectionStrategy, currentColumn: Int, lastYOffsets: [CGFloat]) -> Int {
        switch strategy {
        case .byTurns:
            if currentColumn >= (numberOfColumns - 1) {
                return 0
            } else {
                return currentColumn + 1
            }
        case .lowestHeight:
            guard let min = lastYOffsets.min() else {
                //we shouldn't be here
                return 0
            }
            
            return lastYOffsets.index(of: min)!
        }
    }
    
    func calculateHeaderAttributesForRect(rect: CGRect) -> UICollectionViewLayoutAttributes? {
        if let headerAttributes = headerLayoutAttributes {
            if headerAttributes.frame.intersects(rect) {
                guard headerShouldBeSticky() else {
                    return headerAttributes
                }
                
                let contentOffsetY = collectionView!.contentOffset.y
                let positionY = headerStickyAtYPosition()
                
                if contentOffsetY > positionY {
                    headerAttributes.frame.origin.y = contentOffsetY - positionY
                } else if contentOffsetY < positionY {
                    headerAttributes.frame.origin.y = 0
                }
                return headerAttributes
            }
        }
        return nil
    }
}



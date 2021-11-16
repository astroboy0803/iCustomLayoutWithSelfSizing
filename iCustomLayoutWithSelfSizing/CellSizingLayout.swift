//
//  CellSizingLayout.swift
//  iMeetingLayout
//
//  Created by BruceHuang on 2021/11/10.
//

import UIKit

internal class CellSizingLayout: UICollectionViewLayout {

    struct LayoutInformation {
        let cellHeight: CGFloat
        let headerHeight: CGFloat
        let spacing: CGFloat
        let numberOfColumn: Int
    }

    private var cellLayoutAttributes: [IndexPath: UICollectionViewLayoutAttributes]
    private var headerLayoutAttributes: [Int: UICollectionViewLayoutAttributes]
    private var isSizing: Bool {
        didSet {
            lastCellMaxY = .zero
            groupCellMinY = .zero
        }
    }
    private var lastCellMaxY: CGFloat
    private var groupCellMinY: CGFloat
    var isHeader: Bool {
        didSet {
            self.invalidateLayout()
        }
    }
    
    private let layoutInfos: LayoutInformation

    override init() {
        layoutInfos = .init(cellHeight: 50, headerHeight: 25, spacing: 8, numberOfColumn: 3)
        headerLayoutAttributes = [:]
        cellLayoutAttributes = [:]
        isSizing = false
        lastCellMaxY = .zero
        groupCellMinY = .zero
        isHeader = true
        super.init()
    }

    init(layoutInfos: LayoutInformation) {
        self.layoutInfos = layoutInfos
        headerLayoutAttributes = [:]
        cellLayoutAttributes = [:]
        isSizing = false
        lastCellMaxY = .zero
        groupCellMinY = .zero
        isHeader = true
        super.init()
    }

    required init?(coder: NSCoder) {
        layoutInfos = .init(cellHeight: 50, headerHeight: 25, spacing: 0, numberOfColumn: 3)
        headerLayoutAttributes = [:]
        cellLayoutAttributes = [:]
        isSizing = false
        lastCellMaxY = .zero
        groupCellMinY = .zero
        isHeader = true
        super.init(coder: coder)
    }
    
    // MARK: - step 1: 取消目前的layout
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else {
            return false
        }
        return newBounds.size != collectionView.bounds.size
    }
    
    override func invalidateLayout() {
        headerLayoutAttributes = [:]
        cellLayoutAttributes = [:]
        isSizing = false
        super.invalidateLayout()
    }
    
    // MARK: - step 2: 計算header與cell並cache起來
    override func prepare() {
        super.prepare()
        guard let collectionView = self.collectionView else {
            return
        }
        
        if isSizing || cellLayoutAttributes.isEmpty {
            [Int](0..<collectionView.numberOfSections)
                .forEach { section in
                    if isHeader {
                        headerLayoutAttributes[section] = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: .init(item: 0, section: section))
                    }
                    
                    [Int](0..<collectionView.numberOfItems(inSection: section))
                        .map { item in
                            IndexPath(item: item, section: section)
                        }
                        .forEach {
                            cellLayoutAttributes[$0] = layoutAttributesForItem(at: $0)
                        }
                }
        }
        if isSizing {
            isSizing = false
            collectionView.contentSize = collectionViewContentSize
        }
    }

    // MARK: supplementary attribute 計算
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard elementKind == UICollectionView.elementKindSectionHeader else {
            return nil
        }
        let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        attribute.frame = frameForHeaderView(section: indexPath.section)
        return attribute
    }

    // MARK: header的rect
    private func frameForHeaderView(section: Int) -> CGRect {
        guard let collectionView = collectionView else {
            return .zero
        }
        let size = CGSize(width: collectionView.frame.width, height: layoutInfos.headerHeight)
        let origin = CGPoint(x: 0, y: getLocationY(section: section))
        return .init(origin: origin, size: size)
    }

    // MARK: header的Y
    private func getLocationY(section: Int) -> CGFloat {
        guard
            let collectionView = collectionView,
            section > 0
        else {
            return .zero
        }
        let prevLastIndex = collectionView.numberOfItems(inSection: section - 1) - 1
        guard let lastAttribute = layoutAttributesForItem(at: .init(item: prevLastIndex, section: section - 1)) else {
            return .zero
        }
        return lastAttribute.frame.maxY + layoutInfos.spacing
    }

    // MARK: cell attribute 計算
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attribute.frame = getItemFrame(indexPath: indexPath)
        lastCellMaxY = max(lastCellMaxY, attribute.frame.maxY)
        return attribute
    }

    private func getItemFrame(indexPath: IndexPath) -> CGRect {
        let cellRect = itemRect(indexPath: indexPath)
        let headerFrame = headerLayoutAttributes[indexPath.section]?.frame ?? .zero
        let cellY = cellRect.minY + headerFrame.maxY
        return .init(origin: .init(x: cellRect.minX, y: cellY), size: cellRect.size)
    }

    // MARK: cell寬
    private var itemWidth: CGFloat {
        guard let collectionView = collectionView else {
            return .zero
        }
        let numberOfColumn = CGFloat(layoutInfos.numberOfColumn)
        let fullWidth = collectionView.frame.width
        let contentWidth = fullWidth - layoutInfos.spacing * (numberOfColumn - 1)
        return contentWidth / numberOfColumn
    }

    // MARK: cell的rect
    private func itemRect(indexPath: IndexPath) -> CGRect {
        let cellHeight = cellLayoutAttributes[indexPath]?.frame.height ?? .zero
        let size: CGSize = .init(width: itemWidth, height: max(layoutInfos.cellHeight, cellHeight))
        let origin = itemOrigin(index: indexPath.item)
        return .init(origin: origin, size: size)
    }

    // MARK: cell的位置
    private func itemOrigin(index: Int) -> CGPoint {
        let column = CGFloat(index % layoutInfos.numberOfColumn)
        if column == .zero {
            groupCellMinY = lastCellMaxY
        }
        let locX = column * (itemWidth + layoutInfos.spacing)
        let locY = (layoutInfos.spacing) * CGFloat(index / layoutInfos.numberOfColumn) + groupCellMinY
        return .init(x: locX, y: locY)
    }

    // MARK: - setp 3: 設定content size, 超過才能scroll
    override var collectionViewContentSize: CGSize {
        guard
            let collectionView = collectionView,
            collectionView.frame != .zero
        else {
            return .zero
        }        
        let height = cellLayoutAttributes
            .map({ $0.value.frame.maxY })
            .max() ?? .zero
        let width = collectionView.frame.width
        return .init(width: width, height: height)
    }

    // MARK: - step 4: 依目前位置決定要顯示的cell
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let visibleHeader = headerLayoutAttributes.values
            .filter {
                rect.intersects($0.frame)
            }
        let visibleCell = cellLayoutAttributes.values
            .filter {
                rect.intersects($0.frame)
            }
        return visibleHeader + visibleCell
    }
    
    // MARK: - cell動態高度 reference:
    // https://tigerspike.com/uicollectionview-layout-with-self-sizing-cells-pt-1/
    
    override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        let oriHeight = cellLayoutAttributes[preferredAttributes.indexPath]?.frame.height ?? originalAttributes.frame.height
        return preferredAttributes.frame.height > oriHeight
    }

    override func invalidationContext(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {

        // Store Information from Preferred Attributes
        cellLayoutAttributes[preferredAttributes.indexPath] = preferredAttributes
        isSizing = true
        
        return super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
    }

    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
    }
}


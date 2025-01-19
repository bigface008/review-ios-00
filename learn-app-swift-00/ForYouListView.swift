//
//  ForYouViewController.swift
//  learn-app-swift-00
//
//  Created by 汪喆昊 on 2025/1/18.
//

import UIKit
import SnapKit

struct Picture {
    let width: Int
    let height: Int
    let url: String
}

struct ForYouItem {
    let uid: String
    let title: String
    let authorName: String
    let likeCount: Int
    let cover: Picture
}

protocol ForYouListDelegate: AnyObject {
    func forYouList(_ list: ForYouList, didClickItem item: ForYouItem)
    
    func forYouList(_ list: ForYouList, didLongPressItem item: ForYouItem)
    
    func forYouList(_ list: ForYouList, didLikeItem item: ForYouItem)
}

class ForYouList: UIView {
    private let cellID = "ForYouCell"
    
    private lazy var collectionView: UICollectionView = {
        let layout = ForYouListLayout()
        layout.delegate = self
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.register(ForYouCell.self, forCellWithReuseIdentifier: cellID)
        return view
    }()
    
    var items: [ForYouItem] = []
    
    weak var delegate: ForYouListDelegate?
    
    init() {
        super.init(frame: .zero)
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func addItems(_ newItems: [ForYouItem]) {
        let start = items.count
        let end = items.count + newItems.count - 1
        items.append(contentsOf: newItems)
        let indexPaths = (start...end).map { IndexPath(item: $0, section: 0) }
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: indexPaths)
        }
    }
}

extension ForYouList: UICollectionViewDelegate {
    
}

extension ForYouList: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        if let forYouCell = cell as? ForYouCell {
            forYouCell.setData(items[indexPath.item])
        }
        return cell
    }
}

fileprivate protocol ForYouListLayoutDelegate: AnyObject {
    func forYouListLayoutItemHeight(_ indexPath: IndexPath, width: CGFloat) -> CGFloat
}

extension ForYouList: ForYouListLayoutDelegate {
    func forYouListLayoutItemHeight(_ indexPath: IndexPath, width: CGFloat) -> CGFloat {
        let pic = items[indexPath.item].cover
        return CGFloat(pic.height) * width / CGFloat(pic.width)
    }
}

fileprivate class ForYouListLayout: UICollectionViewFlowLayout {
    weak var delegate: ForYouListLayoutDelegate?
    
    private var layoutAttributes = [UICollectionViewLayoutAttributes]()
    private var leftHeight: CGFloat = 0
    private var rightHeight: CGFloat = 0
    private var maxHeight: CGFloat = 0
    
    override init() {
        super.init()
        let margin: CGFloat = 8
        minimumInteritemSpacing = margin
        minimumLineSpacing = margin
        sectionInset = .init(top: margin, left: margin, bottom: margin, right: margin)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepare() {
        super.prepare()
        let itemWidth = (collectionView!.bounds.width - sectionInset.left - sectionInset.right - minimumInteritemSpacing) / CGFloat(2)
        let itemCount = collectionView!.numberOfItems(inSection: 0)
        
        for i in layoutAttributes.count..<itemCount {
            let indexPath = IndexPath(item: i, section: 0)
            let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let itemHeight = delegate?.forYouListLayoutItemHeight(indexPath, width: itemWidth) ?? 0
            
            let itemX = if leftHeight <= rightHeight {
                sectionInset.left
            } else {
                sectionInset.left + itemWidth + minimumInteritemSpacing
            }
            
            let itemY = min(leftHeight, rightHeight) + minimumInteritemSpacing
            if leftHeight <= rightHeight {
                leftHeight += itemHeight + minimumInteritemSpacing
            } else {
                rightHeight += itemHeight + minimumInteritemSpacing
            }
            
            attr.frame = .init(x: itemX, y: itemY, width: itemWidth, height: itemHeight)
            print("i=\(i) itemX=\(itemX) itemY=\(itemY) width=\(itemWidth) height=\(itemHeight)")
            layoutAttributes.append(attr)
        }
        
        maxHeight = max(leftHeight, rightHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes.filter { $0.frame.intersects(rect) }
    }
    
    override var collectionViewContentSize: CGSize {
        CGSize(width: collectionView!.bounds.width, height: maxHeight)
    }
}

fileprivate class ForYouCell: UICollectionViewCell {
    lazy var coverView = {
        let view = UIImageView()
        return view
    }()
    
    lazy var likeIconView = {
        let view = UIImageView()
        return view
    }()
    
    lazy var likeNumberView = {
        let view = UILabel()
        return view
    }()
    
    lazy var titleView = {
        let view = UILabel()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.backgroundColor = .systemBlue
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        addSubview(coverView)
//        addSubview(likeIconView)
//        addSubview(likeNumberView)
        addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setData(_ data: ForYouItem) {
        titleView.text = data.title
        likeNumberView.text = String(data.likeCount)
    }
}

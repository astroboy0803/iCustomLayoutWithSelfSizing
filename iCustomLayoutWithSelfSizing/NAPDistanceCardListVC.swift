//
//  NAPDistanceCardListVC.swift
//  iMeetingLayout
//
//  Created by i9400506 on 2021/11/9.
//

import UIKit

public class NAPDistanceCardListVC: UIViewController {

    @IBOutlet private var collectionView: UICollectionView!

    // TODO: test
    private var datas: [Int] = [10, 8, 15]

    private var ddd: [Int] = {
        Array(1...40)
            .map { _ in
                Int.random(in: 0...20)
            }
    }()
    
//    private var ddd: [Int] = [3,8,10,2,9,18,5,1,14,9,6,8,4,11,7]

    public init() {
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        super.loadView()
        setupUI()
        registers()
    }

    private func setupUI() {
        let layout = CellSizingLayout(layoutInfos: .init(cellHeight: 50, headerHeight: 0, spacing: 0, numberOfColumn: 3))
        layout.isHeader = false
        self.collectionView.collectionViewLayout = layout

    }

    private func registers() {
        collectionView.register(LabelCell.self, forCellWithReuseIdentifier: LabelCell.identifier)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}

extension NAPDistanceCardListVC: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ddd.count
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LabelCell.identifier, for: indexPath)
        if let labelCell = cell as? LabelCell {
            var text = "\(indexPath)"
            for idx in 0..<ddd[indexPath.item] {
                text += "\nrandom=\(idx)"
            }
            labelCell.setup(text: text)
        }

        return cell
    }
}

// MARK: method 2: 可以取到collectionview正確的大小
extension NAPDistanceCardListVC: UICollectionViewDelegateFlowLayout {
//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        .init(width: collectionView.frame.width, height: 30)
//    }
//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        5
//    }
//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        5
//    }
}

//
//  LabelCell.swift
//  iMeetingLayout
//
//  Created by BruceHuang on 2021/11/9.
//

import UIKit

public class LabelCell: UICollectionViewCell {
    static let identifier = String(describing: self)

    private let textLabel: UILabel = .init()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setting()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setting()
    }

    private func setting() {
        setupUI()
        setupLayout()
    }

    private func setupUI() {
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 10

        textLabel.numberOfLines = .zero
        textLabel.font = .systemFont(ofSize: 18)
        textLabel.textColor = .black
        textLabel.textAlignment = .center
        
        textLabel.layer.borderColor = UIColor.systemBlue.cgColor
        textLabel.layer.borderWidth = 2
        textLabel.layer.cornerRadius = 10

        contentView.addSubview(textLabel)
    }

    private func setupLayout() {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            textLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10),
            textLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            textLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10)
        ])
    }

    public final func setup(text: String) {
        textLabel.text = text
    }

    override public func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
//        var frame = layoutAttributes.frame
//        frame.size.height = ceil(size.height)
//        layoutAttributes.frame = frame
//        return layoutAttributes
        
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
        
//        textLabel.preferredMaxLayoutWidth = layoutAttributes.frame.width
//        layoutAttributes.frame.size.height = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
//        return layoutAttributes
    }
}

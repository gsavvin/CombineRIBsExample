//
//  ProductCell.swift
//  CombineRIBsExample
//
//  Created by Andrey Stopin on 24.01.2023.
//

import UIKit

final class LabelCell: UICollectionViewCell, CollectionViewRegisterable {
  private let label = UILabel()
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    initialSetup()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initialSetup()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    label.text = nil
  }
  
  // MARK: Interface
  
  func setTitle(_ text: String, textColor: UIColor, fontSize: CGFloat, backgroundColor: UIColor) {
    label.text = text
    label.textColor = textColor
    label.font = UIFont.systemFont(ofSize: fontSize)
    
    self.backgroundColor = backgroundColor
  }
  
  // MARK: Private Usage
  
  private func initialSetup() {
    backgroundColor = .white
    
    label.translatesAutoresizingMaskIntoConstraints = false
    addSubview(label)
    
    label.numberOfLines = 0
    label.textAlignment = .center
  
    layer.cornerRadius = 16
    
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 16),
      label.centerXAnchor.constraint(equalTo: centerXAnchor),
      label.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }
}

//
//  ProductCell.swift
//  CombineRIBsExample
//
//  Created by Andrey Stopin on 24.01.2023.
//

import UIKit

final class ProductCell: UICollectionViewCell, CollectionViewRegisterable {
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
  
  func setTitle(_ title: String) {
    label.text = title
    label.textColor = .black
  }
  
  // MARK: Private Usage
  
  private func initialSetup() {
    backgroundColor = .red
    
    label.translatesAutoresizingMaskIntoConstraints = false
    addSubview(label)
    
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: centerXAnchor),
      label.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }
}

//
//  Catalog2Cell.swift
//  CombineRIBsExample
//
//  Created by Andrey Stopin on 25.01.2023.
//

import UIKit

final class Catalog2Cell: UICollectionViewCell, CollectionViewRegisterable {
  // MARK: Private properties
  
  private let titleLabel = UILabel()
  private let separatorView = UIView()
  private let trailingIcon = UIImageView()
  
  // MARK: Overriden
  
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
    titleLabel.text = nil
  }
  
  // MARK: Interface
  
  func setItem(item: CatalogCategory) {
    titleLabel.text = item.title
  }
  
  // MARK: Private
  
  private func initialSetup() {
    separatorView.backgroundColor = .gray.withAlphaComponent(0.1)
    trailingIcon.image = UIImage(systemName: "chevron.right")
    trailingIcon.tintColor = .black
    trailingIcon.contentMode = .scaleAspectFit
    
    constraintsInitialSetup()
  }
  
  private func constraintsInitialSetup() {
    [titleLabel, separatorView, trailingIcon].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      addSubview($0)
    }
    
    NSLayoutConstraint.activate([
      titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
      
      separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
      trailingAnchor.constraint(equalTo: separatorView.trailingAnchor),
      
      separatorView.heightAnchor.constraint(equalToConstant: 1),
      separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
      
      trailingIcon.heightAnchor.constraint(equalToConstant: 20),
      trailingIcon.widthAnchor.constraint(equalToConstant: 20),
      trailingAnchor.constraint(equalTo: trailingIcon.trailingAnchor),
      
      trailingIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
      
      titleLabel.trailingAnchor.constraint(equalTo: trailingIcon.leadingAnchor, constant: 8)
    ])
  }
}

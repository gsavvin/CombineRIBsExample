//
//  UICollectionView+Extensions.swift
//  CombineRIBsExample
//
//  Created by Andrey Stopin on 24.01.2023.
//

import UIKit

extension UICollectionView {
  // MARK: - Dequeue
  
  // Cells
  public func dequeue<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T where T: DequeuableReusableView {
    guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
      fatalError("Could not dequeue cell with identifier \(T.reuseIdentifier)")
    }
    
    return cell
  }
  
  public func register<T: UICollectionViewCell>(_: T.Type) where T: CollectionViewRegisterable {
    register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
  }
}

public protocol DequeuableReusableView: AnyObject {
  /// Defines something that can be dequeued from a table view using a reuseIdentifier
  /// A cell that is defined in a storyboard should implement this.
  static var reuseIdentifier: String { get }
}

extension DequeuableReusableView {
  /// Default implementation of reuseIdentifier is to use the class name,
  /// this can be specifically implemented for difference behaviour
  public static var reuseIdentifier: String {
    String(describing: self)
  }
}

public protocol CollectionViewRegisterable: DequeuableReusableView {
  /// Defines something that can be registered with a collection view, using the reuseIdentifier
  /// A cell that is laid out programmatically or in a nib (that also implements NibLoadable) should implement this
}

//
//  Catalog2ViewController.swift
//  CombineRIBsExample
//
//  Created by Andrey Stopin on 25.01.2023.
//

import Combine
import UIKit

final class Catalog2ViewController: UIViewController, Catalog2ViewControllable {
  // MARK: Private properties
  
  private var interactorOutput: Catalog2InteractorOutput?
  private let viewOutput = ViewOutput()
  
  private var dataSource: [CatalogCategory] = [] {
    didSet {
      collectionView.reloadData()
    }
  }
  
  private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
  
  
  // MARK: Overriden
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetup()
    bindIfNeeded()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    if isMovingFromParent {
      viewOutput.$viewDidDissappear.send(Void())
    }
  }
}

extension Catalog2ViewController {
  private func initialSetup() {
    
    title = "Каталог"
    
    view.addStretchedToBounds(subview: collectionView)
    
    collectionView.collectionViewLayout = makeLayout()
    collectionView.dataSource = self
    collectionView.delegate = self
    
    collectionView.register(Catalog2Cell.self)
  }
  
  
  private func makeLayout() -> UICollectionViewCompositionalLayout {
    UICollectionViewCompositionalLayout { _, _ in
      let itemHeight = CGFloat(70)
      
      let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(itemHeight))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      item.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                   leading: 16,
                                                   bottom: 0,
                                                   trailing: 16)
      
      let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(itemHeight))
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      
      let section = NSCollectionLayoutSection(group: group)
      section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                      leading: 0,
                                                      bottom: 12,
                                                      trailing: 0)
      
      return section
    }
  }
}

// MARK: - BindableView

extension Catalog2ViewController: BindableView {
  func getOutput() -> any Catalog2ViewOutput { viewOutput }
  
  func bindWith(input: Catalog2InteractorOutput) {
    interactorOutput = input
    bindIfNeeded()
  }
  
  private func bindIfNeeded() {
    guard let input = interactorOutput, isViewLoaded else { return }
    
    dataSource = input.categories
  }
}

extension Catalog2ViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { dataSource.count }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let item = dataSource[uncheckedIndex: indexPath.row] else { return UICollectionViewCell() }
    let cell: Catalog2Cell = collectionView.dequeue(forIndexPath: indexPath)
    cell.setItem(item: item)
    return cell
  }
}

extension Catalog2ViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard dataSource[uncheckedIndex: indexPath.row] != nil else { return }
    viewOutput.$categoryTap.send(Void())
  }
}

// MARK: - Helpers

// MARK: - ViewOutput

extension Catalog2ViewController {
  private struct ViewOutput: Catalog2ViewOutput {
    @SendablePublisher var viewDidDissappear: AnyDriver<Void>
    @SendablePublisher var categoryTap: AnyDriver<Void>
  }
}

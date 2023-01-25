//
//  Catalog3ViewController.swift
//  CombineRIBsExample
//
//  Created by Andrey Stopin on 24.01.2023.
//

import Combine
import UIKit

final class Catalog3ViewController: UIViewController, Catalog3ViewControllable {
  // MARK: Private properties
  
  private var presenterOutput: Catalog3PresenterOutput?
  private let viewOutput = ViewOutput()
  
  private var cancelBag = CancelBag()
  
  private typealias DataSource = UICollectionViewDiffableDataSource<Section, RowItem>
  private lazy var dataSource = DataSource(collectionView: collectionView, cellProvider: CollectionViewHelper.makeProvider())
  
  private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
  
  // MARK: Overriden
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetup()
    bindIfNeeded()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    viewOutput.$viewDidDissappear.send(Void())
  }
}

extension Catalog3ViewController {
  private func initialSetup() {
    collectionView.collectionViewLayout = makeLayout()
    collectionView.register(LabelCell.self)
    
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    view.addStretchedToBounds(subview: collectionView)
    
    view.backgroundColor = .brown
  }
  
  private func makeLayout() -> UICollectionViewCompositionalLayout {
    UICollectionViewCompositionalLayout { _, _ in
      let itemBottomInset: CGFloat = 32
      let itemHeight = 200 + itemBottomInset
      
      let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(itemHeight))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      item.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                   leading: 8,
                                                   bottom: itemBottomInset,
                                                   trailing: 8)
      
      let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(itemHeight))
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

      let section = NSCollectionLayoutSection(group: group)
      section.contentInsets = NSDirectionalEdgeInsets(top: 8,
                                                      leading: 8,
                                                      bottom: 0,
                                                      trailing: 8)
      
      return section
    }
  }
}

// MARK: - BindableView

extension Catalog3ViewController: BindableView {
  func getOutput() -> any Catalog3ViewOutput { viewOutput }
  
  func bindWith(input: Catalog3PresenterOutput) {
    presenterOutput = input
    bindIfNeeded()
  }
  
  private func bindIfNeeded() {
    guard let input = presenterOutput, isViewLoaded else { return }
    bindWith(viewModel: input.viewModel)
  }
  
  private func bindWith(viewModel: AnyPublisher<[String], Never>) {
    viewModel.map { model -> [Section] in
      var rowItems: [RowItem] = []
      rowItems += model.map { RowItem.product($0) }
      return [Section(items: rowItems)]
    }
    .sink { [weak self] sections in
      var snapshot = NSDiffableDataSourceSnapshot<Section, RowItem>()
      for section in sections {
        snapshot.appendSections([section])
        snapshot.appendItems(section.items)
      }
      
      self?.dataSource.apply(snapshot)
    }
    .store(in: &cancelBag)
  }
}

// MARK: - Helpers

extension Catalog3ViewController {
  private enum CollectionViewHelper {
    static func makeProvider() -> DataSource.CellProvider {
      { collectionView, indexPath, item in
        switch item {
        case .product(let title):
          let cell: LabelCell = collectionView.dequeue(forIndexPath: indexPath)
          cell.setTitle(title,
                        textColor: .black,
                        fontSize: 16,
                        backgroundColor: .black.withAlphaComponent(0.04))
          return cell
        }
      }
    }
  }
}

// MARK: - ViewOutput

extension Catalog3ViewController {
  private struct ViewOutput: Catalog3ViewOutput {
    @SendablePublisher var retryButtonTap: AnyDriver<Void>
    @SendablePublisher var viewDidDissappear: AnyDriver<Void>
  }
}

// MARK: - Section, RowItem

extension Catalog3ViewController {
  struct Section: Hashable {
    var items: [RowItem]
    
    init(items: [RowItem]) {
      self.items = items
    }
  }

  enum RowItem: Hashable {
    case product(String)
  }
}

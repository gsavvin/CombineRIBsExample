//
//  MainViewController.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

import Combine
import UIKit

final class MainViewController: UIViewController, MainViewControllable {
  // MARK: Private properties
  
  private var presenterOutput: MainPresenterOutput?
  private let viewOutput = ViewOutput()
  
  private var cancelBag = CancelBag()
  
  private typealias DataSource = UICollectionViewDiffableDataSource<Section, RowItem>
  private lazy var dataSource = DataSource(collectionView: collectionView, cellProvider: CollectionViewHelper.makeProvider())
  private var dataSourceSnapshot: NSDiffableDataSourceSnapshot<Section, RowItem>?
  
  private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
  
  private let activityView = UIActivityIndicatorView()
  
  // MARK: Overriden
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initialSetup()
    bindIfNeeded()
  }
  
  private func initialSetup() {
    view.backgroundColor = .white
    
    collectionView.collectionViewLayout = makeLayout()
    collectionView.register(LabelCell.self)
    
    collectionView.delegate = self
    
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    view.addStretchedToBounds(subview: collectionView)
    
    activityView.style = .large
    activityView.color = .black
    view.addStretchedToBounds(subview: activityView)
  }
    
    private func makeLayout() -> UICollectionViewCompositionalLayout {
      UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment -> NSCollectionLayoutSection? in
        guard let self, let section = self.dataSourceSnapshot?.sectionIdentifiers[uncheckedIndex: sectionIndex] else { return nil }
        
        switch section.identity {
        case .banners: return self.makeBannersSection()
        case .categories: return self.makeCategoriesSection()
        }
      }
    }
  
  func makeBannersSection() -> NSCollectionLayoutSection {
    let itemHeight = CGFloat(200)
    
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
                                                    bottom: 24,
                                                    trailing: 0)
    
    return section
  }
  
  func makeCategoriesSection() -> NSCollectionLayoutSection {
    let itemBottomInset: CGFloat = 16
    let itemHeight = 150 + itemBottomInset
    
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

// MARK: - BindableView

extension MainViewController: BindableView {
  func getOutput() -> any MainViewOutput { viewOutput }
  
  func bindWith(input: MainPresenterOutput) {
    presenterOutput = input
    bindIfNeeded()
  }
  
  private func bindIfNeeded() {
    guard let input = presenterOutput, isViewLoaded else { return }
    
    cancelBag.collect {
      input.isLoadingIndicatorVisible
        .drive { [weak self] isVisible in
          guard let loader = self?.activityView else { return }
          loader.isHidden = !isVisible
          isVisible ? loader.startAnimating() : loader.stopAnimating()
        }
    }
    
    bindWith(viewModel: input.viewModel)
  }
  
    private func bindWith(viewModel: AnyDriver<MainScreenData>) {
      viewModel.map { model -> [Section] in
        var sections: [Section] = []
        
        let bannersSection = Section(identity: .banners, items: [RowItem.banner(model.banner)])
        sections.append(bannersSection)
        
        let categories = model.categories.map { RowItem.category($0) }
        let categoriesSection = Section(identity: .categories, items: categories)
        sections.append(categoriesSection)
        
        return sections
      }
      .drive { [weak self] sections in
        var snapshot = NSDiffableDataSourceSnapshot<Section, RowItem>()

        for section in sections {
          snapshot.appendSections([section])
          snapshot.appendItems(section.items)
        }
  
        self?.dataSourceSnapshot = snapshot
        self?.dataSource.apply(snapshot)
      }
      .store(in: &cancelBag)
    }
}

// MARK: - Collection

extension MainViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let section = self.dataSourceSnapshot?.sectionIdentifiers[uncheckedIndex: indexPath.section],
          let item = section.items[uncheckedIndex: indexPath.item] else {
      return
    }
    
    switch item {
    case .banner(let banner): viewOutput.$bannerTap.send(banner)
    case .category(let category): viewOutput.$categoryTap.send(category)
    }
  }
}

  
// MARK: - Helpers

extension MainViewController {
  private enum CollectionViewHelper {
    static func makeProvider() -> DataSource.CellProvider {
      { collectionView, indexPath, item in
        switch item {
        case .banner(let banner):
          let cell:LabelCell  = collectionView.dequeue(forIndexPath: indexPath)
          cell.setTitle(banner.title,
                        textColor: .white,
                        fontSize: 36,
                        backgroundColor: banner.backgroundColor)
          return cell
        case .category(let category):
          let cell: LabelCell = collectionView.dequeue(forIndexPath: indexPath)
          cell.setTitle(category.title,
                        textColor: .black,
                        fontSize: 18,
                        backgroundColor: .random().withAlphaComponent(0.2))
          return cell
        }
      }
    }
  }
}

// MARK: - ViewOutput

extension MainViewController {
  private struct ViewOutput: MainViewOutput {
    @SendablePublisher var bannerTap: AnyPublisher<Banner, Never>
    @SendablePublisher var categoryTap: AnyPublisher<CatalogCategory, Never>
  }
}

// MARK: - Section, RowItem
  
extension MainViewController {
  struct Section: Hashable {
    var identity: Identity

    enum Identity: Hashable {
      case banners
      case categories
    }
    
    var items: [RowItem]
    
    init(identity: Identity, items: [RowItem]) {
      self.items = items
      self.identity = identity
    }
  }
  
  enum RowItem: Hashable {
    case banner(Banner)
    case category(CatalogCategory)
  }
}


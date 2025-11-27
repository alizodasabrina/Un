import UIKit
import SnapKit

class SearchResultsViewController: UIViewController {
    
    var searchQuery: String = ""
    private var images: [UnsplashImage] = []
    
    private var collectionView: UICollectionView!
    private let loadingIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Search Results"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        setupUI()
        loadSearchResults()
    }
    
    private func setupUI() {
        loadingIndicator.style = .medium
        loadingIndicator.color = .white
        view.addSubview(loadingIndicator)
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        flow.minimumInteritemSpacing = 8
        flow.minimumLineSpacing = 8
        flow.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flow)
        collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func loadSearchResults() {
        print("📡 Загружаю: \(searchQuery)")
        loadingIndicator.startAnimating()
        
        UnsplashNetworkManager.shared.fetchImagesByCategory(category: searchQuery, perPage: 100) { [weak self] images, error in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                
                if let images = images, !images.isEmpty {
                    print("✅ Загружено \(images.count) фоток")
                    self?.images = images
                    self?.collectionView.reloadData()
                } else if let error = error {
                    print("❌ Ошибка: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension SearchResultsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! HomeCollectionViewCell
        cell.image = images[indexPath.item]
        return cell
    }
}

extension SearchResultsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let targetWidth = collectionView.bounds.width
        
        guard indexPath.item < images.count else {
            return CGSize(width: targetWidth, height: targetWidth)
        }
        
        let image = images[indexPath.item]
        
        let spacing: CGFloat = 8
        let sectionInset: CGFloat = 8
        let availableWidth = targetWidth - (sectionInset * 2) - spacing
        let itemWidth = availableWidth / 2
        let itemHeight = itemWidth * image.aspectRatio
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
}

extension SearchResultsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        detailVC.images = images
        detailVC.currentIndex = indexPath.item
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

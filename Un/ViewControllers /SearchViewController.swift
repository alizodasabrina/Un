import UIKit
import SnapKit

class SearchViewController: UIViewController {
    
    private let categories = [
        "Nature", "Texture", "Black and White", "Abstract", "Space",
        "Minimal", "Animals", "Sky", "Flowers", "Travel",
        "Underwater", "Drones", "Architecture", "Gradient"
    ]
    
    private var discoverImages: [UnsplashImage] = []
    private var selectedCategory: String = "Nature"
    
    private var categoriesCollectionView: UICollectionView!
    private var discoverCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupSearchBar()
        setupUI()
        loadDiscoverImages()
    }
    
    private func setupSearchBar() {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search photos, collections, users"
        searchBar.barStyle = .black
        searchBar.barTintColor = .black
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = .white
        searchBar.delegate = self
        
        let textField = searchBar.value(forKey: "searchField") as? UITextField
        textField?.textColor = .white
        textField?.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        
        navigationItem.titleView = searchBar
    }
    
    private func setupUI() {
        let mainScrollView = UIScrollView()
        mainScrollView.backgroundColor = .black
        mainScrollView.showsVerticalScrollIndicator = true
        view.addSubview(mainScrollView)
        
        mainScrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.bottom.equalToSuperview()
        }
        
        let categoryTitle = UILabel()
        categoryTitle.text = "Browse by Category"
        categoryTitle.textColor = .white
        categoryTitle.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        mainScrollView.addSubview(categoryTitle)
        
        categoryTitle.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
            make.right.equalToSuperview()
        }
        
        let categoriesFlow = UICollectionViewFlowLayout()
        categoriesFlow.scrollDirection = .horizontal
        categoriesFlow.minimumInteritemSpacing = 6
        categoriesFlow.minimumLineSpacing = 6
        categoriesFlow.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        categoriesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: categoriesFlow)
        categoriesCollectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
        categoriesCollectionView.backgroundColor = .black
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.delegate = self
        categoriesCollectionView.isScrollEnabled = true
        categoriesCollectionView.showsHorizontalScrollIndicator = false
        
        mainScrollView.addSubview(categoriesCollectionView)
        
        categoriesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(categoryTitle.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(232)
        }
        
        let discoverTitle = UILabel()
        discoverTitle.text = "Discover"
        discoverTitle.textColor = .white
        discoverTitle.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        mainScrollView.addSubview(discoverTitle)
        
        discoverTitle.snp.makeConstraints { make in
            make.top.equalTo(categoriesCollectionView.snp.bottom).offset(20)
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview()
        }
        
        let discoverFlow = UICollectionViewFlowLayout()
        discoverFlow.scrollDirection = .vertical
        discoverFlow.minimumInteritemSpacing = 8
        discoverFlow.minimumLineSpacing = 8
        discoverFlow.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        discoverCollectionView = UICollectionView(frame: .zero, collectionViewLayout: discoverFlow)
        discoverCollectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: "HomeCell")
        discoverCollectionView.backgroundColor = .black
        discoverCollectionView.dataSource = self
        discoverCollectionView.delegate = self
        discoverCollectionView.isScrollEnabled = false
        
        mainScrollView.addSubview(discoverCollectionView)
        
        discoverCollectionView.snp.makeConstraints { make in
            make.top.equalTo(discoverTitle.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(8)
            make.width.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(400)
        }
    }
    
    private func loadDiscoverImages() {
        UnsplashNetworkManager.shared.fetchImages(perPage: 100) { [weak self] images, error in
            DispatchQueue.main.async {
                if let images = images {
                    self?.discoverImages = images
                    self?.discoverCollectionView.reloadData()
                } else if let error = error {
                    print("❌ Ошибка: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoriesCollectionView {
            return categories.count
        }
        return discoverImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoriesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            cell.configure(with: categories[indexPath.item])
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath) as! HomeCollectionViewCell
        if indexPath.item < discoverImages.count {
            cell.image = discoverImages[indexPath.item]
        }
        return cell
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoriesCollectionView {
            return CGSize(width: 110, height: 110)
        }
        
        let width = (collectionView.bounds.width - 16) / 2
        if indexPath.item < discoverImages.count {
            let image = discoverImages[indexPath.item]
            let height = width * image.aspectRatio
            return CGSize(width: width, height: height)
        }
        return CGSize(width: width, height: width)
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoriesCollectionView {
            selectedCategory = categories[indexPath.item]
            let gridVC = CategoryGridViewController()
            gridVC.category = selectedCategory
            navigationController?.pushViewController(gridVC, animated: true)
        } else if collectionView == discoverCollectionView {
            let detailVC = DetailViewController()
            detailVC.images = discoverImages
            detailVC.currentIndex = indexPath.item
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        let resultsVC = SearchResultsViewController()
        resultsVC.searchQuery = searchText
        navigationController?.pushViewController(resultsVC, animated: true)
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}

class CategoryCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        let gradient = UIView()
        gradient.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        contentView.addSubview(gradient)
        
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 2
        contentView.addSubview(label)
        
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradient.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(8)
        }
    }
    
    func configure(with categoryName: String) {
        label.text = categoryName
        
        UnsplashNetworkManager.shared.fetchImagesByCategory(category: categoryName, perPage: 1) { [weak self] images, _ in
            DispatchQueue.main.async {
                if let firstImage = images?.first, let url = URL(string: firstImage.url) {
                    URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self?.imageView.image = image
                            }
                        }
                    }.resume()
                }
            }
        }
    }
}

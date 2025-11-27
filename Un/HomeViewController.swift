//
//  HomeViewController.swift
//  Unpl
//
//  Created by Sabrina Mavlyanova on 21/11/25.
//
import UIKit
import SnapKit

class HomeViewController: UIViewController {
    
    private let categories = [
        "Editorial", "Wallpapers", "3D Renders", "Nature", "Texture", "Film", "Architecture",
        "Street Photography", "Experimental", "Travel", "People",
        "3D", "Flat", "Hand Drawn", "Icons", "Line Art", "Patterns"
    ]
    
    private var contentItems: [UnsplashImage] = []
    private var selectedCategory: String = "Editorial"
    private var gridColumns: Int = 2 {
        didSet {
            updateCollectionViewLayout()
        }
    }
    private var gridButton: UIButton?
    
    private lazy var categoriesCollectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        flow.minimumInteritemSpacing = 12
        flow.minimumLineSpacing = 12
        flow.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flow)
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CategoryCell")
        collection.backgroundColor = .black
        collection.dataSource = self
        collection.delegate = self
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        flow.minimumInteritemSpacing = 8
        flow.minimumLineSpacing = 8
        flow.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flow)
        collection.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: "HomeCell")
        collection.backgroundColor = .black
        collection.dataSource = self
        collection.delegate = self
        return collection
    }()
    
    private var loadingIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureNavigationBar()
        addSubview()
        makeConstraints()
        setupLoadingIndicator()
        loadImages()
    }
    
    private func setupLoadingIndicator() {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        view.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        self.loadingIndicator = indicator
    }
    
    private func loadImages() {
        print("📡 Загружаю картинки: \(selectedCategory)")
        loadingIndicator?.startAnimating()
        
        UnsplashNetworkManager.shared.fetchImagesByCategory(category: selectedCategory, perPage: 30) { [weak self] images, error in
            DispatchQueue.main.async {
                self?.loadingIndicator?.stopAnimating()
                
                if let images = images, !images.isEmpty {
                    print("✅ Загружено \(images.count) картинок")
                    self?.contentItems = images
                    self?.collectionView.reloadData()
                } else if let error = error {
                    print("❌ Ошибка: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func toggleGridLayout() {
        gridColumns = (gridColumns == 2) ? 1 : 2
        let newImage = gridColumns == 1 ?
            UIImage(systemName: "square.fill") :
            UIImage(systemName: "square.grid.2x2.fill")
        gridButton?.setImage(newImage, for: .normal)
    }
    
    private func updateCollectionViewLayout() {
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        flow.minimumInteritemSpacing = 8
        flow.minimumLineSpacing = 8
        flow.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        collectionView.collectionViewLayout = flow
        collectionView.reloadData()
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.title = "Unsplash"
        
        // Left button - logo
        let logoImageView = UIImageView(image: UIImage(named: "logo"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoImageView)
        
        // Right button - grid toggle
        let menuButton = UIButton(type: .system)
        menuButton.setImage(UIImage(systemName: "square.grid.2x2.fill"), for: .normal)
        menuButton.tintColor = .white
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.addTarget(self, action: #selector(toggleGridLayout), for: .touchUpInside)
        menuButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        menuButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.gridButton = menuButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: menuButton)
    }
    
    private func addSubview() {
        view.addSubview(categoriesCollectionView)
        view.addSubview(collectionView)
    }
    
    private func makeConstraints() {
        categoriesCollectionView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(60)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(categoriesCollectionView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoriesCollectionView {
            return categories.count
        }
        return contentItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoriesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath)
            cell.backgroundColor = .clear
            cell.layer.cornerRadius = 0
            cell.layer.masksToBounds = true
            
            for subview in cell.contentView.subviews {
                subview.removeFromSuperview()
            }
            
            let label = UILabel()
            label.text = categories[indexPath.item]
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.addSubview(label)
            label.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(8)
            }
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath) as! HomeCollectionViewCell
        if indexPath.item < contentItems.count {
            cell.image = contentItems[indexPath.item]
        }
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoriesCollectionView {
            let label = UILabel()
            label.text = categories[indexPath.item]
            label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            label.sizeToFit()
            return CGSize(width: label.frame.width + 30, height: 50)
        }
        
        let targetWidth = collectionView.bounds.width
        
        guard indexPath.item < contentItems.count else {
            return CGSize(width: targetWidth, height: targetWidth)
        }
        
        let image = contentItems[indexPath.item]
        
        if gridColumns == 1 {
            let height = targetWidth * image.aspectRatio
            return CGSize(width: targetWidth, height: height)
        } else {
            let spacing: CGFloat = 8
            let sectionInset: CGFloat = 8
            let availableWidth = targetWidth - (sectionInset * 2) - spacing
            let itemWidth = availableWidth / 2
            let itemHeight = itemWidth * image.aspectRatio
            return CGSize(width: itemWidth, height: itemHeight)
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoriesCollectionView {
            selectedCategory = categories[indexPath.item]
            print("✅ Категория: \(selectedCategory)")
            loadImages()
            return
        }
        
        let detailVC = DetailViewController()
        detailVC.images = contentItems
        detailVC.currentIndex = indexPath.item
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            loadImages()
            return
        }
        
        UnsplashNetworkManager.shared.fetchImagesByCategory(category: searchText, perPage: 30) { [weak self] images, error in
            DispatchQueue.main.async {
                if let images = images {
                    self?.contentItems = images
                    self?.collectionView.reloadData()
                    searchBar.resignFirstResponder()
                } else if let error = error {
                    print("❌ Ошибка: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        loadImages()
    }
}

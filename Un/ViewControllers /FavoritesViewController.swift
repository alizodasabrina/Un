import UIKit
import SnapKit

class FavoritesViewController: UIViewController {
    
    private var favoriteImages: [UnsplashImage] = []
    private var collectionView: UICollectionView!
    private let emptyStateView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Favorites"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        setupUI()
        loadFavorites()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }
    
    private func setupUI() {
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        flow.minimumInteritemSpacing = 8
        flow.minimumLineSpacing = 8
        flow.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flow)
        collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: "FavoriteCell")
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        setupEmptyState()
    }
    
    private func setupEmptyState() {
        emptyStateView.backgroundColor = .black
        view.addSubview(emptyStateView)
        
        emptyStateView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "Contribute to Unsplash"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        titleLabel.textAlignment = .left
        emptyStateView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        let uploadBox = UIView()
        uploadBox.backgroundColor = .clear
        emptyStateView.addSubview(uploadBox)
        
        uploadBox.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(32)
            make.height.equalTo(280)
        }
        
        DispatchQueue.main.async {
            let shapeLayer = CAShapeLayer()
            let path = UIBezierPath(roundedRect: uploadBox.bounds, cornerRadius: 12)
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = UIColor.white.withAlphaComponent(0.3).cgColor
            shapeLayer.lineWidth = 2
            shapeLayer.lineDashPattern = [5, 5]
            uploadBox.layer.addSublayer(shapeLayer)
        }
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(systemName: "photo")
        uploadImageView.tintColor = .gray
        uploadImageView.contentMode = .scaleAspectFit
        uploadBox.addSubview(uploadImageView)
        
        uploadImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        let plusButton = UIButton()
        plusButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        plusButton.tintColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        plusButton.isUserInteractionEnabled = false
        uploadBox.addSubview(plusButton)
        
        plusButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.bottom.equalTo(uploadImageView.snp.bottom)
            make.right.equalTo(uploadImageView.snp.right)
        }
        
        let uploadLabel = UILabel()
        uploadLabel.text = "Upload your photo to\nthe largest library of\nopen photography."
        uploadLabel.textColor = .white
        uploadLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        uploadLabel.textAlignment = .center
        uploadLabel.numberOfLines = 0
        uploadBox.addSubview(uploadLabel)
        
        uploadLabel.snp.makeConstraints { make in
            make.top.equalTo(uploadImageView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualToSuperview().inset(16)
        }
    }
    
    private func loadFavorites() {
        favoriteImages = AppDelegate.favoriteImages
        print("📌 Загружено \(favoriteImages.count) избранных")
        updateUI()
    }
    
    private func updateUI() {
        if favoriteImages.isEmpty {
            emptyStateView.isHidden = false
            collectionView.isHidden = true
        } else {
            emptyStateView.isHidden = true
            collectionView.isHidden = false
            collectionView.reloadData()
        }
    }
}

extension FavoritesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        favoriteImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCell", for: indexPath) as! HomeCollectionViewCell
        cell.image = favoriteImages[indexPath.item]
        return cell
    }
}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let targetWidth = collectionView.bounds.width
        
        guard indexPath.item < favoriteImages.count else {
            return CGSize(width: targetWidth, height: targetWidth)
        }
        
        let image = favoriteImages[indexPath.item]
        
        let spacing: CGFloat = 8
        let sectionInset: CGFloat = 8
        let availableWidth = targetWidth - (sectionInset * 2) - spacing
        let itemWidth = availableWidth / 2
        let itemHeight = itemWidth * image.aspectRatio
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
}

extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        detailVC.images = favoriteImages
        detailVC.currentIndex = indexPath.item
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

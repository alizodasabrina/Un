import UIKit
import SnapKit

class DetailViewController: UIViewController {
    
    var images: [UnsplashImage] = []
    var currentIndex: Int = 0
    private let imageCache = NSCache<NSString, UIImage>()
    
    private let imageView = UIImageView()
    private let scrollView = UIScrollView()
    private let infoLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView()
    private let likeButton = UIButton()
    private let infoButton = UIButton()
    private let titleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.hidesBackButton = false
        
        setupUI()
        displayImage()
    }
    
    private func setupUI() {
        loadingIndicator.style = .medium
        loadingIndicator.color = .white
        view.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.left.right.equalToSuperview().inset(60)
            make.height.equalTo(40)
        }
        
        infoButton.setImage(UIImage(systemName: "info.circle.fill"), for: .normal)
        infoButton.tintColor = .white
        infoButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        infoButton.layer.cornerRadius = 8
        infoButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
        view.addSubview(infoButton)
        infoButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(50)
        }
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(infoButton.snp.top).offset(-16)
        }
        
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        scrollView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        
        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        likeButton.tintColor = .white
        likeButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        likeButton.layer.cornerRadius = 32
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        
        var config = UIButton.Configuration.plain()
        config.imagePadding = 10
        config.image = UIImage(systemName: "heart")
        likeButton.configuration = config
        
        view.addSubview(likeButton)
        likeButton.snp.makeConstraints { make in
            make.bottom.equalTo(scrollView.snp.bottom).offset(-16)
            make.right.equalTo(scrollView.snp.right).offset(-16)
            make.width.height.equalTo(64)
        }
        
        infoLabel.textColor = .white
        infoLabel.textAlignment = .center
        infoLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.bottom.equalTo(infoButton.snp.top).offset(-16)
            make.left.right.equalToSuperview().inset(16)
        }
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
    }
    
    private func displayImage() {
        guard currentIndex >= 0, currentIndex < images.count else { return }
        
        let image = images[currentIndex]
        print("🖼️ \(currentIndex + 1)/\(images.count)")
        
        loadingIndicator.startAnimating()
        
        let cacheKey = NSString(string: image.url)
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                self.imageView.image = cachedImage
                self.scrollView.zoomScale = 1.0
                self.infoLabel.text = "(\(self.currentIndex + 1) из \(self.images.count))"
            }
            return
        }
        
        if let url = URL(string: image.url) {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 10
            config.timeoutIntervalForResource = 30
            let session = URLSession(configuration: config)
            
            session.dataTask(with: url) { [weak self] data, _, error in
                if let data = data, let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.loadingIndicator.stopAnimating()
                        self?.imageView.image = uiImage
                        self?.scrollView.zoomScale = 1.0
                        self?.infoLabel.text = "(\(self?.currentIndex ?? 0 + 1) из \(self?.images.count ?? 0))"
                        
                        self?.imageCache.setObject(uiImage, forKey: cacheKey)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.loadingIndicator.stopAnimating()
                        print("❌ Ошибка: \(error?.localizedDescription ?? "Unknown")")
                    }
                }
            }.resume()
        }
    }
    
    @objc private func likeTapped() {
        let currentImage = images[currentIndex]
        
        if likeButton.currentImage == UIImage(systemName: "heart") {
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            likeButton.tintColor = .red
            
            var favorites = AppDelegate.favoriteImages
            if !favorites.contains(where: { $0.id == currentImage.id }) {
                favorites.append(currentImage)
                AppDelegate.favoriteImages = favorites
                print("❤️ Добавлено: \(currentImage.id)")
            }
        } else {
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            likeButton.tintColor = .white
            
            var favorites = AppDelegate.favoriteImages
            favorites.removeAll { $0.id == currentImage.id }
            AppDelegate.favoriteImages = favorites
            print("💔 Удалено: \(currentImage.id)")
        }
    }
    
    @objc private func infoTapped() {
        let image = images[currentIndex]
        let alert = UIAlertController(title: "Photo Info", message: "Size: \(image.width)x\(image.height)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func swipeLeft() {
        if currentIndex < images.count - 1 {
            currentIndex += 1
            displayImage()
        }
    }
    
    @objc private func swipeRight() {
        if currentIndex > 0 {
            currentIndex -= 1
            displayImage()
        }
    }
}

extension DetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
}

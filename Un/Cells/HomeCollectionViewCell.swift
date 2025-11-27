//
//  HomeCollectionViewCell.swift
//  Un
//
//  Created by Sabrina Mavlyanova on 21/11/25.
//

import UIKit
import SnapKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let userLabel = UILabel()
    
    var image: UnsplashImage? {
        didSet {
            updateUI()
        }
    }
    
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
        
        let gradientView = UIView()
        gradientView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        contentView.addSubview(gradientView)
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)
        
        userLabel.textColor = .lightGray
        userLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        contentView.addSubview(userLabel)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalTo(userLabel.snp.top).offset(-4)
        }
        
        userLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    private func updateUI() {
        guard let image = image else { return }
        
        if let url = URL(string: image.url) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.imageView.image = uiImage
                    }
                }
            }.resume()
        }
        
        titleLabel.text = image.description ?? "No description"
        userLabel.text = "by \(image.user)"
    }
}

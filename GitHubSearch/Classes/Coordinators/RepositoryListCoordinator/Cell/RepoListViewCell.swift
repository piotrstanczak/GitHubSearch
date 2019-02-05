//
//  RepoListViewCell.swift
//  GitHubSearch
//
//  Created by Piotr Stanczak on 03/02/2019.
//  Copyright © 2019 Piotr Stanczak. All rights reserved.
//

import UIKit
import RxSwift

typealias CellData = (config: RepoListViewCellConfig, viewModel: RepoViewModel)

struct RepoListViewCellConfig {
    let fonts: [UIFont] = [UIFont.boldSystemFont(ofSize: 18.0), UIFont.systemFont(ofSize: 16), UIFont.italicSystemFont(ofSize: 14)]
    let colors: [UIColor] = [.black, .white, UIColor(rgb: 0x53caf8)]
}

final class RepoListViewCell: UITableViewCell {
    
    private var disposeBag = DisposeBag()
    
    var cellData: CellData? {
        didSet {
            guard let cellData = cellData else { return }
            
            setupView(with: cellData.viewModel, and: cellData.config)
        }
    }
    
    private var mainView: UIView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
        self.contentView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    // MARK: Setup view
    
    private func setupView(with viewModel: RepoViewModel, and config: RepoListViewCellConfig) {
        
        selectionStyle = UITableViewCell.SelectionStyle.none
        
        let shadowView = ShadowView()
        self.contentView.addSubview(shadowView)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8.0).isActive = true
        shadowView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8.0).isActive = true
        shadowView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 8).isActive = true
        shadowView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -8).isActive = true
        
        prepareBackground(with: viewModel.identity.uuidString)
        
        let stackView = UIStackView()
        self.contentView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 16.0
        
        stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16.0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16.0).isActive = true
        stackView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 20).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -35).isActive = true
        
        let imageContainer = UIView()
        stackView.addArrangedSubview(imageContainer)
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
        imageContainer.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageContainer.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let imageView = UIImageView()
        imageContainer.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 18).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 18).isActive = true
        imageView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 4).isActive = true
        imageView.image = viewModel.selected.value ? UIImage(named: "fav") : UIImage(named: "notFav")
        imageView.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
        
        viewModel.selected
            .map { value in
                return value ? UIImage(named: "fav") : UIImage(named: "notFav")
            }
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
        
        let texts = [viewModel.name, String(format: "Language: %@", viewModel.language), String(format: "Stars: %@", viewModel.starsCountText)]
        let _ = textContainer(with: texts, fonts: config.fonts, colors: config.colors, in: stackView)
    }
    
    private func prepareBackground(with salt: String) {
        
        let mainView = UIView()
        mainView.backgroundColor = .white
        mainView.layer.cornerRadius = 6
        mainView.layer.masksToBounds = true
        self.contentView.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8.0).isActive = true
        mainView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8.0).isActive = true
        mainView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 8).isActive = true
        mainView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -8).isActive = true
        self.mainView = mainView
        
        let backgroundColor: UIColor = UIColor(rgb: 0x155f7c)
        mainView.backgroundColor = backgroundColor.withAlphaComponent(UIImage.alpha(from: salt))
        self.mainView = mainView
    }
    
    // MARK: Helpers
    
    private func textContainer(with labels: [String], fonts: [UIFont], colors: [UIColor], in stack: UIStackView) -> UIStackView {
        
        let uiLabels = zip(labels, zip(fonts, colors))
            .compactMap { [weak self] data in
                return self?.label(with: data.0, font: data.1.0, color: data.1.1)
            }
        
        let stackView = UIStackView()
        stack.addArrangedSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 8        
        
        uiLabels.forEach { label in
            stackView.addArrangedSubview(label)
        }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }
    
    private func label(with text: String, font: UIFont, color: UIColor) -> UILabel {
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = font
        textLabel.textColor = color
        textLabel.text = text
        textLabel.textAlignment = .left
        
        return textLabel
    }
}

fileprivate final class ShadowView: UIView {
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    private func setupShadow() {
        self.layer.cornerRadius = 3
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 3, height: 3)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}

extension UIImage {
    
    static func alpha(from salt: String) -> CGFloat {
        let minAlpha = 0.6
        let maxAlpha = 0.9
        let fraction: Double = Double(hash64(from: salt)) / Double(Int.max)
        let result = (maxAlpha + (minAlpha - maxAlpha) * fraction)
        return CGFloat(result)
    }
    
    private static func hash64(from salt: String) -> UInt64 {
        var result = UInt64(5381)
        let buffers = [UInt8](salt.utf8)
        for buffer in buffers {
            result = 127 * (result & 0x00ffffffffffffff) + UInt64(buffer)
        }
        return result
    }
}

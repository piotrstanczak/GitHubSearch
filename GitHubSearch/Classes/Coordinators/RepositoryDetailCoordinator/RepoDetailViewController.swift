//
//  RepoDetailViewController.swift
//  GitHubSearch
//
//  Created by Piotr Stanczak on 04/02/2019.
//  Copyright © 2019 Piotr Stanczak. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RepoDetailViewController: UIViewController, ViewModelInjectable, ViewConfigurable {
    
    // MARK: - Properties
    
    var viewModel: RepoViewModel?
    var config: RepoDetailViewConfig?
    
    private let disposeBag = DisposeBag()
    
    private var avararView: UIImageView?
    private var favButton: UIButton?
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewModel = viewModel,
            let config = config else { return }
        
        navigationItem.title = viewModel.name
        
        setupView(with: config, viewModel: viewModel)
        bindView(to: viewModel, with: disposeBag)
        bind(viewModel: viewModel, with: disposeBag)
    }
    
    // MARK: - Bindings
    
    private func bindView(to viewModel: RepoViewModel, with disposeBag: DisposeBag) {
        favButton?.rx.tap
            .withLatestFrom(viewModel.selected)
            .map { !$0 }
            .bind(to: viewModel.selected)
            .disposed(by: disposeBag)
    }
    
    private func bind(viewModel: RepoViewModel, with disposeBag: DisposeBag) {
        guard let favButton = favButton,
            let avararView = avararView else { return }
        
        viewModel.selected
            .bind(to: favButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        viewModel.image
            .bind(to: avararView.rx.image)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Setup views
    
    private func setupView(with config: RepoDetailViewConfig, viewModel: RepoViewModel) {
        view.backgroundColor = config.backgroundColor
        
        setupScroll(with: config, viewModel: viewModel)
        setupNavigation(with: config.navigationBarColor, and: viewModel.identity.uuidString)
    }
    
    private func setupNavigation(with background: UIColor, and salt: String) {
        navigationController?.navigationBar.barTintColor = background.withAlphaComponent(UIImage.alpha(from: salt))
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    private func setupScroll(with config: RepoDetailViewConfig, viewModel: RepoViewModel) {
        
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])

        let stackView = UIStackView()
        scrollView.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 16.0

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            ])

        prepareAvatarView(in: stackView, with: config, viewModel: viewModel)
        prepareTextsView(in: stackView, with: config, with: viewModel)
        
        let bottomView = UIView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        stackView.addArrangedSubview(bottomView)
    }
    
    private func prepareAvatarView(in view: UIStackView, with config: RepoDetailViewConfig, viewModel: RepoViewModel) {

        let mainView = UIView()
        view.addArrangedSubview(mainView)
        mainView.backgroundColor = config.navigationBarColor.withAlphaComponent(UIImage.alpha(from: viewModel.identity.uuidString))
        
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        mainView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        mainView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        mainView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        let stackView = setupStackView(in: mainView, with: UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0))
        
        let avararView = UIImageView()
        stackView.addArrangedSubview(avararView)
        avararView.translatesAutoresizingMaskIntoConstraints = false
        avararView.contentMode = .scaleAspectFit
        self.avararView = avararView
        
        let label = UILabel()
        label.text = viewModel.ownerLogin
        stackView.addArrangedSubview(label)
        
        let favButton = UIButton()
        stackView.addArrangedSubview(favButton)
        favButton.setImage(config.notSelected, for: .normal)
        favButton.setImage(config.selected, for: .selected)
        favButton.translatesAutoresizingMaskIntoConstraints = false
        favButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        favButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        favButton.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        self.favButton = favButton
    }
    
    private func prepareTextsView(in view: UIStackView, with config: RepoDetailViewConfig, with viewModel: RepoViewModel) {
        
        let texts: [(key: String, value: String)] = [(key: config.fullnameKey, value: viewModel.fullName),
                               (key: config.languageKey, value: viewModel.language),
                               (key: config.starsKey, value: viewModel.starsCountText),
                               (key: config.dateKey, value: viewModel.dateCreated)]
        let fonts = config.fonts
        let colors = config.colors
        
        let labels = zip(texts, zip(fonts, colors))
            .compactMap { [weak self] data -> UIStackView? in
                return self?.label(with: data.0.value, key: data.0.key, font: data.1.0, color: data.1.1)
        }
        
        let mainView = UIView()
        view.addArrangedSubview(mainView)
        
        mainView.translatesAutoresizingMaskIntoConstraints = false        
        mainView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        mainView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        
        let stackView = setupStackView(in: mainView, distribution: .fillEqually, alignment: .leading, with: UIEdgeInsets(top: 10, left: 30, bottom: -20, right: -30))
        
        labels.forEach { label in
            stackView.addArrangedSubview(label)
        }
    }
    
    // MARK: - Helpers
    
    private func label(with text: String, key: String, font: UIFont, color: UIColor) -> UIStackView {
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 6
        
        let infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        infoLabel.font = UIFont.italicSystemFont(ofSize: 14)
        infoLabel.textColor = .black
        infoLabel.text = key
        infoLabel.textAlignment = .left
        
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        textLabel.font = font
        textLabel.textColor = color
        textLabel.text = text
        textLabel.textAlignment = .left
        textLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(infoLabel)
        stackView.addArrangedSubview(textLabel)
        
        return stackView
    }
    
    private func setupStackView(in view: UIView, distribution: UIStackView.Distribution = .fill, alignment: UIStackView.Alignment = .center, with margin: UIEdgeInsets = UIEdgeInsets.zero) -> UIStackView {
        let stackView = UIStackView()
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = distribution
        stackView.alignment = alignment
        stackView.spacing = 16.0
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: margin.top),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: margin.left),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: margin.right),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: margin.bottom)
            ])
        
        return stackView
    }
}

//
//  RepoRepoListViewController.swift
//  GitHubSearch
//
//  Created by Piotr Stanczak on 03/02/2019.
//  Copyright © 2019 Piotr Stanczak. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Lottie

typealias Section = AnimatableSectionModel<Int, RepoViewModel>

class RepoListViewController: UIViewController, ViewModelInjectable, ViewConfigurable {
    
    // MARK: - Properties
    
    var viewModel: RepoListViewModel?
    var config: RepoListConfig?
    
    private let disposeBag = DisposeBag()
    private let tableView = UITableView()
    
    fileprivate var loadingView: LOTAnimationView? = nil
    fileprivate var emptyView: LOTAnimationView? = nil

    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search for repository"
        searchController.searchBar.autocapitalizationType = .none
        searchController.dimsBackgroundDuringPresentation = false
        return searchController
    }()
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewModel = viewModel,
            let config = config else { return }
        
        setupView(with: config)
        bindView(to: viewModel, with: disposeBag)
        bind(viewModel: viewModel, config: config, with: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.barTintColor = UIColor(rgb: 0xecb31c)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    // MARK: - Bindings
    
    private func bindView(to viewModel: RepoListViewModel, with disposeBag: DisposeBag) {
        let searchDismissed = searchController.rx.didDismiss
            .map { _ in "" }
        
        searchDismissed
            .bind(to: searchController.searchBar.rx.text)
            .disposed(by: disposeBag)
        
        searchDismissed
            .bind(to: viewModel.query)
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.text.orEmpty
            .skip(1)
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: viewModel.query)
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(RepoViewModel.self)
            .bind(to: viewModel.selected)
            .disposed(by: disposeBag)
    }
    
    private func bind(viewModel: RepoListViewModel, config: RepoListConfig, with disposeBag: DisposeBag) {
        let animationConfiguration = AnimationConfiguration(insertAnimation: .bottom, reloadAnimation: .none, deleteAnimation: .fade)
        let dataSource = RxTableViewSectionedAnimatedDataSource<Section>(animationConfiguration: animationConfiguration,
            configureCell: { _, tableView, indexPath, repository in
                
                let cell = tableView.dequeueReusableCell(withIdentifier: config.cellIdentifier, for: indexPath)
                if let repoCell = cell as? RepoListViewCell {
                    repoCell.cellData = CellData(viewModel: repository, config: RepoListViewCellConfig())
                }
                return cell
        })
        
        viewModel.data
            .map { [Section(model: 0, items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.error
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] errorMessage in
                self?.showError(with: errorMessage)
            })
            .disposed(by: disposeBag)
        
        
        
        viewModel.data.asDriver()
            .map { String(format: config.titleWithCount, $0.count) }
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.isEmpty
            .startWith(true)
            .bind(to: rx.isEmpty)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        tableView.rx.reachedBottom
            .debounce(0.5, scheduler: MainScheduler.instance) 
            .bind(to: viewModel.reachedBottom)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Setup views
    
    private func setupView(with config: RepoListConfig) {
        view.backgroundColor = .white
        
        setupNavigation(with: config)
        setupTableView(with: config)
        setupAnimations(with: config.loadingAnimation, emptyName: config.emptyAnimation)
    }
    
    private func setupNavigation(with config: RepoListConfig) {
        navigationItem.searchController = searchController
        navigationItem.title = config.title
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
        definesPresentationContext = true
    }
    private func setupTableView(with config: RepoListConfig) {
        tableView.backgroundColor = UIColor(rgb: 0xe8e8e8)
        tableView.register(RepoListViewCell.self, forCellReuseIdentifier: config.cellIdentifier)
        tableView.keyboardDismissMode = .interactive
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        tableView.contentInset.bottom = view.safeAreaInsets.bottom
    }
    
    private func setupAnimations(with loadingName: String, emptyName: String) {
        
        let loadingView = prepareAnimationView(with: loadingName) as? LOTAnimationView
        self.loadingView = loadingView
        
        let emptyView = prepareAnimationView(with: emptyName) as? LOTAnimationView
        self.emptyView = emptyView
    }
    
    private func prepareAnimationView(with name: String, loopAnimation: Bool = true) -> UIView {
        let lottieView = LOTAnimationView(name: name)
        view.addSubview(lottieView)
        lottieView.isHidden = true
        
        lottieView.loopAnimation = loopAnimation
        lottieView.contentMode = .scaleAspectFill
        
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        lottieView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        lottieView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true
        
        return lottieView
    }
    
    // MARK: - Helpers
    
    private func showError(with message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

fileprivate extension Reactive where Base: RepoListViewController {
    var loading: Binder<Bool> {
        return Binder(self.base) { viewController, loading in
            if loading {
                viewController.loadingView?.play()
            } else {
                viewController.loadingView?.stop()
            }
            
            viewController.loadingView?.isHidden = !loading
        }
    }
    
    var isEmpty: Binder<Bool> {
        return Binder(self.base) { viewController, isEmpty in
            
            if isEmpty {
                viewController.emptyView?.play()
            } else {
                viewController.emptyView?.stop()
            }
            
            viewController.emptyView?.isHidden = !isEmpty
        }
    }
}

//
//  AppCoordinator.swift
//  GitHubSearch
//
//  Created by Piotr Stanczak on 03/02/2019.
//  Copyright © 2019 Piotr Stanczak. All rights reserved.
//

import RxSwift

class AppCoordinator: Coordinator<UIWindow, CoordinatorFactory, Empty> {
    
    private let disposeBag = DisposeBag()
    
    override func start() -> Observable<Empty> {
        let splashCoordinator = factory.coordinator(for: SplashCoordinator.self, with: navigator)
        
        navigate(to: splashCoordinator)
            .subscribe(onNext: { [weak self] _ in                
                self?.showRepoListViewController()
            })
            .disposed(by: disposeBag)
        
        return .never()
    }
    
    private func showRepoListViewController() {
        let listViewCoordinator = factory.coordinator(for: RepoListCoordinator.self, with: navigator)
        
        navigate(to: listViewCoordinator)
            .subscribe()
            .disposed(by: disposeBag)        
    }
}

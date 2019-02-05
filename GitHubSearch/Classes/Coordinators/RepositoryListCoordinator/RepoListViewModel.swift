//
//  RepoRepoListViewModel.swift
//  GitHubSearch
//
//  Created by Piotr Stanczak on 03/02/2019.
//  Copyright © 2019 Piotr Stanczak. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

enum RepoListState {
    case idle
    case loading
    case completed
}

typealias Query = (phrase: String, result: [RepoViewModel])

class RepoListViewModel {
    
    private let networking: NetworkManager
    private let storage: StorageManager
    
    private let state = BehaviorRelay<RepoListState>(value: .idle)
    private let disposeBag = DisposeBag()
        
    let query = PublishSubject<String>()
    let selected = PublishSubject<RepoViewModel>()
    let page = BehaviorRelay<Int>(value: 0)
    let data = BehaviorRelay<[RepoViewModel]>(value: [])
    let dataCount = BehaviorRelay<Int>(value: 0)
    let reachedBottom = PublishSubject<Void>()
    let isLoading = PublishSubject<Bool>()
    let isEmpty = PublishSubject<Bool>()
    let error = PublishSubject<String>()
    
    init(networking: NetworkManager, storage: StorageManager) {
        self.networking = networking
        self.storage = storage
        
        state
            .map { $0 == .loading }
            .bind(to: isLoading)
            .disposed(by: disposeBag)
        
        data
            .map { $0.count == 0 }
            .bind(to: isEmpty)
            .disposed(by: disposeBag)
        
        // When user reach end of the page
        // We try to load next page
        reachedBottom
            .withLatestFrom(state)
            .filter { $0 == .idle }
            .withLatestFrom(page)
            .map { $0 + 1 }
            .bind(to: page)
            .disposed(by: disposeBag)
        
        // Reseting page after query change
        query
            .map { _ in 0 }
            .bind(to: page)
            .disposed(by: disposeBag)
        
        // Reseting state after query change
        query
            .map { _ in RepoListState.idle }
            .bind(to: state)
            .disposed(by: disposeBag)
        
        // Observing for changes in cells view models
        // If user tapped on the 'fav' button
        // Then we add or remove it from storage
        data
            .flatMap { repositories -> Observable<StorableType> in

                let elements = repositories.map { repository -> Observable<StorableType> in
                    return repository.selected
                        .skip(1)
                        .map { selected in
                            return (id: repository.id, selected: selected)
                        }
                }
                return Observable.merge(elements)
            }
            .bind(to: self.storage.rx.selected)
            .disposed(by: disposeBag)
        
        // Observing for query and page changes
        // Creating request and mapping results
        Observable.combineLatest(query, page)
            .do(onNext: { [weak self] _ in
                self?.state.accept(.loading)
            })
            .flatMapLatest { query, page -> Observable<Query> in
                guard !query.isEmpty else { return .of(("",[])) }
                
                let repo: Observable<Repositories?> = networking.search(with: query, page: page)
                return repo
                    .do(onError: { [weak self] error in
                        self?.error.onNext(error.localizedDescription)
                    })
                    .catchErrorJustReturn(nil)
                    .map { repositories in
                        return (query: query, results: repositories?.items?.compactMap(RepoViewModel.init) ?? [])
                    }
            }            
            .scan(Query(phrase: "", result: [RepoViewModel]()), accumulator: { (oldQuery, newQuery) -> Query in
                // If phrase has changed, we have to collect new results
                // Otherwise we append new results to old one
                if oldQuery.phrase != newQuery.phrase {
                    return newQuery
                } else {
                    var nextQuery = oldQuery
                    nextQuery.result.append(contentsOf: newQuery.result)
                    return nextQuery
                }
            })
            .catchError({ error -> Observable<Query> in
                return .of(Query("", []))
            })
            .map { $0.result }
            .map { [weak self] repositories in
                
                repositories.forEach { repo in
                    let isAdded = self?.storage.isAdded(repo.id) != nil
                    repo.selected.accept(isAdded)
                }
                
                return repositories
            }
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .bind(to: data)
            .disposed(by: disposeBag)
        
        data
            .delay(1.0, scheduler: MainScheduler.instance)
            .map { _ in RepoListState.idle }
            .bind(to: state)
            .disposed(by: disposeBag)
        
        data
            .map { $0.count }
            .bind(to: dataCount)
            .disposed(by: disposeBag)
    }
}


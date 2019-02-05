//
//  Coordinator.swift
//  GitHubSearch
//
//  Created by Piotr Stanczak on 02/02/2019.
//  Copyright © 2019 Piotr Stanczak. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

typealias Empty = Void

class Coordinator<NavigatorType, FactoryType, ResultType> {
    
    typealias Navigator = NavigatorType
    typealias Factory = FactoryType
    typealias Completion = ResultType
    
    let navigator: Navigator
    let factory: Factory
    let identifier = UUID()
    var children = [UUID: Any]()
    
    init(navigator: Navigator, factory: Factory) {
        self.navigator = navigator
        self.factory = factory
    }
    
    private func store<N, F, R>(coordinator: Coordinator<N, F, R>) {
        children[coordinator.identifier] = coordinator
    }
    
    private func free<N, F, R>(coordinator: Coordinator<N, F, R>) {
        children[coordinator.identifier] = nil
    }
    
    func navigate<N, F, R>(to coordinator: Coordinator<N, F, R>) -> Observable<R> {
        store(coordinator: coordinator)

        return coordinator.start()
            .do(onNext: { [weak self] _ in self?.free(coordinator: coordinator) })
    }
    
    func start() -> Observable<Completion> {
        fatalError("This should be implemented!")
    }
}





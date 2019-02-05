//
//  Storable.swift
//  GitHubSearch
//
//  Created by Piotr Stanczak on 04/02/2019.
//  Copyright © 2019 Piotr Stanczak. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

typealias StorableType = (id: Int, selected: Bool)

protocol Storable {
    associatedtype StorableType
    
    var favourite: [StorableType] { get set }
    
    func add(_ element: StorableType)
    func remove(_ element: StorableType)
    func isAdded(_ element: StorableType) -> Int?
}

class StorageManager: Storable, ReactiveCompatible {
    
    private static let storageKey = "Favourites"
    private let userDefaults: UserDefaults
    
    var favourite: [Int]
    
    init(with userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        self.favourite = userDefaults.object(forKey: StorageManager.storageKey) as? [Int] ?? []
    }
    
    func add(_ element: Int) {
        guard isAdded(element) == nil else { return }
        
        self.favourite.append(element)
        self.userDefaults.set(self.favourite, forKey: StorageManager.storageKey)
    }
    
    func remove(_ element: Int) {
        if let index = isAdded(element) {
            self.favourite.remove(at: index)
            self.userDefaults.set(self.favourite, forKey: StorageManager.storageKey)
        }
    }
    
    func isAdded(_ element: Int) -> Int? {
        return favourite.index(of: element)
    }
}

extension Reactive where Base: StorageManager {
    var selected: Binder<StorableType> {
        return Binder(self.base) { storage, element  in
            if element.selected {
                storage.add(element.id)
            } else {
                storage.remove(element.id)
            }            
        }
    }
}

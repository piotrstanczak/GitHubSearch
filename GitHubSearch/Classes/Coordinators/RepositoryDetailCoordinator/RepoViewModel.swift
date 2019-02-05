//
//  RepoViewModel.swift
//  GitHubSearch
//
//  Created by Piotr Stanczak on 04/02/2019.
//  Copyright © 2019 Piotr Stanczak. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

class RepoViewModel: IdentifiableType, Equatable {
    
    private(set) var identity = UUID()
    
    let selected = BehaviorRelay<Bool>(value: false)
    var network: NetworkManager?
    
    let id: Int
    let name: String
    let fullName: String
    let description: String
    let starsCountText: String
    let avatarUrl: URL
    let language: String
    let ownerLogin: String
    private let createdAt: Date
    
    var dateCreated: String {
        return RepoViewModel.dateFormatter().string(from: createdAt)
    }
    
    var image: Observable<UIImage?> {
        guard let network = network else { return .empty() }
        return network.loadImageWithUrl(avatarUrl)
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    init?(repository: Repository) {
        
        guard let id = repository.id,
            let name = repository.name,
            let fullName = repository.fullName,
            let description = repository.description,
            let starsCount = repository.starsCount,
            let urlString = repository.owner?.avatarURL,
            let url =  URL(string: urlString),
            let language = repository.language,
            let ownerLogin = repository.owner?.login,
            let dateString = repository.createdAt,
            let createdAt = RepoViewModel.apiDateFormatter().date(from: dateString) else {
                return nil
        }
        
        self.id = id
        self.name = name
        self.fullName = fullName
        self.description = description
        self.starsCountText = "\(starsCount)"
        self.avatarUrl = url
        self.language = "\(language)"
        self.ownerLogin = ownerLogin
        self.createdAt = createdAt
    }
    
    static func == (lhs: RepoViewModel, rhs: RepoViewModel) -> Bool {
        return lhs.identity == rhs.identity
    }
    
    static func apiDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter
    }
    
    static func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter
    }
}

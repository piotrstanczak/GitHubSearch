//
//  Repositories.swift
//  GitHubSearch
//
//  Created by Piotr Stanczak on 04/02/2019.
//  Copyright © 2019 Piotr Stanczak. All rights reserved.
//

import Foundation

struct Repositories: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [Repository]?
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

struct Repository: Codable {
    let id: Int?
    let name: String?
    let fullName: String?
    let description: String?
    let starsCount: Int?
    let url: String?
    let language: String?
    let owner: Owner?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case description
        case starsCount = "stargazers_count"
        case url
        case language
        case owner
        case createdAt = "created_at"
    }
}

struct Owner: Codable {
    let login: String
    let avatarURL: String
    
    enum CodingKeys: String, CodingKey {
        case login
        case avatarURL = "avatar_url"
    }
}

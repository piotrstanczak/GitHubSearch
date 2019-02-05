//
//  RepoDetailViewConfig.swift
//  GitHubSearch
//
//  Created by Piotr Stanczak on 04/02/2019.
//  Copyright © 2019 Piotr Stanczak. All rights reserved.
//

import UIKit

struct RepoDetailViewConfig {
    let fonts: [UIFont] = [UIFont.boldSystemFont(ofSize: 26.0), UIFont.systemFont(ofSize: 20), UIFont.italicSystemFont(ofSize: 20), UIFont.systemFont(ofSize: 20), UIFont.systemFont(ofSize: 22)]
    let colors: [UIColor] = [.black, .darkGray, UIColor(rgb: 0x53caf8), .darkGray, .darkGray]
    
    let navigationBarColor = UIColor(rgb: 0x155f7c)
    let backgroundColor = UIColor(rgb: 0xe8e8e8)
    
    let notSelected = UIImage(named: "notFav")!
    let selected = UIImage(named: "fav")!
    
    let fullnameKey = "Fullname:"
    let languageKey = "Language:"
    let starsKey = "Stars:"
    let dateKey = "Date created:"
}

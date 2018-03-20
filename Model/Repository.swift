//
//  Repository.swift
//  Githubsearch
//
//  Created by David Vallas on 3/19/18.
//  Copyright © 2018 David Vallas. All rights reserved.
//

import Foundation

struct Repository {
    
    let name: String
    let desc: String
    let login: String
    let language: String
    let stars: Int
    let forks: Int
    let updated: Date
    
    static func parseJSON(json: [Dictionary<String, AnyObject>]) -> [Repository] {
        
        var repositories: [Repository] = []
    
        for dict in json {
            let name = dict["name"].string
            let desc = dict["description"].stringDescription
            let owner = dict["owner"].dict
            let login = owner["login"].string
            let stars = dict["stargazers_count"].int
            let forks = dict["forks"].int
            let updated = dict["updated_at"].date
            let language = dict["language"].stringLanguage
            let repo = Repository(name: name, desc: desc, login: login, language: language, stars: stars, forks: forks, updated: updated)
            repositories.append(repo)
        }
        
        return repositories
    }
    
}

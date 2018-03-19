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
    let login: String
    let languages: [Language]
    let stars: Int
    let forks: Int
    let updated: Date
    
    static func parseJSON(json: [Dictionary<String, AnyObject>]) -> [Repository] {
        
        var repositories: [Repository] = []
    
        for dict in json {
        }
        
        return repositories
    }
    
}

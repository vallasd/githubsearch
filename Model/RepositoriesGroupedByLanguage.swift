//
//  RepositoriesOfALanguage.swift
//  Githubsearch
//
//  Created by David Vallas on 3/19/18.
//  Copyright © 2018 David Vallas. All rights reserved.
//

import Foundation

struct RepositoriesGroupedByLanguage {
    
    let languageName: String
    let repositories: [Repository]
    
    static func sortRepositories(repos: [Repository]) -> [RepositoriesGroupedByLanguage] {
        
        struct tempRGBL {
            let languageName: String
            var repositories: [Repository]
        }
        
        // create Repositories Grouped By Language
        var currentLanguages: [String] = []
        var RGBLArray: [tempRGBL] = []
        
        for repo in repos {
            
            let language = repo.language
            
            // if this is the first time we are seeing the language, append a new RGBL with the new language
            if !currentLanguages.contains(language) {
                currentLanguages.append(language)
                let newRepo = tempRGBL(languageName: language, repositories: [])
                RGBLArray.append(newRepo)
            }
            
            // find the index of the RepositoriesGroupedByLanguage and add the repo to that RGBL
            if let i = RGBLArray.index(where: { $0.languageName == language }) {
                RGBLArray[i].repositories.append(repo)
            }
        }
        
        // sort repositories in each RGBL by the number of stars
        var index = 0
        for rgbl in RGBLArray {
            let sortedRepos = rgbl.repositories.sorted(by: { $0.stars > $1.stars })
            RGBLArray[index].repositories = sortedRepos
            index += 1
        }
        
        // sort RGBLArray by language with the most repos first
        let sortedRGBLArray = RGBLArray.sorted(by: { $0.repositories.count > $1.repositories.count })
        
        // copy tempRGBL to actual RGBL (prefer models to be static as needed, used a tempRGBL because I was appending when creating and needed to use var)
        var realRGBLArray: [RepositoriesGroupedByLanguage] = []
        for r in sortedRGBLArray {
            realRGBLArray.append(RepositoriesGroupedByLanguage(languageName: r.languageName, repositories: r.repositories))
        }
        
        return realRGBLArray
    }
}

extension Sequence where Iterator.Element == RepositoriesGroupedByLanguage {
    
    var repositoryCount: Int {
        
        var count = 0
        
        for rgbl in self {
            count += rgbl.repositories.count
        }
        
        return count
    }
}

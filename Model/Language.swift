//
//  Language.swift
//  Githubsearch
//
//  Created by David Vallas on 3/19/18.
//  Copyright © 2018 David Vallas. All rights reserved.
//

import Foundation

struct Language {
    
    let name: String
    
    static func parseJSON(json: Dictionary<String, AnyObject>) -> [Language] {
        
        var languages: [Language] = []
        
        for key in json.keys {
            let language = Language(name: key)
            languages.append(language)
        }
        
        return languages
    }
}

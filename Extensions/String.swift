//
//  String.swift
//  Githubsearch
//
//  Created by David Vallas on 3/21/18.
//  Copyright © 2018 David Vallas. All rights reserved.
//

import Foundation

extension String {
    
    var githubLastPage: Int? {
        let links = self.components(separatedBy: ",")
        for link in links {
            let parts = link.components(separatedBy: ";")
            if let rel = parts.last {
                if rel == " rel=\"last\"" {
                    if let http = parts.first {
                        let httpClean = http.dropLast()
                        if let pages = httpClean.components(separatedBy: "page=").last {
                            if let num = Int(pages) {
                                return num
                            }
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
}

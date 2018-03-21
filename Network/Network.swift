//
//  Network.swift
//  Githubsearch
//
//  Created by David Vallas on 3/19/18.
//  Copyright © 2018 David Vallas. All rights reserved.
//

import Foundation

class Network: NSObject {
    
    let baseurl = "https://api.github.com/"
    
    // Private vars used to keep tracking of paging for repository queries
    private var repositorySearchString = ""
    private var currentOrgPage = 1
    private var currentUserPage = 1
    private var maxOrgPages = 9999
    private var maxUserPages = 9999
    
    static let shared = Network()
    
    /// This function parses the repository data returned from github, it either returns array of Repository structs and error message if applicable
    fileprivate func parseRepositories(data: Data?, response: URLResponse?, error: Error?) -> (result: [Repository], error: Error?) {
        
        let genericError = NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "unable to request repositories"])
        
        if error == nil {
            if let d = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: d, options: [.allowFragments]) as? [Dictionary<String, AnyObject>] ?? []
                    if json.count == 0 {
                        if let checkMessage = try JSONSerialization.jsonObject(with: d, options: [.allowFragments]) as? Dictionary<String, AnyObject> {
                            if let m = checkMessage["message"] {
                                if let mString = m as? String {
                                    if mString == "Not Found" {
                                        return ([], nil)
                                    }
                                }
                                let messageError = NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "\(m)"])
                                return ([], messageError)
                            }
                        }
                        return ([], nil)
                    }
                    let repositories = Repository.parseJSON(json: json)
                    return (repositories, nil)
                } catch  {
                    return ([], genericError)
                }
            }
        }
        
        let err = error == nil ? genericError : error
        
        return ([], err)
        
    }
    
    /// This function creates a github request and session from a url string
    fileprivate func createSession(urlString: String) -> (url: URL?, session: URLSession?, error: Error?) {
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "unable to create url in getRepositories"])
            print("Error: unable to create url \(urlString) in getRepositories")
            return (nil, nil, error)
        }
        
        let request = NSMutableURLRequest(url: url)
        request.addValue("iphone", forHTTPHeaderField: "user-agent")
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        return (url, session, nil)
    }
    
    /// Resets the getRepositories function so that it will start returning data from page 1
    func resetGetRepositories() {
        repositorySearchString = ""
        currentOrgPage = 1
        currentUserPage = 1
        maxOrgPages = 9999
        maxUserPages = 9999
    }
    
    /// This function gets github repositories for a user or organization.  It handles paging internally, if you dont receive an empty array of Repositories, there may be additional pages to request.  Call this function again and it will return additional repositories.  You can stop requesting once the function returns an empty Repository array or an error message.  If you use a new search string, the function will reset and start searching at page 1.  If you want to reset the paging for the same string, run the resetGetRepositories() function before calling this function.
    func getRepositories(withSearch s: String, completion: @escaping (_ result: [Repository], _ error: Error?) -> Void) {
        
        if s != repositorySearchString {
            resetGetRepositories()
            repositorySearchString = s
        }
        
        let cu = currentUserPage
        let mu = maxUserPages
        let co = currentOrgPage
        let mo = maxOrgPages
        
        if cu >= mu && co >= mo {
            completion([], nil)
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            [weak self] in
            
            var totalRepositories: [Repository] = []
            
            // Get user repositories if we haven't reached the end of the paging
            if cu <= mu {
                if let response = self?.getRepositories(withUser: s, page: cu) {
                    
                    if response.error != nil {
                        completion([], response.error)
                        return
                    }
                    
                    totalRepositories = totalRepositories + response.result
                }
            }
            
            // Get org repositories if we haven't reached the end of the paging
            if co <= mo {
                if let response = self?.getRepositories(withOrg: s, page: cu) {
                    
                    if response.error != nil {
                        completion([], response.error)
                        return
                    }
                    
                    totalRepositories = totalRepositories + response.result
                }
            }
            
            completion(totalRepositories, nil)
        }
        
        currentUserPage += 1
        currentOrgPage += 1
    }
    
    // synchronous call to get Repositories for a specific org
    fileprivate func getRepositories(withOrg o: String, page: Int) -> (result: [Repository], error: Error?) {
        
        let urlString = baseurl + "orgs/\(o)/repos?per_page=100&page=\(page)"
        let response = createSession(urlString: urlString)
        guard let session = response.session, let url = response.url else {
            maxUserPages = currentOrgPage
            return ([], response.error)
        }
        
        let results = session.synchronousDataTask(with: url)
        let parsed = parseRepositories(data: results.0, response: results.1, error: results.2)
        
        if parsed.result.count < 100 || parsed.error != nil {
            maxUserPages = currentOrgPage
        }
        
        return parsed
    }
    
    // synchronous call to get Repositories for a specific user
    fileprivate func getRepositories(withUser u: String, page: Int) -> (result: [Repository], error: Error?) {
        
        let urlString = baseurl + "users/\(u)/repos?per_page=100&page=\(page)"
        let response = createSession(urlString: urlString)
        guard let session = response.session, let url = response.url else {
            maxUserPages = currentOrgPage
            return ([], response.error)
        }
        
        let results = session.synchronousDataTask(with: url)
        let parsed = parseRepositories(data: results.0, response: results.1, error: results.2)
        
        if parsed.result.count < 100 || parsed.error != nil {
            maxUserPages = currentOrgPage
        }
        
        return parsed
    }
}



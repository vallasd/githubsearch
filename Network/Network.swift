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
    
    fileprivate enum RequestType {
        case orgRepository
        case userRepository
    }
    
    fileprivate struct PageData {
        let searchString: String
        var userPage: Int
        var maxUserPages: Int
        var pagesDownloaded: Int // updated right before completion handler is called
        var workItems: [DispatchWorkItem]
    }
    
    fileprivate var pageData: PageData = PageData(searchString: "", userPage: 1, maxUserPages: 1, pagesDownloaded: 0, workItems: [])
    fileprivate var repositoriesPerPage = 100
    
    static let shared = Network()
    
    fileprivate func getLastPage(fromResponse: URLResponse?) -> Int? {
        
        if let response = fromResponse as? HTTPURLResponse {
            if let links = response.allHeaderFields["Link"] as? String {
                if let lastPage = links.githubLastPage {
                    return lastPage
                }
            }
        }
        
        return nil
    }
    
    /// This function parses the repository data returned from github, it either returns array of Repository structs and error message if applicable
    fileprivate func parseRepositories(data: Data?, response: URLResponse?, error: Error?, firstPage: Bool) -> (result: [Repository], error: Error?) {
        
        let genericError = NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "unable to request repositories"])
        
        if firstPage, let lastPage = getLastPage(fromResponse: response) {
            pageData.maxUserPages = lastPage
        }
        
        if error == nil {
            if let d = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: d, options: [.allowFragments]) as? [Dictionary<String, AnyObject>] ?? []
                    if json.count == 0 {
                        let noRepositoryError = NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "No repositories found for search string."])
                        if let checkMessage = try JSONSerialization.jsonObject(with: d, options: [.allowFragments]) as? Dictionary<String, AnyObject> {
                            if let m = checkMessage["message"] {
                                if let mString = m as? String {
                                    if mString == "Not Found" {
                                        return ([], noRepositoryError)
                                    }
                                }
                                let messageError = NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "\(m)"])
                                return ([], messageError)
                            }
                        }
                        return ([], noRepositoryError)
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
    
    /// Resets the paging information for getRepositories so that it will start returning data from page 1 and removes all outstanding work items in the queue.  You should call this and set the string to empty once you are done consuming all your data for a specific search request. (or else you will not be able to refresh the same search 
    func resetPageData(withString: String) {
        
        // remove all current work items from queue
        for workItem in pageData.workItems {
            workItem.cancel()
        }
        
        pageData = PageData(searchString: withString, userPage: 1, maxUserPages: 1, pagesDownloaded: 0, workItems: [])
    }
    
    /// This gives an estimate of the number of repositories left to download.  This estimate is established once the first getRepositories function is run for a specific search string
    func repositoriesLeftToDownload() -> Int {
        let numUserPagesLeft = pageData.maxUserPages - pageData.pagesDownloaded
        return numUserPagesLeft * repositoriesPerPage
    }
    
    /// This function gets github repositories for a user / owner.  The first time this function is called with the same string, it will return the first page of the request (up to 100 repositories).  The second time it is called with the same search string, it will return the respositories for all of the remaining pages.  Use repositoriesLeftToDownload() to get an approximation of how many that will be.  After you have processed the downloaded repositories, call resetPageData(withString: "")
    func getRepositories(withSearch s: String, completion: @escaping (_ result: [Repository], _ error: Error?) -> Void) {
        
        let cQueue = DispatchQueue(label: "com.queue.getRepositories.concurrent", attributes: .concurrent)
        
        if s != pageData.searchString {
            resetPageData(withString: s)
        }
        
        while pageData.userPage <= pageData.maxUserPages {
            
            let pd = pageData // make copy
            
            let workItem = DispatchWorkItem {
                [weak self] in
                if let response = self?.getRepositories(withUser: pd.searchString, page: pd.userPage) {
                    self?.pageData.pagesDownloaded += 1
                    if let currentSearchString = self?.pageData.searchString {
                        // we don't run completion handler if this was a result from an old work item from previous search
                        if currentSearchString == pd.searchString {
                            DispatchQueue.main.async {
                                completion(response.result, response.error)
                            }
                        }
                    }
                }
            }
            
            pageData.workItems.append(workItem)
            cQueue.async(execute: workItem)
            
            pageData.userPage += 1
        }
    }
    
    // synchronous call to get Repositories for a specific user
    fileprivate func getRepositories(withUser u: String, page: Int) -> (result: [Repository], error: Error?) {
        
        let urlString = baseurl + "users/\(u)/repos?per_page=\(repositoriesPerPage)&type=owner&page=\(page)"
        let response = createSession(urlString: urlString)
        guard let session = response.session, let url = response.url else {
            return ([], response.error)
        }
        
        let results = session.synchronousDataTask(with: url)
        let firstPage = page == 1 ? true : false
        let parsed = parseRepositories(data: results.0, response: results.1, error: results.2, firstPage: firstPage)
        
        if parsed.error != nil {
            return ([], parsed.error)
        }
        
        return parsed
    }
}



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
    
    static let shared = Network()
    
    func getRepositories(withUser u: String, completion: @escaping (_ result: [Repository], _ error: Error?) -> Void) {
        
        let genericError = NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "unable to request repositories"])
        
        let urlString = baseurl + "users/\(u)/repos"
        guard let url = URL(string: urlString) else {
            print("Error: unable to create url \(urlString) in getRepositories")
            DispatchQueue.main.async {
                completion([], genericError)
            }
            return
        }
        
        let request = NSMutableURLRequest(url: url)
        request.addValue("iphone", forHTTPHeaderField: "user-agent")
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if error == nil {
                if let d = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: d, options: [.allowFragments]) as? [Dictionary<String, AnyObject>] ?? [[:]]
                        let repositories = Repository.parseJSON(json: json)
                        DispatchQueue.main.async {
                            completion(repositories, nil)
                        }
                        return
                    } catch  {
                        DispatchQueue.main.async {
                            completion([], genericError)
                        }
                        return
                    }
                }
            }
            
            let err = error == nil ? genericError : error
            
            DispatchQueue.main.async {
                completion([], err)
            }
            
            }.resume()
    }
}

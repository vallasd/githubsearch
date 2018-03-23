//
//  SearchTVC.swift
//  Githubsearch
//
//  Created by David Vallas on 3/19/18.
//  Copyright © 2018 David Vallas. All rights reserved.
//

import UIKit

class SearchTVC: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    fileprivate var spinner: UIActivityIndicatorView!
    
    fileprivate var model: [RepositoriesGroupedByLanguage] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    /// currentSearchTerm used to make sure that the user does not enter the same term twice
    fileprivate var currentSearchTerm = "!@#$!asdf2kl%12adsf%%11"
    
    
    fileprivate func resetSearch() {
        stopSpinner()
        Network.shared.resetPageData(withString: "")
        currentSearchTerm = "!@#$!asdf2kl%12adsf%%11"
    }
    
    /// update this var to change the data being displayed in the view controller
    var repositories: [Repository] = [] {
        didSet {
            model = RepositoriesGroupedByLanguage.sortRepositories(repos: repositories)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    fileprivate func addSpinner() {
        
        if spinner == nil {
            spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            spinner.frame = CGRect(x: 0, y: 0, width: 80.0, height: 80.0)
            spinner.center = CGPoint(x: view.bounds.width / 2.0, y: view.bounds.height / 2.0)
            spinner.activityIndicatorViewStyle = .whiteLarge
            spinner.color = .gray
            view.addSubview(spinner)
        }
        
        spinner.isHidden = false
        spinner.startAnimating()
    }
    
    fileprivate func stopSpinner() {
        spinner.stopAnimating()
        spinner.isHidden = true
    }
    
    fileprivate func update(cell: UITableViewCell?, atRow: Int) {
        if let c = cell as? LanguageCell {
            let rgbl = model[atRow]
            c.name.text = rgbl.languageName
            c.count.text = String(rgbl.repositories.count)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination
        
        if let rvc = vc as? RepositoryTVC {
            if let row = tableView.indexPathsForSelectedRows?.first?.row {
                let rgbl = model[row]
                rvc.title = rgbl.languageName
                rvc.model = rgbl.repositories
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell")
        update(cell: cell, atRow: indexPath.row)
        return cell ?? UITableViewCell()
    }
}

extension SearchTVC: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
        searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            if text != "" && text != currentSearchTerm {
                addSpinner()
                currentSearchTerm = text
                repositories = []
                title = text
                updateRepos(withString: currentSearchTerm, firstTry: true)
            }
        }
    }
    
    fileprivate func updateRepos(withString s: String, firstTry: Bool) {
        
        Network.shared.getRepositories(withSearch: s, completion: { [weak self] (repositories, error) in
            
            // we received an error
            if let e = error {
                
                self?.resetSearch()
                let alert = UIAlertController(title: "Error", message: e.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                
            // we received no repositories
            } else if repositories.count == 0 {
                
                self?.resetSearch()
                
                if firstTry {
                    let alert = UIAlertController(title: "Error", message: "No repositories found for search string: \(s)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
                
            // we received some repositories
            } else {
                
                // update repositories variable in view controller (will update the model) and change title to reflect current repository count
                self?.repositories += repositories
                if let count = self?.repositories.count {
                    self?.title = "\(s) (\(count))"
                }
                
                let repositoriesLeft = Network.shared.repositoriesLeftToDownload()
                
                // we don't have anymore repositories to download, remove spinner, we are done
                if repositoriesLeft == 0 {
                    self?.resetSearch()
                }
                
                // this is the first time we kicked off a new search and there are still more repositories for the user to download.  We give them the option to download the rest.
                if repositoriesLeft > 0 && firstTry {
                    self?.userAlertToRequestMoreRepositoryDownloads(left: repositoriesLeft, searchString: s)
                }
            }
        })
    }
    
    /// action sheet that will ask user if he wants to download remaining repositories
    fileprivate func userAlertToRequestMoreRepositoryDownloads(left: Int, searchString s: String) {
        let alert = UIAlertController(title: "There are more repositories to download.", message: "There are up to \(left) repositories left to download.  Do you want to download them?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] action in
            self?.updateRepos(withString: s, firstTry: false)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { [weak self] action in
            self?.resetSearch()
        }))
        present(alert, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.showsCancelButton = false
    }
}


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
    
    var model: [RepositoriesGroupedByLanguage] = [] {
        didSet {
            tableView.reloadData()
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
            if text != "" {
                
                addSpinner()
                Network.shared.resetGetRepositories()
                
                Network.shared.getRepositories(withSearch: text, completion: { [weak self] (repositories, error) in
                    
                    DispatchQueue.main.async {
                        self?.stopSpinner()
                    }
                    
                    if let e = error {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Error", message: e.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self?.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        let rgblArray = RepositoriesGroupedByLanguage.sortRepositories(repos: repositories)
                        DispatchQueue.main.async {
                            self?.title = text
                            self?.model = rgblArray
                        }
                    }
                    
                })
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.showsCancelButton = false
    }
}

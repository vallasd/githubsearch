//
//  RepositoryTVC.swift
//  Githubsearch
//
//  Created by David Vallas on 3/19/18.
//  Copyright © 2018 David Vallas. All rights reserved.
//

import UIKit

class RepositoryTVC: UITableViewController {
    
    var model: [Repository] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
    
    fileprivate func update(cell: UITableViewCell?, atRow: Int) {
        if let c = cell as? RepositoryCell {
            let repo = model[atRow]
            c.name.text = repo.name
            c.desc.text = repo.desc
            c.stars.text = "Stars: \(repo.stars)"
            c.forks.text = "Forks: \(repo.forks)"
            c.updated.text = "Updated: \(repo.updated.simpleDate)"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 137.0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryCell")
        update(cell: cell, atRow: indexPath.row)
        return cell ?? UITableViewCell()
    }
    
}

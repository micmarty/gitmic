//
//  UserViewController.swift
//  GithubClient
//
//  Created by Michał Martyniak on 05/30/2019.
//  Copyright © 2019 Michał Martyniak. All rights reserved.
//

import UIKit
import Foundation

struct RepoItem: Decodable {
    let name: String?
    let watchers: Int?
    let openIssues: Int?
    let stars: Int?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case watchers = "watchers_count"
        case openIssues = "open_issues"
        case stars = "stargazers_count"
    }
}

class RepoTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var issuesLabel: UILabel!
    @IBOutlet weak var watchersLabel: UILabel!
}

class UserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var user: ResultItem?
    var repos: [RepoItem] = []
    
    @IBOutlet weak var repoTableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBAction func goBackClicked(_ sender: Any) {
        performSegueToReturnBack()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadReposFromQuery()
        setUI()
    }
    
    func loadReposFromQuery(){
        if let url = URL(string: "https://api.github.com/users/\(user!.login!)/repos") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let res = try JSONDecoder().decode([RepoItem].self, from: data)
                        self.repos = res
                        print("tutaj kurwA")
                        print(res)
                        DispatchQueue.main.async {
                            self.repoTableView.reloadData() //code for updating the UI
                        }
                    } catch let error {
                        print(error)
                    }
                }
                }.resume()
        }
        repoTableView.reloadData()
    }
    
    func setUI() {
        usernameLabel.text = user?.login
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        repoTableView.reloadData()
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repo = repos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepoCell") as! RepoTableViewCell
        cell.nameLabel?.text = "\(repo.name!)"
        cell.starsLabel?.text = "⭐️ \(repo.stars!)"
        cell.watchersLabel?.text = "👁‍🗨 \(repo.watchers!)"
        cell.issuesLabel?.text =  "⚠️ \(repo.openIssues!)"
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

}

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

struct UserItem: Decodable {
    let blog: String?
    let following: Int?
    let followers: Int?

    
    private enum CodingKeys: String, CodingKey {
        case blog
        case following
        case followers
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
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var repoTableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var blogLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
    @IBAction func goBackClicked(_ sender: Any) {
        performSegueToReturnBack()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImageView.useImage(from: user!.avatarUrl!)
        if let username = user?.login {
            usernameLabel.text = username
            loadReposFromQuery(username: username)
            loadUserInfoFromQuery(username: username)
        }else{
            print("Error, could not unwrap login")
        }
    }
    
    func loadReposFromQuery(username: String){
        if let url = URL(string: "https://api.github.com/users/\(username)/repos") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let res = try JSONDecoder().decode([RepoItem].self, from: data)
                        self.repos = res
                        DispatchQueue.main.async {
                            self.repoTableView.reloadData()
                        }
                    } catch let error {
                        print(error)
                    }
                }
                }.resume()
        }
        repoTableView.reloadData()
    }
    
    func loadUserInfoFromQuery(username: String){
        if let url = URL(string: "https://api.github.com/users/\(username)") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let userData = try JSONDecoder().decode(UserItem.self, from: data)
                        DispatchQueue.main.async {
                            self.blogLabel.text = userData.blog!
                            self.followersLabel.text = String(userData.followers!)
                            self.followingLabel.text = String(userData.following!)
                        }
                    } catch let error {
                        print(error)
                    }
                }
                }.resume()
        }
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

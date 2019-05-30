//
//  ViewController.swift
//  GithubClient
//
//  Created by Michał Martyniak on 05/30/2019.
//  Copyright © 2019 Michał Martyniak. All rights reserved.
//

import UIKit
import Foundation

struct SearchResults: Decodable {
    let totalCount: Int
    let items: [ResultItem] //List<ResultItem>()
    
//    init(from decoder: Decoder) throws {
//        items = try items.decode([ResultItem].self, forKey: .items)
////        items.append(objectsIn: itemsArray)
//    }
    private enum CodingKeys: String, CodingKey {
        case items
        case totalCount = "total_count"
    }
}

struct ResultItem: Decodable {
    let score: Float?
    let login: String?
    let avatarUrl: String? // URL?
    let reposUrl: String?
    
    private enum CodingKeys: String, CodingKey {
        case score
        case login
        case reposUrl = "repos_url"
        case avatarUrl = "avatar_url"
    }
}

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameField: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var users: [ResultItem] = []

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var searchUsersButton: UIButton!
    
    func loadUsersFromQuery(username: String){
        guard let gitUrl = URL(string: "https://api.github.com/search/users?q=\(username)") else { return }
        URLSession.shared.dataTask(with: gitUrl) { (data, response, error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let gitData = try decoder.decode(SearchResults.self, from: data)
                self.users = gitData.items
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let err {
                print("Err", err)
            }
            }.resume()
        tableView.reloadData()
    }
    
    @IBAction func onSearchUsersButtonClick(_ sender: Any) {
        if let typedUsername = textField.text{
            loadUsersFromQuery(username: typedUsername)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUsersFromQuery(username: "ab")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserTableViewCell
        cell.usernameField?.text = user.login
        cell.avatarImageView?.useImage(from: user.avatarUrl!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        performSegue(withIdentifier: "MasterToDetail", sender: user)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MasterToDetail" {
            let destVC = segue.destination as! UserViewController
            if let user = sender as? ResultItem {
                destVC.user = user
            }
        }
    }

}

extension UIImageView {
    func useImage(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
}

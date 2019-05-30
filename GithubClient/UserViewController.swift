//
//  UserViewController.swift
//  GithubClient
//
//  Created by Michał Martyniak on 05/30/2019.
//  Copyright © 2019 Michał Martyniak. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {
    var user: ResultItem?
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    
    func setUI() {
        usernameLabel.text = user?.login
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}

//
//  ViewController.swift
//  News
//
//  Created by Chmola Lilia on 8/19/19.
//  Copyright © 2019 Lilia Chmola. All rights reserved.
//

import UIKit
import SDWebImage
import CCBottomRefreshControl
import SafariServices

class MainViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var searchString = "A"
    private var sortBy = "publishedAt"
    private var page = 1
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        return refreshControl
    }()
    lazy var bottomRefreshControl: UIRefreshControl = {
        let bottomRefreshControl = UIRefreshControl()
        bottomRefreshControl.triggerVerticalOffset = 100
        bottomRefreshControl.addTarget(self, action: #selector(pagination), for: .valueChanged)
        return bottomRefreshControl
    }()
    private let networkManager = NetworkManager()
    private var newsArray = [News]()
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        networkManager.getNewsWith(search: searchString, sortBy: sortBy, page: page) { (newsArray) in
            self.newsArray = newsArray
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        }
        tableView.refreshControl = refreshControl
        tableView.bottomRefreshControl = bottomRefreshControl
    }
    
    @objc private func requestData() {
        print("startRefreshing")
        
        networkManager.getNewsWith(search: searchString, sortBy: sortBy, page: page) { (newsArray) in
            self.newsArray = newsArray
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK: - @IBAction func
    
    @IBAction func filterButtonTapped(_ sender: UIBarButtonItem) {
        let filterView = FilterView.init(frame: UIScreen.main.bounds)
        navigationController?.view.addSubview(filterView)
        filterView.delegate = self
        filterView.displayWithAnimation()
        view.endEditing(true)
    }
    
    // MARK: - Private func
    
    @objc private func pagination() {
        print("startRefreshing")
        
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.bottomRefreshControl.endRefreshing()
        }
    }
    
    fileprivate func replaceSpaceIn(string: inout String) {
        string = string.replacingOccurrences(of: " ", with: "&")
    }
}

// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let safariVC = SFSafariViewController(url: newsArray[indexPath.row].url)
        present(safariVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == newsArray.count - 1 {
            page += 1
            networkManager.getNewsWith(search: searchString, sortBy: sortBy, page: page) { (newsArray) in
                self.newsArray.append(contentsOf: newsArray)
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let newsCell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        
        let news = newsArray[indexPath.row]
        newsCell.titleLabel.text = news.title
        newsCell.authorLabel.text = news.authorString
        newsCell.sourceLabel.text = news.name
        newsCell.descriptionLabel.text = news.description
        newsCell.newsImageView.sd_setImage(with: news.urlToImage, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        newsCell.selectionStyle = .none

        
        return newsCell
    }
}

// MARK: - UISearchBarDelegate

extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        var searchString = searchBar.text!
        replaceSpaceIn(string: &searchString )
        self.searchString = searchString
        page = 1
        networkManager.getNewsWith(search: self.searchString, sortBy: sortBy, page: page) { (newsArray) in
            self.newsArray = newsArray
            self.tableView.reloadData()
        }
    }
}

extension MainViewController: FilterViewDelegate {
    func selected(filter: String) {
        sortBy = filter
        page = 1
        networkManager.getNewsWith(search: searchString, sortBy: sortBy, page: page) { (newsArray) in
            self.newsArray = newsArray
            self.tableView.reloadData()
        }
    }
}

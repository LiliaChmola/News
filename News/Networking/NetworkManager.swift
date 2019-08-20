//
//  NetworkManager.swift
//  News
//
//  Created by Chmola Lilia on 8/19/19.
//  Copyright © 2019 Lilia Chmola. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    func getNewsWith(search: String, sortBy: String, page: Int, compeltion: @escaping ([News]) -> Void) {
        Alamofire.request("https://newsapi.org/v2/everything?q=\(search)&sortBy=\(sortBy)&pePage=20&page=\(page)&apiKey=1e6671c6dc4042459b3a72e0906d707c").responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                if let articlesDictArray = jsonDict["articles"] as? [[String: Any]] {
                    var newsArray = [News]()
                    for dict in articlesDictArray {
                        if let news = News.init(with: dict) {
                            newsArray.append(news)
                        }
                    }
                    compeltion(newsArray)
                }
            }
        }
    }
}

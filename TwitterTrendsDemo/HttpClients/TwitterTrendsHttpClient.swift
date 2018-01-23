//
//  TwitterTrendsHttpClient.swift
//  TwitterTrendsDemo
//
//  Created by Bader BEN ZRIBIA on 22.01.18.
//  Copyright © 2018 Bader Ben Zribia. All rights reserved.
//

import Foundation

class TwitterTrendsHttpClient
{
    func getWoeid(with latitude : String, longitude : String, completion: @escaping (String?, APIError?) -> Void) {
        
        let urlString = TwitterAPI.twitterBaseUrlString + TwitterAPI.twitterClosestUrlString + String(format: TwitterAPI.coordinateUrlString, latitude, longitude)
        guard let url = URL(string: urlString) else {
            completion(nil, .buildingRequestError)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(TwitterAPI.twitterAPIHeader, forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            
            guard let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                error == nil else {
                    
                    completion(nil, .connectingServerError)
                    return
            }
            
            do {
                let decoder = JSONDecoder()
                let root = try decoder.decode([ClosestRoot].self, from: data)
                if root.count > 0 {
                    completion(String(root[0].woeid), nil)
                }
                else {
                    completion(nil, .parsingResponseError)
                }
            }
            catch {
                completion(nil, .parsingResponseError)
                return
            }
            
            }.resume()
        
    }
    
    func getTrends(woeid : String, completion: @escaping ([Trend]?, APIError?) -> Void)
    {
        let urlString = TwitterAPI.twitterBaseUrlString + TwitterAPI.twitterTrendsUrlString + String(format: TwitterAPI.woeidUrlString, woeid)
        guard let url = URL(string: urlString) else {
            completion(nil, .buildingRequestError)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(TwitterAPI.twitterAPIHeader, forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            
            guard let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                error == nil else {
                    
                    completion(nil, .connectingServerError)
                    return
            }
            
            do {
                let decoder = JSONDecoder()
                let trendList = try decoder.decode([TrendsRoot].self, from: data)
                if trendList.count > 0 {
                    completion(trendList[0].trends, nil)
                }
                else {
                    completion(nil, .parsingResponseError)
                }
            }
            catch {
                completion(nil, .parsingResponseError)
                return
            }
            
            }.resume()
    }
}

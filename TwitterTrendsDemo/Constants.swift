//
//  Constants.swift
//  TwitterTrendsDemo
//
//  Created by Bader BEN ZRIBIA on 23.01.18.
//  Copyright © 2018 Bader Ben Zribia. All rights reserved.
//

import Foundation

struct TwitterAPI {
    static let twitterAPIHeader = "Bearer AAAAAAAAAAAAAAAAAAAAALlT4AAAAAAAOwdp2ilo0mGl%2BmRPFQixoS11cP8%3DV0Yc4LTJoqy4YlXlOcK0ct5a4GGdQTEaxj0GqBlHEq65tbwa8L"
    static let twitterBaseUrlString = "https://api.twitter.com/1.1/"
    static let twitterTrendsUrlString = "trends/place.json?"
    static let woeidUrlString = "id=%@"
    static let twitterClosestUrlString = "trends/closest.json?"
    static let coordinateUrlString = "lat=%@&long=%@"
}

enum APIError: String {
    case buildingRequestError = "Url Request Error"
    case connectingServerError = "Request Parameters Error"
    case parsingResponseError = "Parsing Server Response Error"
}


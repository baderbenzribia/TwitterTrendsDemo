//
//  Trend.swift
//  TwitterTrendsDemo
//
//  Created by Bader BEN ZRIBIA on 22.01.18.
//  Copyright © 2018 Bader Ben Zribia. All rights reserved.
//

import Foundation

struct TrendsRoot : Codable {
    let trends : [Trend]
    let as_of : String
    let created_at : String
    let locations : [Location]
}

struct Location : Codable {
    let name : String
    let woeid : Int
}

struct Trend : Codable {
    let name : String
    let url : String
}

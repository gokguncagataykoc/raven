//
//  Stats.swift
//  Raven
//
//  Created by Gök Gün Çağatay Koç on 22.02.2022.
//

import Foundation
import SwiftUI


struct VideoStatsResult: Codable, Equatable {
    let kind: String
    let etag:String
    let items: [Stats]
    let pageInfo: pageInfo
    
    enum CodingKeys: String, CodingKey {
        case kind
        case etag
        case items
        case pageInfo
    }
}

struct pageInfo: Codable, Equatable {
    let totalResults: Int32
    let resultsPerPage: Int32
    
    enum CodingKeys: String, CodingKey {
        case totalResults
        case resultsPerPage
    }
}

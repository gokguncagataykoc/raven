//
//  Stats.swift
//  Raven
//
//  Created by Gök Gün Çağatay Koç on 22.02.2022.
//

import Foundation
import SwiftUI

struct Stats: Codable, Equatable {
    let kind: String
    let etag: String
    let id: String
    let statistics: statistics
    
    enum CodingKeys: String, CodingKey {
        case kind
        case etag
        case id
        case statistics
    }
}

struct statistics: Codable, Equatable {
    let viewCount: String
    let likeCount: String
    let favoriteCount: String
    let commentCount: String
    
    enum CodingKeys: String, CodingKey {
        case viewCount
        case likeCount
        case favoriteCount
        case commentCount
    }
}

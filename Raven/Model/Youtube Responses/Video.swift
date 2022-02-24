//
//  VideoList.swift
//  Raven
//
//  Created by Gök Gün Çağatay Koç on 18.02.2022.
//

import Foundation
import SwiftUI


struct Video: Codable, Equatable {
    let kind: String
    let etag:String
    let id: id
    let snippet: snippet
    
    enum CodingKeys: String, CodingKey {
        case kind
        case etag
        case id
        case snippet
    }
}

struct id: Codable, Equatable {
    let kind: String
    let videoId: String
    
    enum CodingKeys: String, CodingKey {
        case kind = "kind"
        case videoId = "videoId"
    }
}

struct snippet: Codable, Equatable {
    let publishedAt: String
    let channelId: String
    let title: String
    let description: String
    let thumbnails: thumbnails
    let channelTitle: String
    let liveBroadcastContent: String
    let publishTime: String
    
    enum CodingKeys: String, CodingKey {
        case publishedAt
        case channelId
        case title
        case description
        case thumbnails
        case channelTitle
        case liveBroadcastContent
        case publishTime
    }
}

struct thumbnails: Codable, Equatable {
    let high: high
    
    enum CodingKeys: String, CodingKey {
        case high = "high"
    }
}

struct high: Codable, Equatable {
    let url: String
    let width: Int
    let height: Int
    
    enum CodingKeys: String, CodingKey {
        case url
        case width
        case height
    }
}

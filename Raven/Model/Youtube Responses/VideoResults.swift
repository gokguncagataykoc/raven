//
//  VideoResults.swift
//  Raven
//
//  Created by Gök Gün Çağatay Koç on 18.02.2022.
//

import Foundation

struct VideoResults: Codable {
    
    let kind: String
    let nextPageToken: String
    let items: [Video]
    
    enum CodingKeys: String, CodingKey {
        case kind = "kind"
        case nextPageToken = "nextPageToken"
        case items = "items"
    }
    
}

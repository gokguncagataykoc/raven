//
//  VideoResponse.swift
//  Raven
//
//  Created by Gök Gün Çağatay Koç on 18.02.2022.
//

import Foundation

struct VideoResponse: Codable {
    let statusCode: Int
    let statusMessage: String
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case statusMessage = "status_message"
    }
}

extension VideoResponse: LocalizedError {
    var errorDescription: String? {
        return statusMessage
    }
}

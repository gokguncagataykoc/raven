//
//  YoutubeClient.swift
//  Raven
//
//  Created by Gök Gün Çağatay Koç on 18.02.2022.
//

import Foundation

class YoutubeClient {
    
    static let apiKey = "GOOGLE-API-KEY" // Google Api Key
    static let videoPageCount = 20
    
    struct SearchParams {
        static var id = ""
        static var q = ""
        static var pageToken = ""
    }
    
    enum Endpoints {
        static let base = "https://www.googleapis.com/youtube/v3/"
        static let apiKeyParam = "&key=\(YoutubeClient.apiKey)"
        
        case getVideolist(String, String)
        case getVideoData(String)
        
        var stringValue: String {
            switch self {
            case .getVideolist(let query, let pageToken): return Endpoints.base + "search?part=snippet&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&type=video" + Endpoints.apiKeyParam + "&maxResults=\(videoPageCount)&pageToken=\(pageToken.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            case .getVideoData(let videoId): return Endpoints.base + "videos?part=statistics&id=\(videoId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" + Endpoints.apiKeyParam
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(VideoResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    class func getVideolist(query: String, pageToken: String, completion: @escaping ([Video], Error?) -> Void) -> URLSessionDataTask {
        let task = taskForGETRequest(url: Endpoints.getVideolist(query, pageToken).url, responseType: VideoResults.self) { response, error in
            if let response = response {
                completion(response.items, nil)
            } else {
                completion([], error)
            }
        }
        return task
    }
    
    class func getVideoStats(videoId: String, completion: @escaping ([Stats], Error?) -> Void) -> URLSessionDataTask {
        let task = taskForGETRequest(url: Endpoints.getVideoData(videoId).url, responseType: VideoStatsResult.self) { response, error in
            if let response = response {
                completion(response.items, nil)
            } else {
                completion([], error)
            }
        }
        return task
    }
    
}

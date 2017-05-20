//
//  Network.swift
//  MusicProfile
//
//  Created by Tal Cohen on 22/04/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import Foundation
import SwiftyJSON

class Network {
    
    enum Method : String {
        case post = "POST"
        case get = "GET"
        case delete = "DELETE"
        case put = "PUT"
    }
    
    static let baseUrl = "http://themusicprofile.com"
    
    class func request(path: String, method: Network.Method = .post ,success:((_ json: JSON)->())?, failure:((_ error: Error?)->())?) {
        let endpoint = Network.baseUrl + path
        guard let escapedEndpoint = endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: escapedEndpoint) else {
            failure?(nil)
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                failure?(error)
                return
            }
            guard let data = data else {
                failure?(nil)
                return
            }
            let json = JSON(data: data)
            
            success?(json)
        }
        task.resume()
    }
}


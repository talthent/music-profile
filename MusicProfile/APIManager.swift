//
//  APIManager.swift
//  MusicProfile
//
//  Created by Tal Cohen on 20/05/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import Foundation
import SwiftyJSON

class APIManager {
    class func getUser(userId: String, success:((_ user: User)->())?, failure:((_ error: Error?)->())?) {
        let path = "/getUser/\(userId)"
        Network.request(path: path, method: .get, success: { (json) in
            let user = User(json: json)
            success?(user)
        }, failure: failure)
    }
    
    class func getPlaylist(userId: String, startingGenre: String, items: Int = 5, success:((_ playlist: [Song])->())?, failure:((_ error: Error?)->())?) {
        let path = "/getPlaylist/\(userId)/1/\(items)/\(startingGenre)/0"
        Network.request(path: path, method: .get, success: { (json) in
            let jsonArray = json.arrayValue
            var playlist = [Song]()
            jsonArray.forEach({ (json) in
                let song = Song(json: json)
                playlist.append(song)
            })
            success?(playlist)
        }, failure: failure)
    }
    
    
}


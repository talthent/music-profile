//
//  AppData.swift
//  MusicProfile
//
//  Created by Tal Cohen on 20/05/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import Foundation
import SwiftyJSON

class AppData {
    static let shared = AppData()
    
    var user : User!
    var playlist = [Song]()
}

class Song {
    let artistName : String
    let songName : String
    let genre : String
    let url : String
    
    init(json: JSON) {
        self.artistName = json["artistName"].stringValue
        self.songName = json["songName"].stringValue
        self.genre = json["currGenre"].stringValue
        self.url = json["url"].stringValue
    }
}

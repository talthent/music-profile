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
    let id: String
    let artistName : String
    let songName : String
    let genre : String
    let url : String
    
    init(id: String, songName: String, artistName: String, genre: String, url : String) {
        self.id = id
        self.artistName = artistName
        self.songName = songName
        self.genre = genre
        self.url = url
    }
    
    init(json: JSON) {
        self.id = UUID().uuidString
        self.artistName = json["artistName"].stringValue
        self.songName = json["songName"].stringValue
        self.genre = json["currGenre"].stringValue
        self.url = json["url"].stringValue
    }
}

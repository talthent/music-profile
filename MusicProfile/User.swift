//
//  User.swift
//  MusicProfile
//
//  Created by Tal Cohen on 20/05/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import Foundation
import SwiftyJSON

class User {
    let name : String
    let country: String
    let email: String
    let userId: String
    let username: String
    let photo : String
    let pie : [Subgenre]
    
    var categoriesPie : [Genre] {
        get {
            var results = [Genre]()
            pie.forEach { (subgenre) in
                if !results.contains(where: {$0.category == subgenre.category}) {
                    var percentages : Double = 0
                    pie.forEach {
                        if $0.category == subgenre.category {
                            percentages += $0.percentages
                        }
                    }
                    results.append(Genre(percentages: percentages, category: subgenre.category))
                }
            }
            return results
        }
    }
    
    var randomSubgenre : Subgenre? {
        get {
            if self.pie.isEmpty {
                return nil
            }
            let number = Int(arc4random_uniform(UInt32(self.pie.count)))
            return self.pie[number]
        }
    }
    
    init(json: JSON) {
        self.name = json["user"]["firstName"].stringValue + "" + json["user"]["lastName"].stringValue
        self.country = json["user"]["country"].stringValue
        self.email = json["user"]["email"].stringValue
        self.userId = json["user"]["userId"].stringValue
        self.username = json["user"]["username"].stringValue
        self.photo = json["user"]["profileImage"].stringValue
        let pleasure = json["pleasure"]["genres"].arrayValue
        self.pie = pleasure.flatMap { return Subgenre(json: $0) }.sorted{ $0.0.category > $0.1.category}
    }
    
}

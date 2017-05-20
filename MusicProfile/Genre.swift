//
//  Genre.swift
//  MusicProfile
//
//  Created by Tal Cohen on 20/05/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import Foundation
import SwiftyJSON

class Subgenre : Genre {
    let name : String
    
    init(json: JSON) {
        self.name = json["genreName"].stringValue
        let category = json["category"].stringValue
        let percentages = json["percent"].doubleValue
        let color = Colors.random
        super.init(percentages: percentages, color: color, category: category)
    }
}

class Genre {
    let percentages : Double
    let color : UIColor
    let category : String
    init(percentages : Double, color : UIColor = Colors.random, category : String) {
        self.percentages = percentages
        self.color = color
        self.category = category
    }
}


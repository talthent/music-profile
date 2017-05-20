//
//  Colors.swift
//  MusicProfile
//
//  Created by Tal Cohen on 20/05/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import UIKit

class Colors {
    static let cyan = UIColor(red: 114/255, green: 238/255, blue: 252/255, alpha: 1)
    static let cyanBlue = UIColor(red: 106/255, green: 227/255, blue: 251/255, alpha: 1)
    static let lightBlue = UIColor(red: 78/255, green: 189/255, blue: 248/255, alpha: 1)
    static let blue = UIColor(red: 63/255, green: 117/255, blue: 240/255, alpha: 1)
    static let purple = UIColor(red: 123/255, green: 47/255, blue: 244/255, alpha: 1)
    static let violet = UIColor(red: 194/255, green: 58/255, blue: 162/255, alpha: 1)
    static let lightRed = UIColor(red: 237/255, green: 59/255, blue: 112/255, alpha: 1)
    
    class var random : UIColor {
        get {
            let a = [Colors.cyan, Colors.cyanBlue, Colors.lightBlue, Colors.blue, Colors.purple, Colors.violet, Colors.lightRed]
            let number = arc4random_uniform(UInt32(a.count))
            return a[Int(number)]
        }
    }
}

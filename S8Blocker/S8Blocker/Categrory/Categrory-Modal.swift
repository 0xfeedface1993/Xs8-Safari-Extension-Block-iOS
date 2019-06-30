//
//  Categrory-Modal.swift
//  S8Blocker
//
//  Created by virus1993 on 2018/1/15.
//  Copyright © 2018年 ascp. All rights reserved.
//

import Foundation

struct ListCategrory : Codable {
    var name : String
    var segue : String
    var image : String
    var site : String
    static var menus : [ListCategrory] = {
        guard let fileURL = Bundle.main.url(forResource: "categrory", withExtension: "plist") else {
            return [ListCategrory]()
        }
        
        do {
            let file = try Data(contentsOf: fileURL)
            let decoder = PropertyListDecoder()
            let plist = try decoder.decode([ListCategrory].self, from: file)
            return plist
        }   catch {
            print(error)
            return [ListCategrory]()
        }
    }()
}

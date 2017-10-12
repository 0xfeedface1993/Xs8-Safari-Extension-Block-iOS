//
//  JsonModal.swift
//  S8Blocker
//
//  Created by virus1993 on 2017/10/12.
//  Copyright © 2017年 ascp. All rights reserved.
//

import Foundation

struct MovieItem : Codable {
    var size : String
    var movie_time : String
    var movie_id : String
    var title : String
    var formart : String
    var page : String
    var msk : String
    var site_id : String
    static func movieItems(data: Data) -> [MovieItem] {
        let decoder = JSONDecoder()
        let item = try? decoder.decode([MovieItem].self, from: data)
        return item ?? []
    }
}

struct LoginResopnse : Codable {
    var id : String
    var name : String
    var info : String
}

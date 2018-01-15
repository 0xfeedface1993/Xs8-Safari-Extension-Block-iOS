//
//  JsonModal.swift
//  S8Blocker
//
//  Created by virus1993 on 2017/10/12.
//  Copyright © 2017年 ascp. All rights reserved.
//

import Foundation

struct MovieResponse : Codable {
    var page_number : String
    var all_pages : String
    var movies : [MovieItem]
}

struct MovieItem : Codable {
    var size : String
    var movie_time : String
    var movie_id : String
    var title : String
    var formart : String
    var page : String
    var msk : String
    var site_id : String
    var description : String
    var pics : [Picture]
    var links : [DownloadLink]
}

struct Picture : Codable {
    var image_url : String
    var create_time : String
    var id : String
}

struct DownloadLink : Codable {
    var url : String
    var create_time : String
    var id : String
}

struct LoginResopnse : Codable {
    var id : String
    var name : String
    var info : String
}

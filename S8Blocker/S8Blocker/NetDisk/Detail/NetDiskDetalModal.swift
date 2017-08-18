//
//  NetDiskDetalModal.swift
//  S8Blocker
//
//  Created by virus1994 on 2017/8/17.
//  Copyright © 2017年 ascp. All rights reserved.
//

import Foundation

struct NetDiskDetalModal {
    var fileName : String
    var title : String
    var passwod : String
    var pageurl : String
    var images : [String]
    var links : [String]
    var count : Int {
        get {
            return 4 + images.count
        }
    }
    init(data : [String:Any]?) {
        fileName = data?["fileName"] as? String ?? ""
        title = data?["title"] as? String ?? ""
        passwod = data?["passwod"] as? String ?? ""
        pageurl = data?["url"] as? String ?? ""
        links = data?["links"] as? [String] ?? []
        images = data?["pics"] as? [String] ?? []
    }
}

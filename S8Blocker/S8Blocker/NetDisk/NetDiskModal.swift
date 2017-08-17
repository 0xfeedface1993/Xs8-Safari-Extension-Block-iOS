//
//  NetDiskModal.swift
//  Sex8BlockExtension-iOS
//
//  Created by virus1993 on 2017/8/17.
//  Copyright © 2017年 ascp. All rights reserved.
//

import Foundation

struct NetDiskModal {
    var title : String
    var images : [String]
    var href : String
    init() {
        title = ""
        href = ""
        images = ["NetDisk", "NetDisk", "NetDisk"]
    }
    
    init(data: [String:Any]?) {
        title = data?["title"] as? String ?? ""
        href = data?["href"] as? String ?? ""
        images = [String]()
        guard let imgs = data?["images"] as? [String] else {
            images = ["NetDisk", "NetDisk", "NetDisk"]
            return
        }
        
        imgs.enumerated().forEach { (offset, element) in
            images.append(element)
        }
    }
}

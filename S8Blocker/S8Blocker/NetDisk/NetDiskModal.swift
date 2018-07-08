//
//  NetDiskModal.swift
//  Sex8BlockExtension-iOS
//
//  Created by virus1993 on 2017/8/17.
//  Copyright © 2017年 ascp. All rights reserved.
//

import Foundation
import CloudKit

struct NetDiskModal {
    var title : String
    var images = [String]()
    var downloads = [String]()
    var href : String
    var password = ""
    var fileSize = "-M"
    var boradType : String
    var favorite = 0
    var recordID : CKRecord.ID?
    
    init() {
        title = ""
        href = ""
        boradType = ""
    }
    
    init(data: [String:Any]?) {
        title = data?["title"] as? String ?? ""
        href = data?["href"] as? String ?? ""
        boradType = data?["boradType"] as? String ?? ""
    }
    
    init(content: ContentInfo, boradType: String) {
        title = content.title
        href = content.page
        images = content.imageLink
        password = content.passwod
        downloads = content.downloafLink
        fileSize = content.size
        self.boradType = boradType
    }
}

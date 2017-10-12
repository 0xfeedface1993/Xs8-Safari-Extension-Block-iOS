//
//  DictionaryExtension.swift
//  S8Blocker
//
//  Created by virus1993 on 2017/10/12.
//  Copyright © 2017年 ascp. All rights reserved.
//

import Foundation

extension Dictionary {
    func postParams() -> String {
        if let dic = self as? [String:String] {
            var paras = ""
            dic.forEach({ (item) in
                paras += "\(item.key)=\(item.value)&"
            })
            return paras
        }
        return ""
    }
}

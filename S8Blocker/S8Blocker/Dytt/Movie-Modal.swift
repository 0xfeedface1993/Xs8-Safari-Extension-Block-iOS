//
//  Movie.swift
//  S8Blocker
//
//  Created by virus1993 on 2018/1/15.
//  Copyright © 2018年 ascp. All rights reserved.
//

import Foundation
import HTMLString

//struct ListItem {
//    var title : String
//    var description : String
//    var image : String
//}

struct ListItem : Equatable {
    var title : String
    var href : String
    var previewImages : [String]
    init(data: [String:Any]) {
        title = data["title"] as? String ?? ""
        href = data["href"] as? String ?? ""
        previewImages = data["images"] as? [String] ?? []
    }
    
    static func ==(lhs: ListItem, rhs: ListItem) -> Bool {
        return lhs.title == rhs.title && lhs.href == rhs.href
    }
}

/// struct
enum FetchBoard : Int {
    case netDisk = 103
    case listMovie = 23
}


/// 演员导演信息
struct Creator {
    var name : String
    var english : String
}

/// 列表页面链接信息
struct FetchURL : Equatable {
    var site : String
    var board : FetchBoard
    var page : Int
    var maker : (FetchURL) -> String
    var url : URL {
        get {
            return URL(string: maker(self))!;
        }
    }
    
    static func ==(lhs: FetchURL, rhs: FetchURL) -> Bool {
        return lhs.url == rhs.url
    }
}

/// 抓取内容页面信息模型
struct ContentInfo : Equatable {
    var title : String
    var page : String
    var msk : String
    var time : String
    var size : String
    var format : String
    var passwod : String
    var downloafLink : [String]
    var imageLink : [String]
    
//    ◎译　　名　电锯惊魂8：竖锯/电锯惊魂8/夺魂锯：游戏重启(台)/恐惧斗室之狂魔再现(港)/电锯惊魂：遗产
    var translateName : String
//    ◎片　　名　Jigsaw
    var movieRawName : String
//    ◎年　　代　2017
    var releaseYear : String
//    ◎产　　地　美国
    var produceLocation : String
//    ◎类　　别　悬疑/惊悚/恐怖
    var styles : [String]
//    ◎语　　言　英语
    var languages : [String]
//    ◎字　　幕　中英双字幕
    var subtitle : String
//    ◎上映日期　2017-10-27(美国)
    var showTimeInfo : String
    var fileFormart : String
//    ◎文件格式　HD-RMVB
    var videoSize : String
//    ◎视频尺寸　1280 x 720
    var movieTime : String
//    ◎片　　长　91分钟
    var directes : [Creator]
//    ◎导　　演　迈克尔·斯派瑞 Michael Spierig / 彼得·斯派瑞 Peter Spierig
    var actors : [Creator]
//    ◎主　　演　马特·帕斯摩尔 Matt Passmore
    var _note : String
    var note : String {
        set {
            _note = newValue.replacingOccurrences(of: "</p>", with: "").replacingOccurrences(of: "<p>", with: "").replacingOccurrences(of: "<br /><br />", with: "\n").replacingOccurrences(of: "<br />", with: "\n").replacingOccurrences(of: "<br", with: "").removingHTMLEntities
        }
        get {
            return _note
        }
    }
    
    init() {
        page = ""
        title = ""
        msk = ""
        time = ""
        size = ""
        format = ""
        passwod = ""
        downloafLink = [String]()
        imageLink = [String]()
        
        translateName = ""
        movieRawName = ""
        releaseYear = ""
        produceLocation = ""
        styles = [String]()
        languages = [String]()
        subtitle = ""
        showTimeInfo = ""
        fileFormart = ""
        videoSize = ""
        movieTime = ""
        directes = [Creator]()
        actors = [Creator]()
        _note = ""
    }
    
    static func ==(lhs: ContentInfo, rhs: ContentInfo) -> Bool {
        return lhs.title == rhs.title && lhs.page == rhs.page
    }
}

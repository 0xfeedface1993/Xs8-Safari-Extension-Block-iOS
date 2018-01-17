//
//  FetchBot.swift
//  S8Blocker
//
//  Created by virus1993 on 2018/1/15.
//  Copyright © 2018年 ascp. All rights reserved.
//

import Foundation

struct Site {
    var hostName : String
    var parentUrl : URL
    var name : String
    func page(bySuffix suffix: Int) -> URL {
        return parentUrl.appendingPathComponent("list_23_\(suffix).html")
    }
    static let dytt = Site(hostName: "www.ygdy8.net", parentUrl: URL(string: "http://www.ygdy8.net/html/gndy/dyzz")!, name: "电影天堂")
    static let netdisk = Site(hostName: "www.ygdy8.net", parentUrl: URL(string: "http://www.ygdy8.net/html/gndy/dyzz")!, name: "网盘下载")
}

/// 内容信息正则规则选项
struct InfoRuleOption {
    /// 是否有码
    static let msk = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "((【是否有码】)|(【有碼無碼】)|(【影片说明】)|(【影片說明】)|(【是否有碼】)){1}[：:]{0,1}((&nbsp;)|(\\s))*", hasSuffix: nil, innerRegex: "([^<：:(&nbsp;)])+")
    /// 影片时间
    static let time = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "((【影片时间】)|(【影片時間】)|(【视频时间】)){1}[：:]{0,1}((&nbsp;)|(\\s))*", hasSuffix: nil, innerRegex: "([^<(&nbsp;)])+")
    /// 影片大小
    static let size = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "((【影片大小】)|(【视频大小】)){1}[：:]{0,1}((&nbsp;)|(\\s))*", hasSuffix: nil, innerRegex: "([^<：:(&nbsp;)])+")
    /// 影片格式
    static let format = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "((【影片格式】)|(【视频格式】)){1}[：:]{0,1}", hasSuffix: nil, innerRegex: "([^<：:])+")
    /// 解压密码
    static let password = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "((【解壓密碼】)|(【解压密码】)|(解壓密碼)){1}[：:]{0,1}((&nbsp;)|(\\s))*", hasSuffix: nil, innerRegex: "([^<：:])+")
    /// 下载链接
    static let downloadLink = ParserTagRule(tag: "a", isTagPaser: true, attrubutes: [], inTagRegexString: " \\w+=\"\\w+:\\/\\/[\\w+\\.]+[\\/\\-\\w\\.]+\" \\w+=\"\\w+\"", hasSuffix: nil, innerRegex: "\\w+:\\/\\/[\\w+\\.]+[\\/\\-\\w\\.]+")
    /// 下载地址2
    static let downloadLinkLi = ParserTagRule(tag: "li", isTagPaser: true, attrubutes: [], inTagRegexString: "", hasSuffix: nil, innerRegex: "\\w+:\\/\\/[\\w+\\.]+[\\/\\-\\w\\.]+")
    /// 图片链接
    static let imageLink = ParserTagRule(tag: "img", isTagPaser: true, attrubutes: [ParserAttrubuteRule(key: "file"), ParserAttrubuteRule(key: "href"), ParserAttrubuteRule(key: "src")], inTagRegexString: "( \\w+=[\"']{1}[^<>]*[\"']{1})+ class=\"zoom\"( \\w+=[\"']{1}[^<>]*[\"']{1})+ \\/", hasSuffix: nil, innerRegex: nil)
    /// 主内容标签
    static let main = ParserTagRule(tag: "td", isTagPaser: true, attrubutes: [], inTagRegexString: " \\w+=\"t_f\" \\w+=\"postmessage_\\d+\"", hasSuffix: nil, innerRegex: nil)
    
    /// ---- 电影天堂 ---
    /// 主演列表
    static let mainActor = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "◎主[\\s]+演", hasSuffix: "◎", innerRegex: "[^◎]+")
    /// 主演名称
    static let singleActor = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "\\s*", hasSuffix: "<", innerRegex: "[^>]+")
    
    /// 导演列表
    static let mainDirector = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "◎导[\\s]+演", hasSuffix: "◎", innerRegex: "[^◎]+")
    /// 导演名称
    static let singleDirector = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "\\s*", hasSuffix: "[<|\\/]+", innerRegex: "[^\\/]+")
    
    /// 类别列表
    static let mainStyle = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "◎类[\\s]+别", hasSuffix: "◎", innerRegex: "[^◎]+")
    /// 类别名称
    static let singleStyle = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "[\\s\\/]*", hasSuffix: nil, innerRegex: "[^\\/]+")
    
    /// 语言列表
    static let mainLanguage = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "◎语[\\s]+言", hasSuffix: "◎", innerRegex: "[^◎]+")
    /// 语言名称
    static let singleLanguage = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "[\\s\\/]*", hasSuffix: nil, innerRegex: "[^\\/]+")
    
    static let translateName = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "◎译[\\s]+名[\\s]+", hasSuffix: "<", innerRegex: "[^◎<]+")
    static let movieRawName = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "◎片[\\s]+名[\\s]+", hasSuffix: "<", innerRegex: "[^<]+")
    static let releaseYear = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "◎年[\\s]+代[\\s]+", hasSuffix: "<", innerRegex: "[^<]+")
    static let produceLocation = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "◎产[\\s]+地[\\s]+", hasSuffix: "<", innerRegex: "[^<]+")
    static let subtitle = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "◎字[\\s]+幕[\\s]+", hasSuffix: "<", innerRegex: "[^<]+")
    static let showTimeInfo = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "◎上映日期[\\s]+", hasSuffix: "<", innerRegex: "[^<]+")
    static let fileFormart = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "◎文件格式[\\s]+", hasSuffix: "<", innerRegex: "[^<]+")
    static let videoSize = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "◎视频尺寸[\\s]+", hasSuffix: "<", innerRegex: "[^<]+")
    static let movieTime = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "◎片[\\s]+长[\\s]+", hasSuffix: "<", innerRegex: "[^<]+")
    
//    static let note = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "◎简[\\s]+介\\s+[<br \\/>]+", hasSuffix: "<img ", innerRegex: "[\\s\\S]+")◎简\s+介[^◎]+(◎|(<img))
    static let note = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "◎简\\s+介\\s*[(<br />)|(</{0,1}p>)]+", hasSuffix: "(◎|(<img)|(<p><strong>))", innerRegex: "[^◎]+")
//  ◎简\\s+介\\s*[(<br />)|(</{0,1}p>)]+[^◎]+(◎|(<img)|(<p><strong>))
    /// 标题列表
    static let mainTitle = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "<div \\w+=\"\\w+\"><h1><font \\w+=#\\w+>", hasSuffix: "</font></h1></div>", innerRegex: "[\\s\\S]*")
    /// 标题名称
    static let singleTitle = ParserTagRule(tag: "font", isTagPaser: true, attrubutes: [], inTagRegexString: " \\w+=\"#\\w+\"", hasSuffix: nil, innerRegex: "[^<]+")
    
    /// 图片列表
    static let mainMovieImage = ParserTagRule(tag: "img", isTagPaser: false, attrubutes: [ParserAttrubuteRule(key: "src")], inTagRegexString: "<img ", hasSuffix: ">", innerRegex: "[^>]+")
    
    /// 下载地址
    static let movieDowloadLink = ParserTagRule(tag: "a", isTagPaser: true, attrubutes: [ParserAttrubuteRule(key: "thunderrestitle"), ParserAttrubuteRule(key: "src"), ParserAttrubuteRule(key: "aexuztdb"), ParserAttrubuteRule(key: "href")], inTagRegexString: " \\w+=\"\\w+:\\/\\/\\w+:\\w+@\\w+.\\w+.\\w+:\\w+\\/[^\"]+\"", hasSuffix: nil, innerRegex: "\\w+:\\/\\/\\w+:\\w+@\\w+.\\w+.\\w+:\\w+\\/[^<]+")
}

/// 列表页面正则规则选项
struct PageRuleOption {
    /// 内容页面链接
    static let link = ParserTagRule(tag: "a", isTagPaser: true, attrubutes: [ParserAttrubuteRule(key: "href")], inTagRegexString: " href=\"\\w+(\\-[\\d]+)+.\\w+\" \\w+=\"\\w+\\(\\w+\\)\" class=\"s xst\"", hasSuffix: nil, innerRegex: nil)
    static let content = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "<tbody id=\"separatorline\">", hasSuffix: nil, innerRegex: "[\\s\\S]*")
    
    /// ---- 电影天堂 ---
    static let mLink = ParserTagRule(tag: "a", isTagPaser: true, attrubutes: [ParserAttrubuteRule(key: "href")], inTagRegexString: " href=\"[\\/\\w]+\\.\\w+\" class=\"ulink\"", hasSuffix: nil, innerRegex: nil)
    static let mContent = ParserTagRule(tag: "", isTagPaser: false, attrubutes: [], inTagRegexString: "<div class=\"co_area2\">", hasSuffix: nil, innerRegex: "[\\s\\S]*")
}

/// 自动抓取机器人
class FetchBot {
    private static let _bot = FetchBot()
    static var shareBot : FetchBot {
        get {
            return _bot
        }
    }
    
    let backgroundQueue = DispatchQueue.global()
    let backgroundGroup = DispatchGroup()
    var delegate : FetchBotDelegate?
    var contentDatas = [ContentInfo]()
    var runTasks = [FetchURL]()
    var badTasks = [FetchURL]()
    var startPage: UInt = 1
    var pageOffset: UInt = 0
    var count : Int = 0
    var startTime : Date?
    
    /// 初始化方法
    ///
    /// - Parameters:
    ///   - start: 开始页面，大于1
    ///   - offset: 结束页面 = start + offset
    init(start: UInt = 1, offset: UInt = 0) {
        self.startPage = start > 0 ? start:1
        self.pageOffset = offset
    }
    
    func start(withSite site: Site) {
        startTime = Date()
        runTasks.removeAll()
        badTasks.removeAll()
        count = 0
        contentDatas.removeAll()
        DispatchQueue.main.async {
            self.delegate?.bot(didStartBot: self)
        }
        fetchGroup(start: startPage, offset: pageOffset, site: site)
    }
    
    func stop() {
        runTasks.removeAll()
        badTasks.removeAll()
        count = 0
    }
    
    private func fetchGroup(start: UInt, offset: UInt, site : Site) {
        let maker : (FetchURL) -> String = { (s) -> String in
            site.page(bySuffix: s.page).absoluteString
        }
        let topQueue = DispatchQueue(label: "com.ascp.top")
        let group = DispatchGroup()
        
        for i in start...(start + offset) {
            let fetchURL = FetchURL(site: site.hostName, board: .listMovie, page: Int(i), maker: maker)
            let request = browserRequest(url: fetchURL.url)
            
            topQueue.async(group: group, execute: DispatchWorkItem(block: {
                let topSem = DispatchSemaphore(value: 0)
                
                let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, err) in
                    let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.HZ_GB_2312.rawValue))
                    guard let result = data, let html = String(data: result, encoding: String.Encoding(rawValue: enc)) else {
                        if let e = err {
                            print(e)
                        }
                        print("---------- bad decoder, \(response!.description) ----------")
                        self.badTasks.append(fetchURL)
                        topSem.signal()
                        return
                    }
                    
                    if let _ = html.range(of: "<html>\r\n<head>\r\n<META NAME=\"robots\" CONTENT=\"noindex,nofollow\">") {
                        print("---------- robot detected! ----------")
                        self.badTasks.append(fetchURL)
                        topSem.signal()
                        return
                    }
                    
                    let rule = PageRuleOption.mLink
                    self.runTasks.append(fetchURL)
                    
                    print("---------- 开始解析 \(i) 页面 ----------")
                    
                    if let pages = parse(string:html, rule: rule) {
                        let contentQueue = DispatchQueue(label: "com.ascp.content")
                        let contentGroup = DispatchGroup()
                        
                        print("++++++ 解析到 \(pages.count) 个内容链接")
                        
                        for (offset, page) in pages.enumerated() {
                            let title = page.innerHTML
                            guard let href = page.attributes["href"] else {
                                continue
                            }
                            self.count += 1
                            contentQueue.async(group: contentGroup, execute: DispatchWorkItem(block: {
                                self.fetchMainContent(title: title, link: href, page: fetchURL.page, index: offset, site: site)
                            }))
                            
                        }
                        
                        contentGroup.notify(queue: contentQueue, execute: {
                            topSem.signal()
                        })
                    }
                })
                
                task.resume()
                
                topSem.wait()
            }))
        }
        
        group.notify(queue: topQueue) {
            self.delegate?.bot(self, didFinishedContents: self.contentDatas, failedLink: self.badTasks)
        }
    }
    
    private func fetchMainContent(title: String, link: String, page: Int, index: Int, site : Site) {
        let linkMaker : (FetchURL) -> String = { (s) -> String in
            "http://\(s.site)\(link)"
        }
        let linkURL = FetchURL(site: site.hostName, board: .listMovie, page: page, maker: linkMaker)
        let request = browserRequest(url: linkURL.url)
        let sem = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
            let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
            guard let result = data, let html = String(data: result, encoding: String.Encoding(rawValue: enc)) else {
                if let e = err {
                    print(e)
                }
                self.badTasks.append(linkURL)
                return
            }
            
            if let _ = html.range(of: "<html>\r\n<head>\r\n<META NAME=\"robots\" CONTENT=\"noindex,nofollow\">") {
                print("---------- robot detected! ----------")
                self.badTasks.append(linkURL)
                return
            }
            
            let rule = PageRuleOption.mContent
            print("++++ \(page)页\(index)项 parser: \(link)")
            if let mainContent = parse(string:html, rule: rule)?.first?.innerHTML {
                var info = self.parser(withHtml: mainContent)
                info.page = linkURL.url.absoluteString
                self.contentDatas.append(info)
                self.delegate?.bot(self, didLoardContent: info, atIndexPath: self.contentDatas.count)
            }
            self.runTasks.append(linkURL)
            sem.signal()
        }
        task.resume()
        
        sem.wait()
    }
    
    func parser(withHtml mainContent: String) -> ContentInfo {
        var info = ContentInfo()
        
        let titlesRule = InfoRuleOption.mainTitle
        for result in parse(string:mainContent, rule: titlesRule) ?? [] {
            info.title = result.innerHTML
            print("**** title: \(result.innerHTML)")
        }
        
        let actorsRule = InfoRuleOption.mainActor
        for result in parse(string:mainContent, rule: actorsRule) ?? [] {
            for resultx in parse(string:result.innerHTML, rule: InfoRuleOption.singleActor) ?? [] {
                info.actors.append(Creator(name: resultx.innerHTML, english: ""))
                print("*********** actor link: \(resultx.innerHTML)")
            }
        }
        
        let directorsRule = InfoRuleOption.mainDirector
        for result in parse(string:mainContent, rule: directorsRule) ?? [] {
            for resultx in parse(string:result.innerHTML, rule: InfoRuleOption.singleDirector) ?? [] {
                info.directes.append(Creator(name: resultx.innerHTML, english: ""))
                print("*********** director link: \(resultx.innerHTML)")
            }
        }
        
        let translateNameRule = InfoRuleOption.translateName
        for result in parse(string:mainContent, rule: translateNameRule) ?? [] {
            info.translateName = result.innerHTML
            print("***** translateName: \(result.innerHTML)")
        }
        
        let movieRawNameRule = InfoRuleOption.movieRawName
        for result in parse(string:mainContent, rule: movieRawNameRule) ?? [] {
            info.movieRawName = result.innerHTML
            print("***** movieRawName: \(result.innerHTML)")
        }
        
        let releaseYearRule = InfoRuleOption.releaseYear
        for result in parse(string:mainContent, rule: releaseYearRule) ?? [] {
            info.releaseYear = result.innerHTML
            print("***** releaseYear: \(result.innerHTML)")
        }
        
        let produceLocationRule = InfoRuleOption.produceLocation
        for result in parse(string:mainContent, rule: produceLocationRule) ?? [] {
            info.produceLocation = result.innerHTML
            print("***** produceLocation: \(result.innerHTML)")
        }
        
        let subtitleRule = InfoRuleOption.subtitle
        for result in parse(string:mainContent, rule: subtitleRule) ?? [] {
            info.subtitle = result.innerHTML
            print("***** subtitle: \(result.innerHTML)")
        }
        
        let showTimeInfoRule = InfoRuleOption.showTimeInfo
        for result in parse(string:mainContent, rule: showTimeInfoRule) ?? [] {
            info.showTimeInfo = result.innerHTML
            print("***** showTimeInfo: \(result.innerHTML)")
        }
        
        let fileFormartRule = InfoRuleOption.fileFormart
        for result in parse(string:mainContent, rule: fileFormartRule) ?? [] {
            info.fileFormart = result.innerHTML
            print("***** fileFormart: \(result.innerHTML)")
        }
        
        let movieTimeRule = InfoRuleOption.movieTime
        for result in parse(string:mainContent, rule: movieTimeRule) ?? [] {
            info.movieTime = result.innerHTML
            print("***** movieTime: \(result.innerHTML)")
        }
        
        let noteRule = InfoRuleOption.note
        for result in parse(string:mainContent, rule: noteRule) ?? [] {
            info.note = result.innerHTML
            print("***** note: \(result.innerHTML)")
        }
        
        let imageRule = InfoRuleOption.mainMovieImage
        for result in parse(string:mainContent, rule: imageRule) ?? [] {
            if let src = result.attributes["src"] {
                info.imageLink.append(src)
                print("*********** image: \(src)")
            }
        }
        
        let dowloadLinkRule = InfoRuleOption.movieDowloadLink
        for linkResult in parse(string:mainContent, rule: dowloadLinkRule) ?? [] {
            info.downloafLink.append(linkResult.innerHTML)
            print("*********** download link: \(linkResult.innerHTML)")
        }
        
        return info
    }
}

protocol FetchBotDelegate {
    func bot(_ bot: FetchBot, didLoardContent content: ContentInfo, atIndexPath index: Int)
    func bot(didStartBot bot: FetchBot)
    func bot(_ bot: FetchBot, didFinishedContents contents: [ContentInfo], failedLink : [FetchURL])
}


/// 模仿浏览器URL请求
///
/// - Parameter url: URL对象
/// - Returns: URLRequest请求对象
func browserRequest(url : URL) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("zh-CN,zh;q=0.8,en;q=0.6", forHTTPHeaderField: "Accept-Language")
    request.addValue("Refer", forHTTPHeaderField: Site.dytt.hostName)
    request.addValue("1", forHTTPHeaderField: "Upgrade-Insecure-Requests")
    request.addValue("max-age=0", forHTTPHeaderField: "Cache-Control")
    request.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
    request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36", forHTTPHeaderField: "User-Agent")
    request.addValue("text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8", forHTTPHeaderField: "Accept")
    return request
}

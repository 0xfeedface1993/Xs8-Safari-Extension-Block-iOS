//
//  DownloaderTableViewCell.swift
//  S8Blocker
//
//  Created by virus1994 on 2018/6/19.
//  Copyright © 2018年 ascp. All rights reserved.
//

import UIKit
import WebShell_iOS

enum DownloadStatus : String {
    case downloading = "下载中"
    case downloaded = "完成"
    case waitting = "等待中"
    case cancel = "已取消"
    case errors = "失败"
    case abonden = "失效"
    static let statusColorPacks : [DownloadStatus:UIColor] = [.downloading:.green,
                                                              .downloaded:.blue,
                                                              .waitting:.lightGray,

                                                              .cancel:.darkGray,
                                                              .errors:.red,
                                                              .abonden:.brown]
}

extension WebHostSite {
    static let hostImagePack : [WebHostSite:UIImage] = [.feemoo: UIImage(named: "mofe_feemoo")!,
                                                        .pan666: UIImage(named: "mofe_666pan")!,
                                                        .cchooo: UIImage(named: "mofe_ccchooo")!,
                                                        .yousuwp: UIImage(named: "mofe_yousu")!,
                                                        .unknowsite: UIImage(named: "mofe_feemoo")!]
}

class DownloaderTableViewCell: UITableViewCell {
    @IBOutlet weak var siteImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var restartBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var percent: UILabel!
    @IBOutlet weak var status: UILabel!
    var info : DownloadStateInfo!
    var restartAction : ((DownloadStateInfo)->())?
    var cancelAction : ((DownloadStateInfo)->())?
    @IBOutlet weak var newSize: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        restartBtn.isHidden = true
        cancelBtn.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func load(newInfo: DownloadStateInfo) {
        info = newInfo
        siteImage.image = info.siteIcon
        title.text = info.name
        progressBar.progress = info.progress
        status.text = info.status.rawValue
        let megeSize = info.totalBytes / 1024.0 / 1024.0
        newSize.text = String(format: "%.2fM", megeSize)
        percent.text = String(format: "%.2f", info.progress * 100) + "%"
    }
    
    @IBAction func restart(_ sender: Any) {
        restartAction?(info)
    }
    
    @IBAction func cancel(_ sender: Any) {
        cancelAction?(info)
    }
    
    
}

/// 下载状态数据模型，用于视图数据绑定
struct DownloadStateInfo {
    var uuid = UUID().uuidString
    var status : DownloadStatus {
        didSet {
            update(newStatus: status)
        }
    }
    var hostType : WebHostSite {
        didSet {
            update(newSite: hostType)
        }
    }
    var originTask: PCDownloadTask?
    weak var riffle: PCWebRiffle?
    var name = ""
    var progress : Float = 0.0
    var totalBytes : Float = 1.0
    var site = ""
    var state = ""
    var stateColor = UIColor.black
    var isCanCancel : Bool = false
    var isCanRestart : Bool = false
    var isHiddenPrograss : Bool = false
    var siteIcon : UIImage?
    
    init() {
        status = .waitting
        hostType = .unknowsite
    }
    
    init(task: PCDownloadTask) {
        status = .downloading
        if let url = task.request.riffle?.mainURL {
            hostType = siteType(url: url)
        }   else    {
            hostType = .unknowsite
        }
        
        name = task.fileName
        let pros = task.pack.progress * 100.0
        let guts = Float(task.pack.totalBytes) / 1024.0 / 1024.0
        progress = pros
        totalBytes = guts
        originTask = task
        update(newSite: hostType)
        update(newStatus: status)
    }
    
    init(riffle: PCWebRiffle) {
        status = .waitting
        hostType = riffle.host
        name = riffle.mainURL?.absoluteString ?? "no url"
        progress = 0.0
        totalBytes = 1.0
        self.riffle = riffle
        update(newSite: hostType)
        update(newStatus: status)
    }
    
    mutating func update(newStatus: DownloadStatus) {
        state = newStatus.rawValue
        stateColor = DownloadStatus.statusColorPacks[status]!
        isCanCancel = status == .downloading || status == .waitting
        isCanRestart = status != .abonden && status != .waitting && status != .downloading
        isHiddenPrograss = status != .downloading
    }
    
    mutating func update(newSite: WebHostSite) {
        siteIcon = WebHostSite.hostImagePack[newSite]!
    }
    
    var description: String {
        return "status: \(status)\n hostType: \(hostType)\n name: \(name)\n uuid: \(uuid)\n progress: \(progress)\n" + "site: \(site)\n state: \(state)\n stateColor: \(stateColor)\n isCanCancel: \(isCanCancel)\n isCanRestart: \(isCanRestart)\n" + "isHiddenPrograss: \(isHiddenPrograss)\n siteIcon: \(siteIcon)"
    }
}

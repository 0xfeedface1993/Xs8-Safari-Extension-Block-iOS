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
    @IBOutlet weak var percent: UILabel!
    @IBOutlet weak var status: UILabel!
    var info : DownloadStateInfo!
    var restartAction : ((DownloadStateInfo)->())?
    var cancelAction : ((DownloadStateInfo)->())?
    @IBOutlet weak var newSize: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        restartBtn.isEnabled = false
        selectionStyle = .blue
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func load(newInfo: DownloadStateInfo) {
        info = newInfo
        siteImage.image = info.record.siteIcon
        title.text = info.record.name
        progressBar.progress = info.record.progress
        status.text = info.record.status
        status.textColor = info.record.stateColor
        restartBtn.isEnabled = info.record.isCanRestart
        let megeSize = info.record.totalBytes
        newSize.text = String(format: "%.2fM", megeSize / 1024.0 / 1024.0)
        percent.text = String(format: "%.2f", info.record.progress * 100) + "%"
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
    var originTask: PCDownloadTask?
    weak var riffle: PCWebRiffle?
    var record : DRecord! 
    
    init(record: DRecord) {
        self.record = record
        self.record.update(newSite: WebHostSite(rawValue: record.hostType)!)
        self.record.update(newStatus: DownloadStatus(rawValue: record.status)!)
    }
    
    init(task: PCDownloadTask) {
        record.load(task: task)
        originTask = task
    }
    
    init(riffle: PCWebRiffle) {
        record = DRecord.maker()
        record.uuid = riffle.uuid
        record.load(riffle: riffle)
        self.riffle = riffle
    }
    
    var description: String {
        return "status: \(record.status)\n hostType: \(record.hostType)\n name: \(record.name ?? "---")\n uuid: \(record.uuid.uuidString)\n progress: \(record.progress)\n" + "state: \(record.state ?? "---")\n stateColor: \(String(describing: record.stateColor))\n isCanCancel: \(record.isCanCancel)\n isCanRestart: \(record.isCanRestart)\n" + "isHiddenPrograss: \(record.isHiddenPrograss)\n siteIcon: \(String(describing: record.siteIcon))"
    }
}

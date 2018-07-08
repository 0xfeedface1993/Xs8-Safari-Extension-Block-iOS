//
//  DRecord+CoreDataClass.swift
//  S8Blocker
//
//  Created by virus1994 on 2018/6/20.
//  Copyright © 2018年 ascp. All rights reserved.
//
//

import UIKit
import CoreData
import WebShell_iOS

@objc(DRecord)
public class DRecord: NSManagedObject {
    public static func maker() -> DRecord {
        let app = UIApplication.shared.delegate as! AppDelegate
        let record = NSEntityDescription.insertNewObject(forEntityName: "DRecord", into: app.managedObjectContext) as! DRecord
        record.defaultLoad()
        return record
    }
    
    public func defaultLoad() {
        status = DownloadStatus.waitting.rawValue
        hostType = WebHostSite.unknowsite.rawValue
        startTimeStamp = Date()
    }
    
    func load(task: PCDownloadTask) {
        status = DownloadStatus.downloading.rawValue
        if let url = task.request.riffle?.mainURL {
            hostType = siteType(url: url).rawValue
        }   else    {
            hostType = WebHostSite.unknowsite.rawValue
        }
        uuid = task.request.uuid
        name = task.fileName
        let pros = task.pack.progress
        let guts = Float(task.pack.totalBytes) / 1024.0 / 1024.0
        progress = pros
        totalBytes = guts
    }
    
    func load(riffle: PCWebRiffle) {
        url = riffle.mainURL
        uuid = riffle.uuid
        status = DownloadStatus.waitting.rawValue
        hostType = riffle.host.rawValue
        name = riffle.mainURL?.absoluteString ?? "no url"
        progress = 0.0
        totalBytes = 1.0
    }
    
    public override func didChangeValue(forKey key: String) {
        switch key {
        case "status":
            update(newStatus: DownloadStatus(rawValue: status)!)
            break
        case "hostType":
            update(newSite: WebHostSite(rawValue: hostType)!)
        default:
            break
        }
    }
    
    func update(newStatus: DownloadStatus) {
        state = newStatus.rawValue
        stateColor = DownloadStatus.statusColorPacks[newStatus]!
        isCanCancel = newStatus == .downloading || newStatus == .waitting
        isCanRestart = newStatus != .abonden && newStatus != .waitting && newStatus != .downloading
        isHiddenPrograss = newStatus != .downloading
    }
    
    func update(newSite: WebHostSite) {
        siteIcon = WebHostSite.hostImagePack[newSite]!
    }
}

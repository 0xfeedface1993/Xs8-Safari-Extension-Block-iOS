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
    var saveFileName: String {
        let parts = name?.split(separator: ".")
        let last = String(parts?.last ?? "")
        let prefix = String(parts?.dropLast().joined() ?? "")
        return "\(prefix)(\(password ?? "")).\(last)"
    }
    
    var localFileURL: URL? {
        var documentURL = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
        documentURL.appendPathComponent(saveFileName)
        if FileManager.default.fileExists(atPath: documentURL.path) {
            return documentURL
        }   else    {
            return nil
        }
    }
    
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
        let guts = task.pack.totalBytes
        progress = pros
        totalBytes = Float(guts)
        remoteFileURL = task.request.request.url
        error = task.pack.error?.localizedDescription
    }
    
    func load(riffle: PCWebRiffle) {
        url = riffle.mainURL
        uuid = riffle.uuid
        status = DownloadStatus.waitting.rawValue
        hostType = riffle.host.rawValue
        name = riffle.mainURL?.absoluteString ?? "no url"
        progress = 0.0
        totalBytes = 1.0
        password = riffle.password
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

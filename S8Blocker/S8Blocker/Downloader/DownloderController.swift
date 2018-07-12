//
//  DownloderController.swift
//  S8Blocker
//
//  Created by virus1994 on 2018/6/21.
//  Copyright © 2018年 ascp. All rights reserved.
//

import Foundation
import WebShell_iOS

class DownloaderController {
    static let share = DownloaderController()
    private let app = UIApplication.shared.delegate as! AppDelegate
    var datas = [DownloadStateInfo]()
    var updateBlock : ((DRecord)->Void)?
    
    init() {
        PCPipeline.share.delegate = self
    }
    
    func remove(record: DRecord) {
        if let index = datas.firstIndex(where: { $0.record == record }) {
            datas.remove(at: index)
            app.managedObjectContext.delete(record)
        }
    }
}

extension DownloaderController : PCPiplineDelegate {
    func pipline(didAddRiffle riffle: PCWebRiffle) {
        
    }
    
    func pipline(didUpdateTask task: PCDownloadTask) {
        update(task: task)
    }
    
    func pipline(didFinishedTask task: PCDownloadTask) {
        finished(task: task)
        app.saveContext()
    }
    
    func pipline(didFinishedRiffle riffle: PCWebRiffle) {
        finished(riffle: riffle)
        app.saveContext()
    }
    
    func add(riffle: PCWebRiffle) {
        let info = DownloadStateInfo(riffle: riffle)
        datas.insert(info, at: 0)
    }
    
    func update(task: PCDownloadTask) {
        if let index = datas.firstIndex(where: { $0.record.uuid == task.request.uuid }) {
            datas[index].record.load(task: task)
            updateBlock?(datas[index].record)
        }
    }
    
    func finished(task: PCDownloadTask) {
        if let index = datas.firstIndex(where: { $0.record.uuid == task.request.uuid }) {
            datas[index].record.load(task: task)
            datas[index].record.endTimeStamp = Date()
            if let _ = datas[index].record.error {
                datas[index].record.status = DownloadStatus.errors.rawValue
            }   else    {
                datas[index].record.status = DownloadStatus.downloaded.rawValue
                datas[index].record.progress = 1.0
            }
            updateBlock?(datas[index].record)
        }
    }
    
    func finished(riffle: PCWebRiffle) {
        if let index = datas.firstIndex(where: { $0.record.uuid == riffle.uuid }) {
            datas[index].record.status = DownloadStatus.errors.rawValue
            updateBlock?(datas[index].record)
        }
    }
}

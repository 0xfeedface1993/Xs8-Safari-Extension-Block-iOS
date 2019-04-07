//
//  Storage.swift
//  S8Blocker
//
//  Created by virus1994 on 2018/5/27.
//  Copyright © 2018年 ascp. All rights reserved.
//

import UIKit
import CloudKit

enum RecordType : String {
    case ndMovie = "NDMoive"
}

typealias SaveCompletion = (CKRecord?, Error?) -> Void
typealias ValidateCompletion = (CKAccountStatus, Error?) -> Void
typealias QueryCompletion = (CKQueryOperation.Cursor?, Error?) -> Void
typealias FetchRecordCompletion = (NetDiskModal) -> Void

protocol CloudSaver {
    
}

extension CloudSaver {
    /// 复制私有区域数据到公共区域
    ///
    /// - Parameter cursor: 若为nil。则说明是开始，否则是获取下一个batch
    func copyPrivateToPublic(cursor: CKQueryOperation.Cursor?) {
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        let query = CKQuery(recordType: RecordType.ndMovie.rawValue, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let operation = cursor == nil ? CKQueryOperation(query: query):CKQueryOperation(cursor: cursor!)
        operation.recordFetchedBlock = { (record) in
            let newRecord = CKRecord(recordType: record.recordType)
            newRecord.load(record: record)
            let publicDatabase = container.publicCloudDatabase
            publicDatabase.save(newRecord, completionHandler: { (recc, errr) in
                if let e = errr {
                    print(e)
                    return
                }
                print("Save OK \(recc!.recordID)")
            })
        }
        operation.queryCompletionBlock = { (records, err) in
            if let e = err {
                print(e)
                return
            }
            self.copyPrivateToPublic(cursor: records)
        }
        privateDatabase.add(operation)
    }
    
    /// 保存记录
    ///
    /// - Parameters:
    ///   - netDisk: 网盘数据模型
    ///   - completion: 执行回调
    func save(netDisk: NetDiskModal, completion: SaveCompletion?) {
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        let record = CKRecord(recordType: RecordType.ndMovie.rawValue)
        record.load(netDisk: netDisk)
        if let completion = completion {
            privateDatabase.save(record, completionHandler: completion)
        }   else    {
            privateDatabase.save(record) { (_, _) in
                
            }
        }
    }
    
    /// 查询所有网盘数据
    ///
    /// - Parameters:
    ///   - fetchBlock: 获取到一条记录回调
    ///   - completion: 获取请求完成回调
    ///   - site: 指定的版块
    func queryAllMovies(fetchBlock: FetchRecordCompletion?, completion: QueryCompletion?, site: String, keyword: String) {
        let container = CKContainer.default()
        let privateCloudDatabase = container.privateCloudDatabase
        var predicate: NSPredicate!
        if !keyword.isEmpty {
            let string = "boradType == %@ AND self contains %@"
            let args = [site, keyword]
            predicate = NSPredicate(format: string, argumentArray: args)
        }   else    {
            predicate = NSPredicate(format: "boradType == %@", site)
        }
        let query = CKQuery(recordType: RecordType.ndMovie.rawValue, predicate: predicate)
        if keyword.isEmpty {
            query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        }
        
        let operation = CKQueryOperation(query: query)
        if keyword.isEmpty {
            operation.resultsLimit = 50
        }
        
        operation.recordFetchedBlock = { rd in
            fetchBlock?(rd.convertModal())
        }
        operation.queryCompletionBlock = { (cursor, err) in
            completion?(cursor, err)
        }
        privateCloudDatabase.add(operation)
    }
    
    /// 获取下一页网盘数据
    ///
    /// - Parameters:
    ///   - cursor: 上一页的位置指示
    ///   - fetchBlock: 获取一条记录的回调
    ///   - completion: 获取请求完成回调
    func queryNextPageMovies(cursor: CKQueryOperation.Cursor, fetchBlock: FetchRecordCompletion?, completion: QueryCompletion?) {
        let container = CKContainer.default()
        let privateCloudDatabase = container.privateCloudDatabase
        let operation = CKQueryOperation(cursor: cursor)
        operation.recordFetchedBlock = { rd in
            fetchBlock?(rd.convertModal())
        }
        operation.queryCompletionBlock = { (csr, err) in
            completion?(csr, err)
        }
        privateCloudDatabase.add(operation)
    }
    
    /// 将公有库中所有记录修改为指定版块
    ///
    /// - Parameters:
    ///   - boardType: 指定版块
    ///   - cursor: 上一个batch
    func add(boardType: String, cursor: CKQueryOperation.Cursor?) {
        let container = CKContainer.default()
        let query = CKQuery(recordType: RecordType.ndMovie.rawValue, predicate: NSPredicate(value: true))
        let operation = cursor == nil ? CKQueryOperation(query: query):CKQueryOperation(cursor: cursor!)
        let publicDatabase = container.publicCloudDatabase
        operation.recordFetchedBlock = { (record) in
            record["boradType"] = boardType as NSString as CKRecordValue
            publicDatabase.save(record, completionHandler: { (recc, errr) in
                if let e = errr {
                    print(e)
                    return
                }
                print("Save OK \(recc!.recordID)")
            })
        }
        operation.queryCompletionBlock = { csr, err in
            if let e = err {
                print(e)
                return
            }
            if let csr = csr {
                self.add(boardType: boardType, cursor: csr)
            }
        }
        publicDatabase.add(operation)
    }
    
    /// 清空数据库内网盘记录
    ///
    /// - Parameter database: 数据库类型（私有、公有)
    func empty(database: CKDatabase) {
        let query = CKQuery(recordType: RecordType.ndMovie.rawValue, predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { rd in
            database.delete(withRecordID: rd.recordID, completionHandler: { (id, err) in
                if let e = err {
                    print(e)
                    return
                }
                print("Delete OK \(id!)")
            })
        }
        operation.queryCompletionBlock = { (cursor, err) in
           print("Fetch finished!")
        }
        database.add(operation)
    }
    
    /// 收藏喜欢的帖子
    ///
    /// - Parameter favoriteModal: 网盘数据模型
    func flep(favoriteModal: NetDiskModal) {
        let container = CKContainer.default()
        let database = container.privateCloudDatabase
        func saveData(rec: CKRecord) {
            database.save(rec) { (recc, err) in
                if let e = err {
                    print(e)
                    return
                }
                print("Save OK \(String(describing: recc?.recordID))")
            }
        }
        
        guard let queryID = favoriteModal.recordID else {
            let record = CKRecord(recordType: RecordType.ndMovie.rawValue)
            record.load(netDisk: favoriteModal)
            record["favorite"] = NSNumber(value: favoriteModal.favorite)
            saveData(rec: record)
            return
        }
        
        let record = CKRecord(recordType: RecordType.ndMovie.rawValue, recordID: queryID)
        database.fetch(withRecordID: queryID) { (rec, err) in
            if let e = err {
                print(e)
                record["favorite"] = NSNumber(value: favoriteModal.favorite)
                record.load(netDisk: favoriteModal)
                saveData(rec: record)
                return
            }
            guard let rec = rec else {
                record["favorite"] = NSNumber(value: favoriteModal.favorite)
                record.load(netDisk: favoriteModal)
                saveData(rec: record)
                return
            }
            rec["favorite"] = NSNumber(value: favoriteModal.favorite)
            saveData(rec: rec)
        }
    }
    
    func check(favoriteModal: NetDiskModal, fetchBlock: FetchRecordCompletion?, completion: (()->Void)?) {
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        
        if let id = favoriteModal.recordID {
            privateDatabase.fetch(withRecordID: id) { (rec, err) in
                if let e = err {
                    print(e)
                    return
                }
                guard let rec = rec else {
                    return
                }
                fetchBlock?(rec.convertModal())
                completion?()
            }
        }   else    {
            let predict = NSPredicate(format: "title == %@", favoriteModal.title)
            let query = CKQuery(recordType: RecordType.ndMovie.rawValue, predicate: predict)
            let operation = CKQueryOperation(query: query)
            operation.recordFetchedBlock = { rd in
                fetchBlock?(rd.convertModal())
            }
            operation.completionBlock = completion
            privateDatabase.add(operation)
        }
    }
    
    // 查询收藏的页面
    func query(favoriteSite: String, keyword: String, fetchBlock: FetchRecordCompletion?, completion: QueryCompletion?) {
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        var predicate: NSPredicate!
        if !keyword.isEmpty {
            let string = "boradType == %@ AND favorite > 0 AND self contains %@"
            let args = [favoriteSite, keyword]
            predicate = NSPredicate(format: string, argumentArray: args)
        }   else    {
            predicate = NSPredicate(format: "boradType == %@ AND favorite > 0", favoriteSite)
        }
        let query = CKQuery(recordType: RecordType.ndMovie.rawValue, predicate: predicate)
        if keyword.isEmpty {
            query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        }
        
        let operation = CKQueryOperation(query: query)
        if keyword.isEmpty {
            operation.resultsLimit = 50
        }
        
        operation.recordFetchedBlock = { rd in
            fetchBlock?(rd.convertModal())
        }
        operation.queryCompletionBlock = { (cursor, err) in
            completion?(cursor, err)
        }
        privateDatabase.add(operation)
    }
    
    func next(favoriteCursor: CKQueryOperation.Cursor, fetchBlock: FetchRecordCompletion?, completion: QueryCompletion?) {
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        let operation = CKQueryOperation(cursor: favoriteCursor)
        operation.recordFetchedBlock = { rd in
            fetchBlock?(rd.convertModal())
        }
        operation.queryCompletionBlock = { (csr, err) in
            completion?(csr, err)
        }
        privateDatabase.add(operation)
    }
}


// MARK: - 模型和记录实例之间转换
extension CKRecord {
    /// 载入网盘信息到当前记录
    ///
    /// - Parameter netDisk: 网盘数据模型
    func load(netDisk: NetDiskModal) {
        self["title"]  = netDisk.title as NSString
        self["href"]  = netDisk.href as NSString
        self["password"]  = netDisk.password as NSString
        self["fileSize"]  = netDisk.fileSize as NSString
        self["downloads"]  = netDisk.downloads.map({ $0 as NSString }) as CKRecordValue
        self["images"]  = netDisk.images.map({ $0 as NSString }) as CKRecordValue
        self["boradType"] = netDisk.boradType as NSString
        self["favorite"] = NSNumber(value: netDisk.favorite)
    }
    
    /// 复制记录实例到自身
    ///
    /// - Parameter record: 需要复制的记录
    func load(record: CKRecord) {
        self["title"] = record["title"]
        self["href"] = record["href"]
        self["fileSize"] = record["fileSize"]
        self["password"] = record["password"]
        self["downloads"] = record["downloads"]
        self["images"] = record["images"]
        self["boradType"] = record["boradType"]
        self["favorite"] = record["favorite"]
    }
    
    /// 记录失恋转换成网盘数据模型
    ///
    /// - Returns: 网盘数据模型
    func convertModal() -> NetDiskModal {
        var modal = NetDiskModal()
        modal.recordID = self.recordID
        modal.title = self["title"] as? String ?? ""
        modal.href = self["href"] as? String ?? ""
        modal.fileSize = self["fileSize"] as? String ?? ""
        modal.password = self["password"] as? String ?? ""
        modal.downloads = self["downloads"] as? [String] ?? []
        modal.images = self["images"] as? [String] ?? []
        modal.boradType = self["boradType"] as? String ?? ""
        modal.favorite = (self["favorite"] as? NSNumber)?.intValue ?? 0
        return modal
    }
}

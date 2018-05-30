//
//  Storage.swift
//  S8Blocker
//
//  Created by virus1994 on 2018/5/27.
//  Copyright © 2018年 ascp. All rights reserved.
//

import UIKit
import CloudKit

//downloads
//fileSize
//format
//href
//images
//password
//title
//recordName

typealias SaveCompletion = (CKRecord?, Error?) -> Void
typealias ValidateCompletion = (CKAccountStatus, Error?) -> Void
typealias QueryCompletion = (CKQueryCursor?, Error?) -> Void
typealias FetchRecordCompletion = (NetDiskModal) -> Void

protocol CloudSaver {
    
}

extension CloudSaver {
    func copyPrivateToPublic(cursor: CKQueryCursor?) {
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        let query = CKQuery(recordType: "NDMoive", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let operation = cursor == nil ? CKQueryOperation(query: query):CKQueryOperation(cursor: cursor!)
        operation.recordFetchedBlock = { (record) in
            let newRecord = CKRecord(recordType: record.recordType)
            newRecord["title"] = record["title"]
            newRecord["href"] = record["href"]
            newRecord["fileSize"] = record["fileSize"]
            newRecord["password"] = record["password"]
            newRecord["downloads"] = record["downloads"]
            newRecord["images"] = record["images"]
            newRecord["boradType"] = record["boradType"]
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
    
    func save(netDisk: NetDiskModal, completion: @escaping SaveCompletion) {
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        let record = CKRecord(recordType: "NDMoive")
        record["title"]  = netDisk.title as NSString
        record["href"]  = netDisk.href as NSString
        record["password"]  = netDisk.password as NSString
        record["fileSize"]  = netDisk.fileSize as NSString
        record["downloads"]  = netDisk.downloads.map({ $0 as NSString }) as CKRecordValue
        record["images"]  = netDisk.images.map({ $0 as NSString }) as CKRecordValue
        record["boradType"] = netDisk.boradType as NSString
        privateDatabase.save(record, completionHandler: completion)
    }
    
    func queryAllMovies(fetchBlock: @escaping FetchRecordCompletion, completion: @escaping QueryCompletion, site: String) {
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        let predicate = NSPredicate(format: "boradType = %@", site)
        let query = CKQuery(recordType: "NDMoive", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { rd in
            var modal = NetDiskModal()
            modal.title = rd["title"] as! String
            modal.href = rd["href"] as! String
            modal.fileSize = rd["fileSize"] as! String
            modal.password = rd["password"] as! String
            modal.downloads = rd["downloads"] as! [String]
            modal.images = rd["images"] as! [String]
            modal.boradType = rd["boradType"] as! String
            fetchBlock(modal)
        }
        operation.queryCompletionBlock = { (cursor, err) in
            completion(cursor, err)
        }
        publicDatabase.add(operation)
    }
    
    func queryNextPageMovies(cursor: CKQueryCursor, fetchBlock: @escaping FetchRecordCompletion, completion: @escaping QueryCompletion) {
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        let operation = CKQueryOperation(cursor: cursor)
        operation.recordFetchedBlock = { rd in
            var modal = NetDiskModal()
            modal.title = rd["title"] as! String
            modal.href = rd["href"] as! String
            modal.fileSize = rd["fileSize"] as! String
            modal.password = rd["password"] as! String
            modal.downloads = rd["downloads"] as! [String]
            modal.images = rd["images"] as! [String]
            modal.boradType = rd["boradType"] as! String
            fetchBlock(modal)
        }
        operation.queryCompletionBlock = { (csr, err) in
            completion(csr, err)
        }
        publicDatabase.add(operation)
    }
    
    func add(boardType: String, cursor: CKQueryCursor?) {
        let container = CKContainer.default()
        let query = CKQuery(recordType: "NDMoive", predicate: NSPredicate(value: true))
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
    
    func empty(database: CKDatabase) {
        let query = CKQuery(recordType: "NDMoive", predicate: NSPredicate(value: true))
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
}

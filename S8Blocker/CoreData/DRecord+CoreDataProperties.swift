//
//  DRecord+CoreDataProperties.swift
//  S8Blocker
//
//  Created by virus1994 on 2018/6/20.
//  Copyright © 2018年 ascp. All rights reserved.
//
//

import UIKit
import CoreData


extension DRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DRecord> {
        return NSFetchRequest<DRecord>(entityName: "DRecord")
    }

    @NSManaged public var uuid: UUID
    @NSManaged public var name: String?
    @NSManaged public var progress: Float
    @NSManaged public var totalBytes: Float
    @NSManaged public var status: String
    @NSManaged public var url: URL?
    @NSManaged public var stateColor: UIColor
    @NSManaged public var state: String?
    @NSManaged public var siteIcon: UIImage?
    @NSManaged public var isHiddenPrograss: Bool
    @NSManaged public var isCanRestart: Bool
    @NSManaged public var isCanCancel: Bool
    @NSManaged public var isFacorite: Bool
    @NSManaged public var movie: Movie?
    @NSManaged public var hostType: Int
    @NSManaged public var startTimeStamp: Date
    @NSManaged public var endTimeStamp: Date?
    @NSManaged public var remoteFileURL: URL?
    @NSManaged public var error: String?
    @NSManaged public var password: String?
}

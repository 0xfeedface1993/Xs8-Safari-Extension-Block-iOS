//
//  RemoteDownloader.swift
//  S8Blocker
//
//  Created by virus1994 on 2019/4/4.
//  Copyright © 2019 ascp. All rights reserved.
//

import Foundation

protocol RemoteDownloader {
    
}

extension RemoteDownloader {
    func download(file: NetDiskModal, downloadLink: String) {
        let request = NotifyAddRequest(format: "", title: file.title, msk: "", pageurl: file.href, passwod: file.password, size: file.fileSize, time: "", downloadLink: downloadLink, links: file.downloads, pics: file.images)
        let caller = WebserviceCaller<APIResponse<[String:String]>, NotifyAddRequest>(url: .debug, way: .post, method: .addDownload)
        caller.paras = request
        caller.execute = { (data, err, res) in
            if let _ = err {
                return
            }
            
            guard let json = data else {
                print(">>>>>>>>>>>> Empty Data <<<<<<<<<<<<<<")
                return
            }
            
            guard json.code == 200 else {
                print(">>>>>>>>>>>> Error Code: \(json.code), \(json.msg) <<<<<<<<<<<<<<")
                return
            }
            
            guard let inner = json.data else {
                print(">>>>>>>>>>>> Inner Data Empty <<<<<<<<<<<<<<")
                return
            }
            
            print(inner)
        }
        try? Webservice.share.read(caller: caller)
    }
}

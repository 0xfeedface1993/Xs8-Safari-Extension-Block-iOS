//
//  DownloaderTableViewController.swift
//  S8Blocker
//
//  Created by virus1994 on 2018/6/19.
//  Copyright © 2018年 ascp. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData
import WebShell_iOS

class DownloaderTableViewController: UITableViewController {
    let cellIdenitfier = "com.ascp.downloader.cell"
    var datas : [DownloadStateInfo] { return firmData }
    var dynamicData = [DownloadStateInfo]()
    private let document = UIDocumentInteractionController()
    private var firmData = [DownloadStateInfo]()
    var fileList: [String] {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first else {
            print("<<<<<<<<<<<<<<<<<<< DocumentDirectory Not Found! >>>>>>>>>>>>>>>>>>>>")
            return []
        }
        do {
            let list = try FileManager.default.contentsOfDirectory(atPath: url.path)
            return list
        } catch {
            print(error)
            return []
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.register(UINib(nibName: "DownloaderTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdenitfier)
        loadData()
//        DRecord.deleteAllRecord()
        
        let controller = DownloaderController.share
        dynamicData = controller.datas
        
        controller.updateBlock = { [weak self] (record) in
            self?.dynamicData = controller.datas
            if let index = self?.datas.firstIndex(where: { record == $0.record }) {
                DispatchQueue.main.async {
                    let indexPath = IndexPath(row: index, section: 0)
                    if self?.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                        (self?.tableView.cellForRow(at: indexPath) as! DownloaderTableViewCell).load(newInfo: self!.datas[index])
                    }
                }
            }
        }
        
        let barItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.trash, target: self, action: #selector(deleteAllFile))
        navigationItem.rightBarButtonItem = barItem
        
        UNUserNotificationCenter.current().requestAuthorization(options: UNAuthorizationOptions.alert.union(.sound)) { (flag, err) in
            if let e = err {
                DispatchQueue.main.async {
                    print(e)
                    let alert = UIAlertController(title: "推送已关闭", message: "您将需要手动进入app继续下载任务", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "确定", style: .cancel, handler: { (_) in
                        alert.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(cancel)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            if flag {
                
            }
        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdenitfier, for: indexPath) as! DownloaderTableViewCell

        // Configure the cell...
        
        cell.load(newInfo: datas[indexPath.row])
        cell.restartAction = { info in
            print("restart action")
            
            if let riffle = PCPipeline.share.add(url: info.record.url!.absoluteString, password: info.record.movie?.password ?? "") {
                DownloaderController.share.remove(record: info.record)
                if let index = self.firmData.firstIndex(where: { $0.record == info.record }) {
                    let indexPath = IndexPath(row: index, section: 0)
                    if self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                        self.tableView.reloadRows(at: [indexPath], with: .left)
                    }
                    let app = UIApplication.shared.delegate as! AppDelegate
                    app.managedObjectContext.delete(info.record)
                }
                DownloaderController.share.add(riffle: riffle)
                
            }
            
            self.loadData()
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let fileURL = datas[indexPath.row].record.localFileURL else {
            print("************ file NOT EXSIT! *************")
            return
        }
        document.url = fileURL
        document.presentOpenInMenu(from: tableView.cellForRow(at: indexPath)!.frame, in: view, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DownloaderTableViewController {
     func loadData() {
        DownloaderTableViewController.read { (records, error) in
            print(fileList)
            if let e = error {
                let alert = UIAlertController(title: "数据读取失败", message: e.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                let top = navigationController?.viewControllers.first
                top?.present(alert, animated: true, completion: nil)
                return
            }
            firmData = records.map({ DownloadStateInfo(record: $0) })
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.tableView.reloadData()
//                self.deleteAllFile()
            }
            
        }
    }
    
    static func read(completion: ([DRecord], Error?) -> Void) {
        // 获取任务，任务都存储在数据库中，根据开始下载时间排序
        do {
            let request = NSFetchRequest<DRecord>(entityName: "DRecord")
            request.predicate = NSPredicate(value: true)
            let app = UIApplication.shared.delegate as! AppDelegate
            var records = try app.managedObjectContext.fetch(request)
            records.sort(by: { $0.startTimeStamp > $1.startTimeStamp })
            PCDownloadManager.share.loadBackgroundTask { (tasks) -> [(task: URLSessionDownloadTask, url: URL, remoteURL: URL, uuid: UUID)] in
                let backgroundTask = tasks.map({ task -> (task: URLSessionDownloadTask, url: URL, remoteURL: URL, uuid: UUID)? in
                    if let rkr = task.response?.url?.absoluteString, let t = records.first(where: { $0.remoteFileURL?.absoluteString == rkr  }) {
                        return (task: task, url: t.url!, remoteURL: t.remoteFileURL!, uuid: t.uuid)
                    }
                    return nil
                }).filter({ $0 != nil }).map({ $0! })
                print(backgroundTask)
                return backgroundTask
            }
            completion(records, nil)
        } catch {
            print(error)
            completion([], error)
        }
    }
    
    @objc func deleteAllFile() {
        let alert = UIAlertController(title: "警告", message: "所有已下载文件会被删除", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: { _ in
            guard let url = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first else {
                print("<<<<<<<<<<<<<<<<<<< DocumentDirectory Not Found! >>>>>>>>>>>>>>>>>>>>")
                return
            }
            do {
                for item in self.fileList {
                    try FileManager.default.removeItem(atPath: url.appendingPathComponent(item).path)
                }
            } catch {
                print(error)
            }
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
        let top = navigationController?.viewControllers.first
        top?.present(alert, animated: true, completion: nil)
    }
}

//
//  DownloaderTableViewController.swift
//  S8Blocker
//
//  Created by virus1994 on 2018/6/19.
//  Copyright © 2018年 ascp. All rights reserved.
//

import UIKit
import CoreData
import WebShell_iOS

class DownloaderTableViewController: UITableViewController {
    let cellIdenitfier = "com.ascp.downloader.cell"
    var datas : [DownloadStateInfo] { return firmData }
    var dynamicData = [DownloadStateInfo]()
    private var firmData = [DownloadStateInfo]()
    
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
        let app = UIApplication.shared.delegate as! AppDelegate
        
        // 获取任务，任务都存储在数据库中，根据开始下载时间排序
        do {
            let request = NSFetchRequest<DRecord>(entityName: "DRecord")
            request.predicate = NSPredicate(value: true)
            var records = try app.managedObjectContext.fetch(request)
            records.sort(by: { $0.startTimeStamp > $1.startTimeStamp })
            firmData.removeAll()
            records.forEach({ firmData.append(DownloadStateInfo(record: $0)) })
            
            PCDownloadManager.share.loadBackgroundTask { (tasks) -> [(task: URLSessionDownloadTask, url: URL, remoteURL: URL, uuid: UUID)] in
                return tasks.map({ task -> (task: URLSessionDownloadTask, url: URL, remoteURL: URL, uuid: UUID)? in
                    if let t = records.first(where: { $0.remoteFileURL == task.response!.url!  }) {
                        return (task: task, url: t.url!, remoteURL: t.remoteFileURL!, uuid: t.uuid)
                    }
                    return nil
                }).filter({ $0 != nil }).map({ $0! })
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.tableView.reloadData()
            }
//            records.forEach({ app.managedObjectContext.delete($0) })
//            app.saveContext()
        } catch {
            print(error)
            let alert = UIAlertController(title: "数据读取失败", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            let top = navigationController?.viewControllers.first
            top?.present(alert, animated: true, completion: nil)
        }
    }
}

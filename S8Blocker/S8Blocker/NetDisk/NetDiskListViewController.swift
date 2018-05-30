//
//  NetDiskListViewController.swift
//  Sex8BlockExtension-iOS
//
//  Created by virus1993 on 2017/8/17.
//  Copyright © 2017年 ascp. All rights reserved.
//

import UIKit
import WebKit
import CloudKit

enum SitePlace {
    case login
    case main
    case netdisk
    case page
}

class NetDiskListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    fileprivate var data = [NetDiskModal]()
    var isRefreshing = false
    var page = 1 {
        didSet {
            let bot = FetchBot.shareBot
            bot.startPage = UInt(page)
        }
    }
    
    var site = Site.netdisk
    var isCloudDataSource = true
    var cursor : CKQueryCursor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = site.categrory?.name
        // Do any additional setup after loading the view.
        
        tableviewLoad()
//        copyPrivateToPublic(cursor: nil)
//        add(boardType: site.categrory!.site, cursor: nil)
//        empty(database: CKContainer.default().publicCloudDatabase)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParentViewController {
            FetchBot.shareBot.stop {
                print("------------ Stop All Download Task -----------")
            }
        }
    }
    
    deinit {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentOffset = scrollView.contentOffset.y
        let distance = scrollView.contentSize.height - contentOffset
        if distance < height, contentOffset > 0, isRefreshing == false {
            print("load next page tableview!")
            isRefreshing = true
//            page += 1
//            DispatchQueue.global().async {
//                FetchBot.shareBot.start(withSite: self.site)
//            }
            if let cursor = self.cursor {
                self.queryNextPageMovies(cursor: cursor, fetchBlock: { modal in
                    if let _ = self.data.index(where: { $0.href == modal.href }) {
                        print("Last Page!")
                        return
                    }
                    self.data.append(modal)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }) { (cusor, err) in
                    self.cursor = cusor
                    if let e = err {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "读取失败", message: e.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                    self.isRefreshing = false
                }
            }
            print("++++++ end of bottom ********")
        }
    }
}


// MARK: - UITableViewDataSource, UITableViewDelegate
extension NetDiskListViewController : UITableViewDataSource, UITableViewDelegate {
    func tableviewLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "NetDiskTableViewCell", bundle: nil), forCellReuseIdentifier: NetDiskTableViewCellIdentifier)
        fetch()
//        let bot = FetchBot.shareBot
//        bot.startPage = 1
//        bot.pageOffset = 100
//        bot.delegate = self
//        DispatchQueue.global().async {
//            bot.start(withSite: self.site)
//        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NetDiskTableViewCellIdentifier, for: indexPath) as! NetDiskTableViewCell
        cell.loadData(data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Sex8", bundle: nil)
        let v = storyboard.instantiateViewController(withIdentifier: "NetDiskDetail") as! NetDiskDetailViewController
        v.netdisk = data[indexPath.row]
        navigationController?.pushViewController(v, animated: true)
    }
}

// MARK: - FetchBot Delegate
extension NetDiskListViewController: FetchBotDelegate {
    func bot(_ bot: FetchBot, didLoardContent content: ContentInfo, atIndexPath index: Int) {
        let netDisk = NetDiskModal(content: content, boradType: site.categrory?.site ?? "")
        data.append(netDisk)
        save(netDisk: netDisk) { (rec, err) in
            if let e = err {
                print("************* Save \(netDisk.title) to cloud Failed: \(e.localizedDescription)")
                return
            }
            
            if let record = rec {
                print("Save to cloud Ok: \(record.recordID)")
            }
        }
//        DispatchQueue.main.async {
//            [unowned self] in
//            self.tableView.reloadData()
//        }
    }
    
    func bot(didStartBot bot: FetchBot) {
        
    }
    
    func bot(_ bot: FetchBot, didFinishedContents contents: [ContentInfo], failedLink: [FetchURL]) {
        self.isRefreshing = false
    }
    
    
}

// MARK: - Cloud Datebase
extension NetDiskListViewController: CloudSaver {
    func fetch() {
        CKContainer.default().accountStatus { (status, err) in
            if let e = err {
                self.isCloudDataSource = false
                let bot = FetchBot.shareBot
                bot.startPage = 1
                bot.pageOffset = 1
                bot.delegate = self
                DispatchQueue.global().async {
                    bot.start(withSite: self.site)
                }
                print("iCloud not working: \(e.localizedDescription)")
                print("------------ Using AutoFetch now!")
                return
            }
            
            self.isCloudDataSource = true
            self.queryAllMovies(fetchBlock: { modal in
                self.data.append(modal)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }, completion: { (results, err) in
                self.cursor = results
                if let e = err {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "读取失败", message: e.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    return
                }
            }, site: self.site.categrory?.site ?? "")
        }
        
    }
}

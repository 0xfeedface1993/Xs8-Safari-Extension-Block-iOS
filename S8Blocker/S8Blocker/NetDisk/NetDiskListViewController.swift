//
//  NetDiskListViewController.swift
//  Sex8BlockExtension-iOS
//
//  Created by virus1993 on 2017/8/17.
//  Copyright © 2017年 ascp. All rights reserved.
//

import UIKit
import WebKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "网盘下载"
        let bot = FetchBot.shareBot
        bot.startPage = 1
        bot.pageOffset = 1
        bot.delegate = self
        DispatchQueue.global().async {
            bot.start(withSite: .netdisk)
        }
        // Do any additional setup after loading the view.
        tableviewLoad()
    }
    
    deinit {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 &&  isRefreshing == false {
            print("load next page tableview!")
            isRefreshing = true
            page += 1
            DispatchQueue.global().async {
                FetchBot.shareBot.start(withSite: .netdisk)
                self.isRefreshing = false
            }
        }
    }
}


// MARK: - UITableViewDataSource, UITableViewDelegate
extension NetDiskListViewController : UITableViewDataSource, UITableViewDelegate {
    func tableviewLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "NetDiskTableViewCell", bundle: nil), forCellReuseIdentifier: NetDiskTableViewCellIdentifier)
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
        let netDisk = NetDiskModal(content: content)
        data.append(netDisk)
        DispatchQueue.main.async {
            [unowned self] in
            self.tableView.reloadData()
        }
    }
    
    func bot(didStartBot bot: FetchBot) {
        
    }
    
    func bot(_ bot: FetchBot, didFinishedContents contents: [ContentInfo], failedLink: [FetchURL]) {
        
    }
    
    
}

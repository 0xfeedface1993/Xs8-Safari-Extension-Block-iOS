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

struct NetCell {
    var modal : NetDiskModal
    var previewImages : [ImageItem]
    
    init(modal: NetDiskModal) {
        self.modal = modal
        self.previewImages = modal.images.map({ ImageItem(url: URL(string: $0), state: .wait, size: #imageLiteral(resourceName: "NetDisk").size) })
    }
}

class NetDiskListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    fileprivate var data = [NetCell]()
    fileprivate var backupData = [NetCell]()
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
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = site.categrory?.name
        // Do any additional setup after loading the view.
        
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "帖子名称"
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        tableviewLoad()
        
        definesPresentationContext = true
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = true
            navigationItem.largeTitleDisplayMode = .automatic
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
            tableView.tableHeaderView = searchController.searchBar
        }
        
        let collect = UIBarButtonItem(image: #imageLiteral(resourceName: "Unlike"), style: .done, target: self, action: #selector(switchDataSource(sender:)))
        navigationItem.rightBarButtonItem = collect
        
//        copyPrivateToPublic(cursor: nil)
//        add(boardType: site.categrory!.site, cursor: nil)
//        empty(database: CKContainer.default().privateCloudDatabase)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParentViewController {
            FetchBot.shareBot.stop {
                print("------------ Stop All Download Task -----------")
            }
        }   else    {
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.searchController.isActive {
            return
        }
        let height = scrollView.frame.size.height
        let contentOffset = scrollView.contentOffset.y
        let distance = scrollView.contentSize.height - contentOffset
        if distance < height, contentOffset > 0, isRefreshing == false {
            print("load next page tableview!")
            isRefreshing = true
            if !isCloudDataSource {
                page += 1
                DispatchQueue.global().async {
                    FetchBot.shareBot.start(withSite: self.site)
                }
                return
            }
            if let cursor = self.cursor {
                self.queryNextPageMovies(cursor: cursor, fetchBlock: { modal in
                    if let _ = self.data.index(where: { $0.modal.href == modal.href }) {
                        print("Last Page!")
                        return
                    }
                    self.data.append(NetCell(modal: modal))
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
    
    @objc func switchDataSource(sender: UIBarButtonItem) {
        let second = NetDiskFavoriteViewController()
        second.site = site
        let navi = UINavigationController(rootViewController: second)
        let presentationController = CustomPresentViewController(presentedViewController: navi, presenting: self)
        navi.transitioningDelegate = presentationController
        present(navi, animated: true, completion: nil)
    }
}


// MARK: - UITableViewDataSource, UITableViewDelegate
extension NetDiskListViewController : UITableViewDataSource, UITableViewDelegate {
    func tableviewLoad() {
        if  tableView == nil {
            return
        }
//        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "NetDiskTableViewCell", bundle: nil), forCellReuseIdentifier: NetDiskTableViewCellIdentifier)
        fetch(keyword: "")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NetDiskTableViewCellIdentifier, for: indexPath) as! NetDiskTableViewCell
        cell.loadData(data[indexPath.row].modal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Sex8", bundle: nil)
        searchController.searchBar.resignFirstResponder()
        let v = storyboard.instantiateViewController(withIdentifier: "NetDiskDetail") as! NetDiskDetailViewController
        v.netdisk = data[indexPath.row].modal
        navigationController?.pushViewController(v, animated: true)
    }
}

// MARK: - FetchBot Delegate
extension NetDiskListViewController: FetchBotDelegate {
    func bot(_ bot: FetchBot, didLoardContent content: ContentInfo, atIndexPath index: Int) {
        let netDisk = NetDiskModal(content: content, boradType: site.categrory?.site ?? "")
        
        if isCloudDataSource {
            save(netDisk: netDisk) { (rec, err) in
                if let e = err {
                    print("************* Save \(netDisk.title) to cloud Failed: \(e.localizedDescription)")
                    return
                }

                if let record = rec {
                    print("Save to cloud Ok: \(record.recordID)")
                }
            }
        }   else    {
            DispatchQueue.main.async {
                [unowned self] in
                if self.searchController.isActive {
                    self.backupData.append(NetCell(modal: netDisk))
                }   else    {
                    self.data.append(NetCell(modal: netDisk))
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func bot(didStartBot bot: FetchBot) {
        
    }
    
    func bot(_ bot: FetchBot, didFinishedContents contents: [ContentInfo], failedLink: [FetchURL]) {
        self.isRefreshing = false
    }
}

// MARK: - Cloud Datebase
extension NetDiskListViewController: CloudSaver {
    func fetch(keyword: String) {
        CKContainer.default().accountStatus { (status, err) in
            if let e = err {
                self.isCloudDataSource = false
                let bot = FetchBot.shareBot
                bot.delegate = self
                bot.pageOffset = 1
                DispatchQueue.global().async {
                    bot.start(withSite: self.site)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                print(e)
                return
            }

            if !keyword.isEmpty {
                self.data.removeAll()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }

            self.isCloudDataSource = true
            self.queryAllMovies(fetchBlock: { modal in
                self.data.append(NetCell(modal: modal))
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }, completion: { (results, err) in
                self.cursor = results
                if let e = err {
                    print(e)
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "读取失败", message: e.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    return
                }
            }, site: self.site.categrory?.site ?? "", keyword: keyword)
        }
    }
}

extension NetDiskListViewController : UISearchControllerDelegate, UISearchResultsUpdating {
    func willPresentSearchController(_ searchController: UISearchController) {
        backupData = data
        searchController.searchBar.showsCancelButton = true
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        data = backupData
        searchController.searchBar.showsCancelButton = false
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let keyword = self.searchController.searchBar.text, !keyword.isEmpty else {
            return
        }
        
        if isCloudDataSource {
            fetch(keyword: keyword)
        }   else    {
            data = backupData.filter({ $0.modal.title.contains(keyword) })
            tableView.reloadData()
        }
    }
}

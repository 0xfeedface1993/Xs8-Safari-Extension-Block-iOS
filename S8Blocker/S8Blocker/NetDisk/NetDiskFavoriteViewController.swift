//
//  NetDiskFavoriteViewController.swift
//  S8Blocker
//
//  Created by virus1994 on 2018/6/10.
//  Copyright © 2018年 ascp. All rights reserved.
//

import UIKit
import CloudKit
import Kingfisher

class NetDiskFavoriteViewController: UIViewController {
    let tableView = UITableView()
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
    var cursor : CKQueryOperation.Cursor?
    
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = site.categrory?.name
        
        view.addSubview(tableView)
        
        tableView.rowHeight = 200 + 24 + 12 + 20
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["table": tableView]
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table]|", options: [], metrics: nil, views: views) + NSLayoutConstraint.constraints(withVisualFormat: "V:|[table]|", options: [], metrics: nil, views: views))
        
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "帖子名称"
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationController?.navigationBar.tintColor = .red
            tableView.contentInsetAdjustmentBehavior = .always
        } else {
            // Fallback on earlier versions
            tableView.tableHeaderView = searchController.searchBar
        }
        
        updatePreferredContentSize(withTraitCollection: traitCollection)

        // Do any additional setup after loading the view.
        let collect = UIBarButtonItem(image: #imageLiteral(resourceName: "Like"), style: .done, target: self, action: #selector(switchDataSource(sender:)))
        navigationItem.rightBarButtonItem = collect
        
        tableviewLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
            navigationItem.largeTitleDisplayMode = .always
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func updatePreferredContentSize(withTraitCollection traitCollection: UITraitCollection) {
        preferredContentSize = view.bounds.size
    }

    @objc func switchDataSource(sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSize(withTraitCollection: traitCollection)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.searchController.isActive {
            return
        }
        let height = scrollView.frame.size.height
        let contentOffset = scrollView.contentOffset.y
        let distance = scrollView.contentSize.height - contentOffset
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .automatic
        } else {
            // Fallback on earlier versions
        }
        if distance < height, contentOffset > 0, isRefreshing == false {
            print("load next page tableview!")
            isRefreshing = true
            if let cursor = self.cursor {
                self.next(favoriteCursor: cursor, fetchBlock: { modal in
                    if let _ = self.data.firstIndex(where: { $0.modal.href == modal.href }) {
                        print("Last Page!")
                        return
                    }
                    self.data.append(NetCell(modal: modal))
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }, completion: { (cusor, err) in
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
                })
            }
            print("++++++ end of bottom ********")
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension NetDiskFavoriteViewController : UITableViewDataSource, UITableViewDelegate {
    func tableviewLoad() {
        tableView.prefetchDataSource = self
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
        for (index, imageView) in cell.previewImages.enumerated() {
            guard let url = data[indexPath.row].previewImages[index].url else {
                self.data[indexPath.row].previewImages[index].state = .error
                imageView.image = UIImage(named: "Bad")
                continue
            }
            switch data[indexPath.row].previewImages[index].state {
            case .wait:
                self.data[indexPath.row].previewImages[index].state = .downloading
                if let cache = ImageCache.default.cacheImage(forUrl: url) {
                    self.data[indexPath.row].previewImages[index].state = .downloaded
                    imageView.image = cache
                    continue
                }
                imageView.image = UIImage(named: "NetDisk")
                ImageDownloader.default.downloadImage(with: url, completionHandler: { (image, error, urlx, data) in
                    guard self.data.count > indexPath.row else {
                        print("****** Data being change ******")
                        return
                    }
                    if let _ = error {
                        DispatchQueue.main.async {
                            self.data[indexPath.row].previewImages[index].state = .error
                            self.data[indexPath.row].previewImages[index].size = #imageLiteral(resourceName: "Failed").size
                            if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                                imageView.image = #imageLiteral(resourceName: "Failed")
                            }
                        }
                        return
                    }
                    if let img = image {
                        ImageCache.default.store(img, forKey: url.absoluteString)
                        DispatchQueue.main.async {
                            self.data[indexPath.row].previewImages[index].state = .downloaded
                            self.data[indexPath.row].previewImages[index].size = img.size
                            if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                                imageView.image = img
                            }
                        }
                    }
                })
                
            case .downloading:
                imageView.image = UIImage(named: "NetDisk")
            case .downloaded:
                imageView.image = ImageCache.default.cacheImage(forUrl: url)
            case .error:
                imageView.image = UIImage(named: "Failed")
            }
        }
        return cell
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 400
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Sex8", bundle: nil)
        let v = storyboard.instantiateViewController(withIdentifier: "NetDiskDetail") as! NetDiskDetailViewController
        v.netdisk = data[indexPath.row].modal
        navigationController?.pushViewController(v, animated: true)
    }
}

extension NetDiskFavoriteViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { (indexPath) in
            guard self.data.count > indexPath.row else {
                print("****** Data being change ******")
                return
            }
            for item in self.data[indexPath.row].previewImages.enumerated() {
                let linkIndex = item.offset
                if item.element.state == .wait {
                    guard let url = item.element.url else {
                        self.data[indexPath.row].previewImages[linkIndex].state = .error
                        continue
                    }
                    self.data[indexPath.row].previewImages[linkIndex].state = .downloading
                    if let cache = ImageCache.default.cacheImage(forUrl: url) {
                        self.data[indexPath.row].previewImages[linkIndex].state = .downloaded
                        DispatchQueue.main.async {
                            if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                                let cell = tableView.cellForRow(at: indexPath) as! NetDiskTableViewCell
                                cell.previewImages[item.offset].image = cache
                            }
                        }
                        continue
                    }
                    ImageDownloader.default.downloadImage(with: url, completionHandler: { (image, error, urlx, data) in
                        guard self.data.count > indexPath.row else {
                            print("****** Data being change ******")
                            return
                        }
                        if let _ = error {
                            self.data[indexPath.row].previewImages[linkIndex].state = .error
                            self.data[indexPath.row].previewImages[linkIndex].size = #imageLiteral(resourceName: "Failed").size
                            DispatchQueue.main.async {
                                if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                                    let cell = tableView.cellForRow(at: indexPath) as! NetDiskTableViewCell
                                    cell.previewImages[item.offset].image = #imageLiteral(resourceName: "Failed")
                                }
                            }
                            return
                        }
                        if let img = image {
                            ImageCache.default.store(img, forKey: url.absoluteString)
                            self.data[indexPath.row].previewImages[linkIndex].state = .downloaded
                            self.data[indexPath.row].previewImages[linkIndex].size = img.size
                            DispatchQueue.main.async {
                                if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                                    let cell = tableView.cellForRow(at: indexPath) as! NetDiskTableViewCell
                                    cell.previewImages[item.offset].image = img
                                }
                            }
                        }
                    })
                }
            }
        }
    }
}

// MARK: - Cloud Datebase
extension NetDiskFavoriteViewController: CloudSaver {
    func fetch(keyword: String) {
        CKContainer.default().accountStatus { (status, err) in
            if let e = err {
                self.isCloudDataSource = false
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
            self.query(favoriteSite: self.site.categrory?.site ?? "", keyword: keyword, fetchBlock: { modal in
                guard modal.title.contains(keyword) else {
                    return
                }
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
            })
        }
        
    }
}

extension NetDiskFavoriteViewController : UISearchControllerDelegate, UISearchResultsUpdating {
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

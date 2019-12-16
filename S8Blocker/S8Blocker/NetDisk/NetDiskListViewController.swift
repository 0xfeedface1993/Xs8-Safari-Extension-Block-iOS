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
import Kingfisher

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
        self.previewImages = [ImageItem]()
        for i in 0...2 {
            var url : URL? = nil
            if i < modal.images.count {
                url = URL(string: modal.images[i])
            }
            self.previewImages.append(ImageItem(url: url, state: .wait, size: #imageLiteral(resourceName: "NetDisk").size))
        }
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
    var cursor : CKQueryOperation.Cursor?
    
    let searchController = UISearchController(searchResultsController: nil)
    var caching = [IndexPath:CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = site.categrory?.name
        tableView.separatorStyle = .none
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
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
        ImageCache.default.clearMemoryCache()
        print("<<<<<< Clear memory cache")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(">>>>>>>>> scrollView did scroll: \(scrollView.contentOffset)")
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
                    if let _ = self.data.firstIndex(where: { $0.modal.href == modal.href }) {
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print(">>>>>>>>> scrollView did end Decelerating: \(scrollView.contentOffset)")
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
        tableView.rowHeight = 200 + 24 + 12 + 20
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
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
        let reserveData = data[indexPath.row]
        cell.loadData(reserveData.modal)
        for (index, imageView) in cell.previewImages.enumerated() {
            guard let url = reserveData.previewImages[index].url else {
                self.data[indexPath.row].previewImages[index].state = .error
                imageView.loadSizeFit(image: UIImage(named: "Bad")!, completion: { _ in
                    
                })
                continue
            }
            
            let updateImageThumbView: (UIImage) -> () = { thumb in
                DispatchQueue.main.async {
                    if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                        imageView.image = thumb
                    }
                }
            }
            switch reserveData.previewImages[index].state {
            case .wait:
                self.data[indexPath.row].previewImages[index].state = .downloading
                ImageCache.default.cacheImage(forUrl: url) { [unowned self] cache in
                    if let cache = cache {
                        self.data[indexPath.row].previewImages[index].state = .downloaded
                        imageView.loadSizeFit(url: url, image: cache, completion: updateImageThumbView)
                        return
                    }
                    
                    imageView.loadSizeFit(image: UIImage(named: "NetDisk")!, completion: { _ in })
                    ImageDownloader.default.downloadImage(with: url) { result in
                        switch result {
                        case .success(let value):
                            guard self.data.count > indexPath.row else {
                                print("****** Data being change ******")
                                return
                            }
                            ImageCache.default.store(value.image, forKey: url.absoluteString)
                            ImageCache.default.saveThumb(url: url, image: value.image)
                            self.data[indexPath.row].previewImages[index].state = .downloaded
                            self.data[indexPath.row].previewImages[index].size = value.image.size
                            imageView.loadSizeFit(url: url, image: value.image, completion: updateImageThumbView)
                        case .failure(let error):
                            print("Job failed: \(error.localizedDescription)")
                            self.data[indexPath.row].previewImages[index].state = .error
                            self.data[indexPath.row].previewImages[index].size = #imageLiteral(resourceName: "Failed").size
                            DispatchQueue.main.async {
                                if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                                    imageView.image = UIImage(named: "Failed")
                                }
                            }
                        }
                    }
                }
            case .downloading:
                imageView.loadSizeFit(image: UIImage(named: "NetDisk")!, completion: { _ in })
            case .downloaded:
                ImageCache.default.cacheImage(forUrl: url) { cache in
                    if let img = cache {
                        imageView.loadSizeFit(url: url, image: img, completion: updateImageThumbView)
                    }   else    {
                        imageView.loadSizeFit(image: UIImage(named: "Failed")!, completion: { _ in })
                    }
                }
                
            case .error:
                imageView.loadSizeFit(image: UIImage(named: "Failed")!, completion: { _ in })
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return caching[indexPath] ?? 265
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        caching[indexPath] = cell.layer.bounds.height
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

extension NetDiskListViewController: UITableViewDataSourcePrefetching {
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
                    ImageCache.default.cacheImage(forUrl: url) { [unowned self] cache in
                        if let cache = cache {
                            self.data[indexPath.row].previewImages[linkIndex].state = .downloaded
                            if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                                let cell = tableView.cellForRow(at: indexPath) as! NetDiskTableViewCell
                                cell.previewImages[item.offset].loadSizeFit(url: url, image: cache, completion: { thumb in
                                    DispatchQueue.main.async {
                                        if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                                            cell.previewImages[item.offset].image = thumb
                                        }
                                    }
                                })
                            }
                            return
                        }
                        ImageDownloader.default.downloadImage(with: url) { result in
                            switch result {
                            case .success(let value):
                                guard self.data.count > indexPath.row else {
                                    print("****** Data being change ******")
                                    return
                                }
                                ImageCache.default.store(value.image, forKey: url.absoluteString)
                                ImageCache.default.saveThumb(url: url, image: value.image)
                                self.data[indexPath.row].previewImages[linkIndex].state = .downloaded
                                self.data[indexPath.row].previewImages[linkIndex].size = value.image.size
                                DispatchQueue.main.async {
                                    if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                                        let cell = tableView.cellForRow(at: indexPath) as! NetDiskTableViewCell
                                        cell.previewImages[item.offset].loadSizeFit(url: url, image: value.image, completion: { thumb in
                                            DispatchQueue.main.async {
                                                if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                                                    cell.previewImages[item.offset].image = thumb
                                                }
                                            }
                                        })
                                    }
                                }
                            case .failure(let error):
                                print("Job failed: \(error.localizedDescription)")
                                self.data[indexPath.row].previewImages[linkIndex].state = .error
                                self.data[indexPath.row].previewImages[linkIndex].size = #imageLiteral(resourceName: "Failed").size
                                DispatchQueue.main.async {
                                    if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                                        let cell = tableView.cellForRow(at: indexPath) as! NetDiskTableViewCell
                                        cell.previewImages[item.offset].loadSizeFit(image: #imageLiteral(resourceName: "Failed"), completion: { _ in })
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Cloud Datebase
extension NetDiskListViewController: CloudSaver {
    func fetch(keyword: String) {
        func botFetch() {
            let bot = FetchBot.shareBot
            bot.delegate = self
            bot.pageOffset = 1
            DispatchQueue.global().async {
                bot.start(withSite: self.site)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        CKContainer.default().accountStatus { (status, err) in
            if let e = err {
                self.isCloudDataSource = false
                botFetch()
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
                if !keyword.isEmpty {                
                    guard modal.title.contains(keyword) else { return }
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

let compressQueue = DispatchQueue(label: "com.ascp.image.compress")

extension UIImageView {
    func loadSizeFit(url: URL? = nil, image: UIImage, completion: @escaping (UIImage) -> ()) {
        self.contentMode = image.size.width <= image.size.height ? .scaleAspectFit:.scaleAspectFill
        guard let u = url else {
            self.image = image
            return
        }
        ImageCache.default.cacheThumbImage(url: u, image: image, completion: completion)
    }
}

extension ImageCache {
    func thumbName(url: URL) -> String {
        return "ascp_thumb_" + url.absoluteString
    }
    
    func cacheImage(forUrl url: URL, completion: @escaping ((UIImage?) -> Void)) {
        if let img = ImageCache.default.retrieveImageInMemoryCache(forKey: url.absoluteString) {
            completion(img)
            return
        }
        
        ImageCache.default.retrieveImageInDiskCache(forKey: url.absoluteString) { result in
            switch result {
            case .success(let value):
                completion(value)
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func cacheImage(forName name: String, completion: @escaping ((UIImage?) -> Void)) {
        if let img = ImageCache.default.retrieveImageInMemoryCache(forKey: name) {
            completion(img)
            return
        }
        
        ImageCache.default.retrieveImageInDiskCache(forKey: name) { result in
            switch result {
            case .success(let value):
                completion(value)
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func cacheThumbImage(url: URL, image: UIImage, completion: @escaping (UIImage) -> ()) {
        let name = thumbName(url: url)
        cacheImage(forName: name) { originImage in
            guard let originImage = originImage else {
                var data : Data!
                var ratio : CGFloat = 0.5
                let maxBytes = 512 * 1024
                compressQueue.async {
                    repeat {
                        data = image.jpegData(compressionQuality: ratio)
                        ratio *= 0.5
                    } while (data.count > maxBytes)
                    let thumb = UIImage(data: data)!
                    ImageCache.default.store(thumb, forKey: name)
                    completion(thumb)
                }
                return
            }
            
            completion(originImage)
        }
    }
    
    func saveThumb(url: URL, image: UIImage) {
        let name = thumbName(url: url)
        var data : Data!
        var ratio : CGFloat = 0.5
        let maxBytes = 512 * 1024
        repeat {
            data = image.jpegData(compressionQuality: ratio)
            ratio *= 0.5
        } while (data.count > maxBytes)
        let thumb = UIImage(data: data)!
        ImageCache.default.store(thumb, forKey: name)
    }
}

//
//  NetDiskDetailViewController.swift
//  S8Blocker
//
//  Created by virus1994 on 2017/8/17.
//  Copyright © 2017年 ascp. All rights reserved.
//

import UIKit
import WebKit
import Kingfisher

enum DownloadState {
    case wait
    case downloading
    case downloaded
    case error
}

struct ImageItem {
    var url: URL?
    var state: DownloadState
    var size: CGSize
    var radio: CGFloat {
        return size.height / size.width
    }
    func realHeight(fitWidth: CGFloat) -> CGFloat {
        return radio * fitWidth
    }
}

class NetDiskDetailViewController: UITableViewController {
    var netdisk : NetDiskModal?
    var images = [ImageItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "详情"
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "NetDiskTitleTableViewCell", bundle: nil), forCellReuseIdentifier: NetDiskTitleTableViewCellIdentitfier)
        tableView.register(UINib(nibName: "NetDiskImageTableViewCell", bundle: nil), forCellReuseIdentifier: NetDiskImageTableViewCellIdentitfier)
        tableView.separatorStyle = .none
        
        guard let imageLinks = netdisk?.images else {
            return
        }
        
        images = imageLinks.map({ ImageItem(url: URL(string: $0), state: .wait, size: #imageLiteral(resourceName: "NetDisk").size) })
        
        let saveItem = UIBarButtonItem(title: "收藏", style: .plain, target: self, action: #selector(saver))
        navigationItem.rightBarButtonItem = saveItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension NetDiskDetailViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 + images.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: NetDiskTitleTableViewCellIdentitfier, for: indexPath) as! NetDiskTitleTableViewCell
            cell.title.text = netdisk?.title
            cell.title.textColor = .black
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: NetDiskTitleTableViewCellIdentitfier, for: indexPath) as! NetDiskTitleTableViewCell
            cell.title.text = netdisk?.fileSize
            cell.title.textColor = .lightGray
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: NetDiskTitleTableViewCellIdentitfier, for: indexPath) as! NetDiskTitleTableViewCell
            cell.title.text = netdisk?.password
            cell.title.textColor = .lightGray
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: NetDiskImageTableViewCellIdentitfier, for: indexPath) as! NetDiskImageTableViewCell
            
            func layoutMaker(radio: CGFloat) {
                let constraint = NSLayoutConstraint(item: cell.img, attribute: .height, relatedBy: .equal, toItem: cell.img, attribute: .width, multiplier: radio, constant: 0)
                constraint.priority = UILayoutPriority(rawValue: 999)
                NSLayoutConstraint.activate([constraint])
            }
            
            let linkIndex = indexPath.row - 3
            let item = self.images[linkIndex]
            let url = item.url
            
            switch item.state {
            case .wait:
                self.images[linkIndex].state = .downloading
                cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "NetDisk"), options: nil, progressBlock: nil, completionHandler: { (img, err, cache, urlx) in
                    if let _ = err {
                        DispatchQueue.main.async {
                            self.images[linkIndex].state = .error
                            self.images[linkIndex].size = #imageLiteral(resourceName: "Failed").size
                            layoutMaker(radio: self.images[linkIndex].radio)
                            tableView.reloadData()
                        }
                        return
                    }
                    
                    if let img = img {
                        DispatchQueue.main.async {
                            self.images[linkIndex].state = .downloaded
                            self.images[linkIndex].size = img.size
                            layoutMaker(radio: self.images[linkIndex].radio)
                            tableView.reloadData()
                        }
                    }
                })
            case .downloading:
                cell.img.image = #imageLiteral(resourceName: "NetDisk")
            case .downloaded:
                cell.img.kf.setImage(with: url)
            case .error:
                cell.img.image = #imageLiteral(resourceName: "Failed")
            }
            
            layoutMaker(radio: self.images[linkIndex].radio)
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if let cell = tableView.cellForRow(at: indexPath) as? NetDiskImageTableViewCell, let img = cell.img.image {
//            return self.view.frame.size.width * (img.size.height / img.size.width)
//        }
//        return 300
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Favorite
extension NetDiskDetailViewController: CloudSaver {
    @objc func saver() {
        save(netDisk: netdisk!) { (rec, err) in
            if let e = err {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "保存失败", message: e.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            if let record = rec {
                print("Save to cloud Ok: \(record.recordID)")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "保存成功", message: "请在收藏夹里面查看", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

